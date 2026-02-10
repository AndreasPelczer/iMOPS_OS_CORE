// ============================================================
//  TaskRepository.swift
//  iMOPS_OS_CORE
//
//  Task-Verwaltung mit 4-stufigem Lebenszyklus:
//  offen -> inArbeit -> erledigt -> abgenommen (HACCP-versiegelt)
//
//  Die HACCP-Tresor-Logik bleibt unangetastet:
//  Bei Abschluss wird archiviert + KILLTREE.
// ============================================================

import Foundation

struct TaskRepository {

    // MARK: - Task erstellen

    /// Erzeugt einen neuen Arbeits-Bon mit ChefIQ-Vorbereitung
    static func createProductionTask(id: String, title: String, weight: Int = 10) {
        let timestamp = Date().timeIntervalSince1970

        // 1. Zuerst die Metadaten (Gewicht ist wichtig fuer die Matrix!)
        iMOPS.SET(.task(id, "TITLE"), title)
        iMOPS.SET(.task(id, "CREATED"), timestamp)
        iMOPS.SET(.task(id, "WEIGHT"), weight)

        // 2. Jetzt erst den Status setzen - das triggert die Matrix-Berechnung
        iMOPS.SET(.task(id, "STATUS"), ArbeitsschrittStatus.offen.storageValue)

        print("iMOPS-GRID: Neuer Task injiziert: \(title) (Weight: \(weight))")
    }

    // MARK: - Status-Transition (4-Stufen-Lebenszyklus)

    /// Aendert den Status eines Arbeitsschritts im Lebenszyklus.
    /// Gueltige Uebergaenge:
    ///   offen -> inArbeit -> erledigt -> abgenommen
    ///   offen -> erledigt (Schnell-Quittierung, Legacy)
    ///
    /// Bei .erledigt wird automatisch archiviert (HACCP-Tresor).
    /// Bei .abgenommen wird der Commander-Stempel gesetzt.
    static func transitionTask(id: String, to newStatus: ArbeitsschrittStatus) {
        let currentRaw: String? = iMOPS.GET(.task(id, "STATUS"))
        guard let currentRaw = currentRaw else {
            print("iMOPS-KERNEL-ERROR: Task \(id) existiert nicht im Kernel.")
            return
        }

        let current = ArbeitsschrittStatus(fromStorage: currentRaw)

        // Validierung: Nur erlaubte Uebergaenge
        guard isValidTransition(from: current, to: newStatus) else {
            print("iMOPS-KERNEL-ERROR: Ungueltiger Uebergang \(current.rawValue) -> \(newStatus.rawValue) fuer Task \(id)")
            return
        }

        switch newStatus {
        case .offen:
            iMOPS.SET(.task(id, "STATUS"), newStatus.storageValue)

        case .inArbeit:
            iMOPS.SET(.task(id, "STATUS"), newStatus.storageValue)
            print("iMOPS-GRID: Task \(id) in Bearbeitung.")

        case .erledigt:
            // HACCP-Archivierung: Tresor versiegeln
            sealToArchive(id: id)

        case .abgenommen:
            // Commander-Abnahme: Finaler Stempel
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            iMOPS.SET(.archive(id, "ABGENOMMEN"), formatter.string(from: now))
            iMOPS.SET(.archive(id, "ABGENOMMEN_VON"),
                       iMOPS.GET(.nav("ACTIVE_USER")) as String? ?? "COMMANDER")
            print("iMOPS-HACCP: Task \(id) vom Commander abgenommen.")
        }
    }

    // MARK: - Legacy: completeTask (Abwaertskompatibel)

    /// Task quittieren = HACCP Tresor / Revisionssicheres Archiv
    /// Behaelt das bisherige Verhalten bei: offen -> erledigt (direkt).
    static func completeTask(id: String) {
        sealToArchive(id: id)
    }

    // MARK: - HACCP Tresor (Interne Logik)

    /// Versiegelt einen Task im HACCP-Tresor.
    /// Diese Daten sind ab jetzt unantastbar fuer den operativen Betrieb.
    private static func sealToArchive(id: String) {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let timeString = formatter.string(from: now)

        // 1) Daten-Snapshot aus dem Kernel ziehen
        let title: String = iMOPS.GET(.task(id, "TITLE")) ?? "UNBEKANNT"
        let user: String = iMOPS.GET(.nav("ACTIVE_USER")) ?? "SYSTEM"

        // ChefIQ-Pins retten vor dem Loeschen
        let medical: String = iMOPS.GET(.task(id, "PINS.MEDICAL")) ?? "N/A"
        let sop: String = iMOPS.GET(.task(id, "PINS.SOP")) ?? "N/A"

        // 2) HACCP Tresor versiegeln (^ARCHIVE)
        iMOPS.SET(.archive(id, "TITLE"), title)
        iMOPS.SET(.archive(id, "TIME"), timeString)
        iMOPS.SET(.archive(id, "USER"), user)
        iMOPS.SET(.archive(id, "MEDICAL_SNAPSHOT"), medical)
        iMOPS.SET(.archive(id, "SOP_REFERENCE"), sop)

        // 3) Den aktiven Arbeitsplatz (Subtree) loeschen
        iMOPS.KILLTREE(.task(id, ""))

        print("iMOPS-HACCP: Task \(id) inklusive ChefIQ-Daten versiegelt um \(timeString). ;=)")

        // 4) Automatische Rueckkehr zum Auswahl-Bildschirm
        iMOPS.GOTO("BRIGADE_SELECT")
        DispatchQueue.main.async {
            TheBrain.shared.archiveUpdateTrigger += 1
        }
    }

    // MARK: - Transition-Validierung

    /// Prueft ob ein Status-Uebergang erlaubt ist.
    private static func isValidTransition(
        from current: ArbeitsschrittStatus,
        to target: ArbeitsschrittStatus
    ) -> Bool {
        switch (current, target) {
        case (.offen, .inArbeit):      return true
        case (.offen, .erledigt):      return true  // Schnell-Quittierung (Legacy)
        case (.inArbeit, .erledigt):   return true
        case (.erledigt, .abgenommen): return true
        default:                       return false
        }
    }

    // MARK: - Navigation (Optimiert)

    private var lastLocation: String = ""

    mutating func updateLocation(_ newLocation: String) {
        guard newLocation != lastLocation else { return }

        let startTime = DispatchTime.now()
        iMOPS.SET(.nav("LOCATION"), newLocation)
        lastLocation = newLocation

        let endTime = DispatchTime.now()
        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        print("iMOPS-CORE-SPEED: ^NAV.LOCATION gesetzt in \(nanoTime) ns (Optimiert)")
    }
}
