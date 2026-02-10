//
//  TheBrain.swift
//  iMOPS_OS_CORE
//
//  Kernel 1.1 (Matrix Edition)
//  - Thread-safe Storage & Matrix Calculation
//  - Reaktive Meier-Score Überwachung
//  - Service-Fieberkurve (Score-Historie)
//  - TDDA-Update: Mensch-Meier-Formel & Fatigue-Vektor integriert
//

import Foundation
import Observation

/// Ein präziser Datenpunkt für die Service-Fieberkurve
/// Damit dein Bruder (der Ingenieur) die Last-Verteilung grafisch versteht.
struct MatrixPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let score: Int
}

/// ^iMOPS GLOBAL - Die unbestechliche Wahrheit (Kernel)
/// Hinweis für die Brigade:
/// - Wir bleiben beim "MUMPS-Global"-Mapping: [String: Any]
/// - Wir schützen den Zugriff via Serial Queue (Thread-Safety).
/// - NEU: Die Pelczer-Matrix berechnet die Belastung live und schreibt die Historie.
@available(iOS 17.0, *)
@Observable
final class TheBrain {
    static let shared = TheBrain()

    /// Der "Global Store" (MUMPS Global)
    /// Hier liegen alle Realitäts-Daten der Brigade.
    private var storage: [String: Any] = [:]
    
    /// Der "Wachrüttler" für die UI-Synchronisation
    var archiveUpdateTrigger: Int = 0

    /// DIE PELCZER-MATRIX (Meier-Score)
    /// Diese Property ist reaktiv. SwiftUI wird rot, wenn Harry brennt.
    private(set) var meierScore: Int = 0
    
    /// DAS SERVICE-GEDÄCHTNIS
    /// Speichert die letzten 50 Belastungsänderungen für die Fieberkurve.
    var scoreHistory: [MatrixPoint] = []

    /// Kernel-Lock:
    /// Schützt den Store vor Race-Conditions, wenn am Pass das Chaos ausbricht.
    private let kernelQueue = DispatchQueue(label: "imops.kernel.queue", qos: .userInitiated)

    // MARK: - Matrix Engine (Internal)

    /// Berechnet die aktuelle kognitive Last.
    /// Läuft innerhalb der kernelQueue, damit nichts korrumpiert.
    private func refreshMeierScore() {
        let allKeys = storage.keys
        
        // Wir suchen alle offenen Tasks (TDDA: Offene Entropie-Quellen)
        let activeTasks = allKeys.filter {
            $0.hasPrefix("^TASK.") &&
            $0.hasSuffix(".STATUS") &&
            (storage[$0] as? String == "OPEN")
        }
        
        var totalLoad = 0
        var oldestTimestamp: Double = Date().timeIntervalSince1970
        
        for key in activeTasks {
            let components = key.components(separatedBy: ".")
            if components.count >= 2 {
                let taskID = components[1]
                
                // Gewichtung: Standard 10, es sei denn, wir haben spezifisches Gewicht gesetzt
                let weight = storage["^TASK.\(taskID).WEIGHT"] as? Int ?? 10
                totalLoad += weight
                
                // Zeit-Erfassung für den Ermüdungsfaktor ("Die Suppe lügt nicht")
                let created = storage["^TASK.\(taskID).CREATED"] as? Double ?? Date().timeIntervalSince1970
                if created < oldestTimestamp { oldestTimestamp = created }
            }
        }
        
        // --- INJEKTION: MENSCH-MEIER-FORMEL ---
        
        // 1. Ermüdungs-Vektor: Wie lange druckt die älteste Aufgabe?
        let hoursOnClock = (Date().timeIntervalSince1970 - oldestTimestamp) / 3600
        let fatigueFactor = 1.0 + (hoursOnClock / 10.0) // 10% Last-Zuwachs pro Stunde Standzeit
        
        // 2. Kapazitäts-Check: Wer ist in der Brigade?
        let staffCount = allKeys.filter { $0.hasPrefix("^BRIGADE.") && $0.hasSuffix(".NAME") }.count
        let systemCapacity = Double(max(staffCount, 1) * 20) // Jeder Kopf trägt ca. 20 Units stabil
        
        // 3. Berechnung der Pelczer-Matrix (MMZ)
        var finalLoad = (Double(totalLoad) / systemCapacity) * fatigueFactor * 100
        
        // 4. BOURDAIN-GUARD (Gen 3): Ermüdungsschutz der Brigade
        // Bei langer Schicht steigt die Grundlast automatisch (Altgesellen-Prinzip)
        let shiftStart = storage["^SYS.SHIFT_START"] as? Date ?? Date()
        let taskValidation = BourdainGuard.validateTaskAction(startTime: shiftStart)
        switch BourdainGuard.checkWorkLifeBalance(startTime: shiftStart) {
        case .warning: finalLoad *= 1.15  // +15% Last ab 8h
        case .reset:   finalLoad *= 1.30  // +30% Last ab 10h
        case .fresh:   break
        }

        // 5. RIO-REISER-JITTER (Gen 3): Schutz des Individuums (MenschMeierModus)
        // Jitter-Stärke skaliert mit Ermüdungslevel (Gen 3 BourdainGuard)
        let normalizedLoad = min(max(finalLoad / 100.0, 0.0), 1.0)
        let noise = Double.random(in: -taskValidation.jitterStrength...taskValidation.jitterStrength)
        let jitteredLoad = min(max(normalizedLoad + noise, 0.0), 1.0) * 100.0

        let scoreResult = Int(min(max(jitteredLoad, 0), 100))

        // 6. WHISPER-MESSAGE: Flüsternde Warnung bei Ermüdung
        if let whisper = taskValidation.whisper {
            print("iMOPS-BOURDAIN: \(whisper)")
        }
        
        // Zurück auf den Main-Thread für das UI-Feuerwerk und die Historie
        DispatchQueue.main.async {
            self.meierScore = scoreResult
            
            // Punkt in die Fieberkurve injizieren
            let newPoint = MatrixPoint(timestamp: Date(), score: scoreResult)
            self.scoreHistory.append(newPoint)
            
            // Wir begrenzen das Gedächtnis auf 50 Punkte (Performance-Schutz)
            if self.scoreHistory.count > 50 {
                self.scoreHistory.removeFirst()
            }
        }
    }

    // MARK: - Kernel Safety

    /// Minimaler Pfad-Validator:
    /// Ein Global muss mit ^ starten und darf kein "Bullshit-Rauschen" (Leerzeichen) enthalten.
    private func validate(_ path: String) -> Bool {
        guard !path.isEmpty else { return false }
        guard path.hasPrefix("^") else { return false }
        guard !path.contains(" ") else { return false }
        return true
    }

    // MARK: - Core Commands (SET / GET / KILL)

    /// Der S-Befehl (Set)
    /// Schreibt Daten und triggert sofort die Matrix-Berechnung.
    func set(_ path: String, _ value: Any) {
        guard validate(path) else {
            print("iMOPS-KERNEL-ERROR: Ungültiger Pfad (SET): \(path)")
            return
        }

        let start = DispatchTime.now()

        kernelQueue.sync {
            storage[path] = value
            // Zündung der Matrix-Engine bei jeder Änderung
            refreshMeierScore()
        }

        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds

        // Performance-Log: Für das Gefühl von unendlicher Power
        print("iMOPS-CORE-SPEED: \(path) gesetzt in \(nanoTime) ns")
    }

    /// Der G-Befehl (Get) - Typsicherer Zugriff auf die Wahrheit.
    func get<T>(_ path: String) -> T? {
        guard validate(path) else {
            print("iMOPS-KERNEL-ERROR: Ungültiger Pfad (GET): \(path)")
            return nil
        }

        return kernelQueue.sync {
            storage[path] as? T
        }
    }

    /// Der KILL-Befehl (Einzel-Key löschen)
    func kill(_ path: String) {
        guard validate(path) else {
            print("iMOPS-KERNEL-ERROR: Ungültiger Pfad (KILL): \(path)")
            return
        }

        kernelQueue.sync {
            storage.removeValue(forKey: path)
            refreshMeierScore()
        }
    }

    /// KILL-TREE
    /// Löscht ganze Baumstrukturen (z.B. wenn ein Task komplett erledigt ist).
    func killTree(prefix: String) {
        guard validate(prefix) else {
            print("iMOPS-KERNEL-ERROR: Ungültiger Prefix (KILLTREE): \(prefix)")
            return
        }

        kernelQueue.sync {
            let keysToRemove = storage.keys.filter { $0.hasPrefix(prefix) }
            for k in keysToRemove {
                storage.removeValue(forKey: k)
            }
            refreshMeierScore()
        }
    }

    // MARK: - Bridge: KernelArbeitsschritt

    /// Materialisiert alle aktiven Tasks als typisierte KernelArbeitsschritt-Objekte.
    /// Lese-Fassade ueber den [String: Any]-Storage. Thread-safe.
    func getArbeitsschritte() -> [KernelArbeitsschritt] {
        let snapshot: [String: Any] = kernelQueue.sync { storage }

        // Alle einzigartigen Task-IDs finden
        let taskIDs = Set(
            snapshot.keys
                .filter { $0.hasPrefix("^TASK.") }
                .compactMap { key -> String? in
                    let parts = key.components(separatedBy: ".")
                    return parts.count >= 2 ? parts[1] : nil
                }
        )

        return taskIDs.compactMap { id in
            KernelArbeitsschritt.fromStorage(id: id, storage: snapshot)
        }
    }

    // MARK: - Inventory / Export

    /// Inventur: alle Keys (Snapshot für Debugging)
    func allKeys() -> [String] {
        kernelQueue.sync {
            Array(storage.keys)
        }
    }

    /// Exportiert den Archiv-Bereich als Text.
    /// Revisionssicherer Snapshot für den Commander.
    ///
    /// DSGVO-Konformitaet: Guards werden VOR Export angewendet.
    /// Schutz darf nicht nur beim Anzeigen gelten,
    /// sondern auch beim Verlassen des Systems.
    func exportLog(securityLevel: SecurityLevel = .standard,
                   adminRequestCount: Int = 0) -> String {
        let snapshot: [String: Any] = kernelQueue.sync { storage }

        // Guard-Check VOR Export: PrivacyShield pruefen
        let shieldActive = MenschMeierModus.shouldTriggerPrivacyShield(
            requestCount: adminRequestCount
        )
        let effectiveLevel: SecurityLevel = shieldActive ? .deEscalation : securityLevel

        var log = "--- iMOPS HACCP EXPORT ---\n"
        log += "Timestamp: \(Date().description)\n"
        log += "Security: \(effectiveLevel.displayName)\n"
        log += "--------------------------\n\n"

        let archiveKeys = snapshot.keys
            .filter { $0.hasPrefix("^ARCHIVE") }
            .sorted()

        for key in archiveKeys {
            var value = "\(snapshot[key] ?? "")"

            // Guard: Rollen-Felder bei De-Eskalation anonymisieren
            if effectiveLevel == .deEscalation &&
               (key.hasSuffix(".ROLE") || key.hasSuffix(".ABGENOMMEN_VON")) {
                value = MenschMeierModus.anonymizeForAdmin(
                    author: value, securityLevel: effectiveLevel
                )
            }

            log += "\(key): \(value)\n"
        }

        log += "\n--- ENDE DER ÜBERTRAGUNG ---"
        return log
    }

    /// Exportiert den Archiv-Bereich als CSV.
    /// Spalten: ID, Titel, Zeitfenster, Rolle, Medical, SOP
    /// DSGVO-Konformitaet: Guards werden VOR Export angewendet.
    func exportCSV(securityLevel: SecurityLevel = .standard,
                   adminRequestCount: Int = 0) -> String {
        let (ids, snapshot, effectiveLevel) = prepareExport(
            securityLevel: securityLevel, adminRequestCount: adminRequestCount
        )

        var csv = "ID;TITEL;ZEITFENSTER;ROLLE;MEDICAL;SOP\n"

        for id in ids {
            let title = snapshot["^ARCHIVE.\(id).TITLE"] as? String ?? ""
            let time = snapshot["^ARCHIVE.\(id).TIME"] as? String ?? ""
            var role = snapshot["^ARCHIVE.\(id).ROLE"] as? String ?? "Brigade"
            let medical = snapshot["^ARCHIVE.\(id).MEDICAL_SNAPSHOT"] as? String ?? ""
            let sop = snapshot["^ARCHIVE.\(id).SOP_REFERENCE"] as? String ?? ""

            if effectiveLevel == .deEscalation {
                role = MenschMeierModus.anonymizeForAdmin(
                    author: role, securityLevel: effectiveLevel
                )
            }

            csv += "\(id);\(title);\(time);\(role);\(medical);\(sop)\n"
        }

        return csv
    }

    /// Exportiert den Archiv-Bereich als JSON.
    /// DSGVO-Konformitaet: Guards werden VOR Export angewendet.
    func exportJSON(securityLevel: SecurityLevel = .standard,
                    adminRequestCount: Int = 0) -> String {
        let (ids, snapshot, effectiveLevel) = prepareExport(
            securityLevel: securityLevel, adminRequestCount: adminRequestCount
        )

        var entries: [[String: String]] = []

        for id in ids {
            let title = snapshot["^ARCHIVE.\(id).TITLE"] as? String ?? ""
            let time = snapshot["^ARCHIVE.\(id).TIME"] as? String ?? ""
            var role = snapshot["^ARCHIVE.\(id).ROLE"] as? String ?? "Brigade"
            let medical = snapshot["^ARCHIVE.\(id).MEDICAL_SNAPSHOT"] as? String ?? ""
            let sop = snapshot["^ARCHIVE.\(id).SOP_REFERENCE"] as? String ?? ""

            if effectiveLevel == .deEscalation {
                role = MenschMeierModus.anonymizeForAdmin(
                    author: role, securityLevel: effectiveLevel
                )
            }

            entries.append([
                "id": id, "titel": title, "zeitfenster": time,
                "rolle": role, "medical": medical, "sop": sop
            ])
        }

        let meta: [String: Any] = [
            "version": "iMOPS v1.0",
            "exportiert": Date().description,
            "security": effectiveLevel.displayName,
            "eintraege": entries.count
        ]

        // Manuelles JSON (kein JSONEncoder noetig fuer [String: Any])
        var json = "{\n"
        json += "  \"meta\": {\n"
        json += "    \"version\": \"\(meta["version"] ?? "")\",\n"
        json += "    \"exportiert\": \"\(meta["exportiert"] ?? "")\",\n"
        json += "    \"security\": \"\(meta["security"] ?? "")\",\n"
        json += "    \"eintraege\": \(meta["eintraege"] ?? 0)\n"
        json += "  },\n"
        json += "  \"archiv\": [\n"

        for (i, entry) in entries.enumerated() {
            json += "    {\n"
            json += "      \"id\": \"\(entry["id"] ?? "")\",\n"
            json += "      \"titel\": \"\(entry["titel"] ?? "")\",\n"
            json += "      \"zeitfenster\": \"\(entry["zeitfenster"] ?? "")\",\n"
            json += "      \"rolle\": \"\(entry["rolle"] ?? "")\",\n"
            json += "      \"medical\": \"\(entry["medical"] ?? "")\",\n"
            json += "      \"sop\": \"\(entry["sop"] ?? "")\"\n"
            json += "    }\(i < entries.count - 1 ? "," : "")\n"
        }

        json += "  ]\n"
        json += "}"
        return json
    }

    /// Gemeinsame Guard-Vorbereitung fuer alle Export-Formate.
    /// Gibt (sortierte IDs, Snapshot, effektives SecurityLevel) zurueck.
    private func prepareExport(
        securityLevel: SecurityLevel,
        adminRequestCount: Int
    ) -> (ids: [String], snapshot: [String: Any], effectiveLevel: SecurityLevel) {
        let snapshot: [String: Any] = kernelQueue.sync { storage }

        let shieldActive = MenschMeierModus.shouldTriggerPrivacyShield(
            requestCount: adminRequestCount
        )
        let effectiveLevel: SecurityLevel = shieldActive ? .deEscalation : securityLevel

        let ids = snapshot.keys
            .filter { $0.hasPrefix("^ARCHIVE.") && $0.hasSuffix(".TITLE") }
            .compactMap { $0.components(separatedBy: ".").dropFirst().first }
            .sorted(by: >)

        return (ids, snapshot, effectiveLevel)
    }

    // MARK: - Kernel Self-Check

    /// Ergebnis eines einzelnen Pruefschritts
    struct CheckResult: Identifiable {
        let id = UUID()
        let name: String
        let passed: Bool
        let detail: String
    }

    /// Fuehrt einen vollstaendigen Kernel-Selbsttest durch.
    /// Prueft alle Guards, die DSGVO-Konformitaet und die Kernel-Integritaet.
    /// Laeuft in der App — kein Xcode noetig.
    func kernelSelfCheck() -> [CheckResult] {
        var results: [CheckResult] = []

        // 1. SecurityLevel: Genau 2 Cases
        let slCount = SecurityLevel.allCases.count
        results.append(CheckResult(
            name: "SecurityLevel Cases",
            passed: slCount == 2,
            detail: slCount == 2
                ? "Genau 2 Stufen (.standard, .deEscalation)"
                : "FEHLER: \(slCount) Stufen gefunden statt 2"
        ))

        // 2. SecurityLevel: De-Eskalation aktiviert Shield
        results.append(CheckResult(
            name: "De-Eskalation Shield",
            passed: SecurityLevel.deEscalation.isShieldActive,
            detail: SecurityLevel.deEscalation.isShieldActive
                ? "Shield aktiv bei De-Eskalation"
                : "FEHLER: Shield nicht aktiv"
        ))

        // 3. Rio Reiser Jitter: Clamping 0.0...1.0
        var jitterOK = true
        for _ in 0..<100 {
            let v = MenschMeierModus.applyRioReiserJitter(value: 0.5)
            if v < 0.0 || v > 1.0 { jitterOK = false; break }
        }
        results.append(CheckResult(
            name: "Jitter Clamping",
            passed: jitterOK,
            detail: jitterOK
                ? "100 Iterationen im Bereich 0.0...1.0"
                : "FEHLER: Jitter ausserhalb der Grenzen"
        ))

        // 4. Jitter Amplitude <= 5%
        var amplitudeOK = true
        for _ in 0..<100 {
            let v = MenschMeierModus.applyRioReiserJitter(value: 0.5)
            if abs(v - 0.5) > 0.05 { amplitudeOK = false; break }
        }
        results.append(CheckResult(
            name: "Jitter Amplitude",
            passed: amplitudeOK,
            detail: amplitudeOK
                ? "Amplitude <= 5% (100 Iterationen)"
                : "FEHLER: Amplitude ueberschreitet 5%"
        ))

        // 5. Anonymisierung: De-Eskalation gibt "Brigade"
        let anon = MenschMeierModus.anonymizeForAdmin(
            author: "Harry Meier", securityLevel: .deEscalation
        )
        results.append(CheckResult(
            name: "Anonymisierung",
            passed: anon == "Brigade",
            detail: anon == "Brigade"
                ? "De-Eskalation anonymisiert zu 'Brigade'"
                : "FEHLER: Ergebnis ist '\(anon)' statt 'Brigade'"
        ))

        // 6. Privacy Shield: Schwelle bei > 50
        let under = MenschMeierModus.shouldTriggerPrivacyShield(requestCount: 50)
        let over = MenschMeierModus.shouldTriggerPrivacyShield(requestCount: 51)
        results.append(CheckResult(
            name: "Privacy Shield Schwelle",
            passed: !under && over,
            detail: !under && over
                ? "Inaktiv bei 50, aktiv bei 51"
                : "FEHLER: Schwelle nicht bei > 50"
        ))

        // 7. Allergen immer transparent
        let allergenProtected = MenschMeierModus.isPrivacyShieldActive(priority: "allergen")
        results.append(CheckResult(
            name: "Allergen Transparenz",
            passed: !allergenProtected,
            detail: !allergenProtected
                ? "Allergen-Schritte immer sichtbar"
                : "FEHLER: Allergen wird geschuetzt (Lebensgefahr!)"
        ))

        // 8. BourdainGuard: Frische Schicht = .fresh
        let freshLevel = BourdainGuard.checkWorkLifeBalance(startTime: Date())
        results.append(CheckResult(
            name: "BourdainGuard Fresh",
            passed: freshLevel == .fresh,
            detail: freshLevel == .fresh
                ? "Neue Schicht ergibt .fresh"
                : "FEHLER: Neue Schicht ergibt .\(freshLevel.rawValue)"
        ))

        // 9. BourdainGuard: 9h = .warning
        let warningLevel = BourdainGuard.checkWorkLifeBalance(
            startTime: Date().addingTimeInterval(-9 * 3600)
        )
        results.append(CheckResult(
            name: "BourdainGuard 9h",
            passed: warningLevel == .warning,
            detail: warningLevel == .warning
                ? "9h Schicht ergibt .warning"
                : "FEHLER: 9h ergibt .\(warningLevel.rawValue)"
        ))

        // 10. BourdainGuard: 11h = .reset + Training
        let resetLevel = BourdainGuard.checkWorkLifeBalance(
            startTime: Date().addingTimeInterval(-11 * 3600)
        )
        results.append(CheckResult(
            name: "BourdainGuard 11h",
            passed: resetLevel == .reset && resetLevel.forceTrainingMode,
            detail: resetLevel == .reset
                ? "11h Schicht: .reset + Training erzwungen"
                : "FEHLER: 11h ergibt .\(resetLevel.rawValue)"
        ))

        // 11. DSGVO: Archiv speichert ROLE, nicht USER
        let snapshot: [String: Any] = kernelQueue.sync { storage }
        let hasUser = snapshot.keys.contains { $0.hasPrefix("^ARCHIVE.") && $0.hasSuffix(".USER") }
        let hasRole = snapshot.keys.contains { $0.hasPrefix("^ARCHIVE.") && $0.hasSuffix(".ROLE") }
            || snapshot.keys.filter { $0.hasPrefix("^ARCHIVE.") }.isEmpty // Kein Archiv = OK
        results.append(CheckResult(
            name: "DSGVO Archiv",
            passed: !hasUser,
            detail: hasUser
                ? "FEHLER: ^ARCHIVE.*.USER gefunden (personenbezogen!)"
                : hasRole ? "Archiv nutzt ROLE statt USER" : "Archiv leer (OK)"
        ))

        // 12. Schicht-Start registriert
        let shiftStart = snapshot["^SYS.SHIFT_START"] as? Date
        results.append(CheckResult(
            name: "Schicht-Start",
            passed: shiftStart != nil,
            detail: shiftStart != nil
                ? "^SYS.SHIFT_START registriert"
                : "FEHLER: Kein Schicht-Start im Kernel"
        ))

        // 13. KernelGuards Orchestrator funktioniert
        let report = KernelGuards.evaluate(
            schritte: getArbeitsschritte(),
            securityLevel: .standard,
            sessionStart: shiftStart ?? Date()
        )
        let terminalOK = report.terminalStatus.contains("SECURITY")
            && report.terminalStatus.contains("FATIGUE")
            && report.terminalStatus.contains("LOAD")
        results.append(CheckResult(
            name: "KernelGuards Orchestrator",
            passed: terminalOK,
            detail: terminalOK
                ? "evaluate() liefert vollstaendigen Report"
                : "FEHLER: terminalStatus unvollstaendig"
        ))

        // Ergebnis loggen
        let passed = results.filter { $0.passed }.count
        let total = results.count
        print("iMOPS-SELFCHECK: \(passed)/\(total) Tests bestanden")
        if passed < total {
            for r in results where !r.passed {
                print("iMOPS-SELFCHECK-FAIL: \(r.name) — \(r.detail)")
            }
        }

        return results
    }

    /// Holt alle versiegelten IDs aus dem Tresor (^ARCHIVE)
    func getArchiveIDs() -> [String] {
        let snapshot = kernelQueue.sync { storage }
        let archiveKeys = snapshot.keys.filter { $0.hasPrefix("^ARCHIVE") && $0.hasSuffix(".TITLE") }
        
        return archiveKeys.compactMap { key in
            key.components(separatedBy: ".").dropFirst().first
        }.sorted(by: >)
    }
    
    func simulateRushHour() {
        print("iMOPS-MATRIX: Starte Belastungssimulation...")
        
        // Wir ballern 10 kritische Bons in den Kernel
        for i in 1...10 {
            let id = "STRESS_\(i)"
            set("^TASK.\(id).TITLE", "EXTREM-BON #\(i)")
            set("^TASK.\(id).CREATED", Date().timeIntervalSince1970)
            set("^TASK.\(id).WEIGHT", 15) // Jeder Bon wiegt 15 Punkte
            set("^TASK.\(id).STATUS", "OPEN")
        }
        
        print("iMOPS-MATRIX: Simulation abgeschlossen. Aktueller Score: \(meierScore)")
    }

    // MARK: - Seed / Boot

    /// Boot-Sequenz: Minimal-Daten + ChefIQ Injektion
    func seed() {
        // 1) Brigade laden (Stamm-Mannschaft)
        set("^BRIGADE.HARRY.NAME", "Harry Meier")
        set("^BRIGADE.HARRY.ROLE", "Gardemanger")
        set("^BRIGADE.LUKAS.NAME", "Lukas")
        set("^BRIGADE.LUKAS.ROLE", "Runner")

        // 2) Den "Smart-Task" 001 vorbereiten
        set("^TASK.001.TITLE", "MATJES WÄSSERN")
        set("^TASK.001.CREATED", Date().timeIntervalSince1970)
        
        // Zuerst das Gewicht (Kognitive Last) setzen...
        set("^TASK.001.WEIGHT", 5)
        
        // ...und DANN den Status. Erst jetzt findet die Matrix-Engine
        // den Task UND sein Gewicht gleichzeitig im Speicher.
        set("^TASK.001.STATUS", "OPEN")

        // 3) ChefIQ Zusatz-Infos (HACCP / Medizinische Pins)
        set("^TASK.001.PINS.MEDICAL", "BE: 0.1 | kcal: 145 | ALLERGEN: D")
        set("^TASK.001.PINS.SOP", "Wässerung: 12h bei < 4°C. Wasser 2x wechseln.")
        
        // 4) System-Status Zündung
        set("^SYS.STATUS", "KERNEL ONLINE")

        // 5) Schicht-Start registrieren (BourdainGuard Gen 3)
        kernelQueue.sync { storage["^SYS.SHIFT_START"] = Date() }
        
        // --- DER TRICK FÜR DEN LOG ---
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("iMOPS-KERNEL: Labor-Seed abgeschlossen. Matrix-Score: \(self.meierScore)")
            print("iMOPS-MATRIX: Harrys Belastung erkannt. System bereit für Service-Druck.")
        }
    }
}
