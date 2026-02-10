//
//  KernelGuards.swift
//  iMOPS_OS_CORE
//
//  Kernel 3.0 Guard System (konsolidiert)
//  Quellen:
//  - Gen 1: IMops_alt/KERNEL/AppEnums.swift (SecurityLevel)
//  - Gen 1: IMops_alt/DATABASE/MenschMeierModus.swift (Anonymisierung, PrivacyShield)
//  - Gen 2: Gastro_GRID-Omni/Kernel/MenschMeierModus.swift (Jitter, Brigade-Load)
//  - Gen 2: Gastro_GRID-Omni/Kernel/BourdainGuard.swift (Ermuedung)
//  - Gen 3: KernelGuards.swift (Orchestrator) - NEU
//
//  Adaptiert fuer iMOPS_OS_CORE: TheBrain statt KernelArbeitsschritt
//

import Foundation

// ============================================================
// MARK: - SecurityLevel (Gen 3)
// Der ethische Status des Systems (Mensch-Meier-Layer)
// ============================================================

enum SecurityLevel: String, Codable, CaseIterable {
    case standard       // Normalbetrieb: Namen sichtbar
    case deEscalation   // Guerilla-Modus: Namen anonymisiert

    var displayName: String {
        switch self {
        case .standard:     return "Standard"
        case .deEscalation: return "De-Eskalation (Guerilla)"
        }
    }

    var sfSymbol: String {
        switch self {
        case .standard:     return "shield"
        case .deEscalation: return "shield.fill"
        }
    }

    /// Ist der Schutzschild aktiv?
    var isShieldActive: Bool {
        self == .deEscalation
    }
}

// ============================================================
// MARK: - MenschMeierModus (Gen 3)
// Das Immunsystem: Schuetzt Individuen vor Mikro-Tracking.
// Konsolidiert aus Gen 1 (Anonymisierung, PrivacyShield)
// + Gen 2 (Jitter, Brigade-Load)
// ============================================================

struct MenschMeierModus {

    // MARK: Rio-Reiser-Prinzip (Jitter)

    /// Berechnet die aggregierte Brigade-Last mit +/- 5% Rauschen.
    /// Adaptiert fuer TheBrain: arbeitet mit Task-Zaehlung statt KernelArbeitsschritt.
    ///
    /// - Parameters:
    ///   - openCount: Anzahl offener Tasks
    ///   - totalCount: Gesamtzahl aller Tasks (offen + archiviert)
    /// - Returns: Belastungswert 0.0 ... 1.0 (mit Jitter)
    static func calculateBrigadeLoad(openCount: Int, totalCount: Int) -> Double {
        guard totalCount > 0 else { return 0.0 }
        let rawLoad = Double(openCount) / Double(totalCount)
        return applyRioReiserJitter(value: rawLoad)
    }

    /// Das Rio-Reiser-Prinzip: +/- 5% Unschaerfe auf jeden Einzelwert.
    /// Damit der Admin keine Mikrosekunden zaehlt.
    ///
    /// - Parameter value: Rohwert (0.0 ... 1.0)
    /// - Returns: Wert mit Rauschen, geclamped auf 0.0 ... 1.0
    static func applyRioReiserJitter(value: Double) -> Double {
        let noise = Double.random(in: -0.05...0.05)
        return min(max(value + noise, 0.0), 1.0)
    }

    // MARK: Anonymisierung (aus Gen 1)

    /// Die "Giftpille": Anonymisiert den Autorennamen.
    /// Im Normalbetrieb: Name sichtbar.
    /// Bei De-Eskalation: Name wird durch "Brigade" ersetzt.
    static func anonymizeForAdmin(author: String, securityLevel: SecurityLevel) -> String {
        switch securityLevel {
        case .standard:
            return author
        case .deEscalation:
            return "Brigade"
        }
    }

    // MARK: Privacy Shield (Anti-Missbrauch, aus Gen 1)

    /// Prueft auf Management-Missbrauch.
    /// Wenn zu viele Detail-Abfragen in zu kurzer Zeit kommen,
    /// schaltet das System auf "Unschaerfe".
    static func shouldTriggerPrivacyShield(requestCount: Int) -> Bool {
        return requestCount > 50
    }

    /// Bestimmt ob ein Arbeitsschritt ethisch geschuetzt ist.
    /// Kritische Schritte (Allergen) sind IMMER transparent.
    /// Routine-Schritte werden bei Stress geschuetzt.
    static func isPrivacyShieldActive(priority: String) -> Bool {
        return priority != "allergen"
    }
}

// ============================================================
// MARK: - BourdainGuard (Gen 3)
// Schuetzt die Brigade vor Ermuedung und Ueberarbeitung.
// "Ein toter Handwerker haelt keine Versprechen mehr."
// ============================================================

struct BourdainGuard {

    // MARK: FatigueLevel

    enum FatigueLevel: String, CaseIterable {
        case fresh      // Alles im gruenen Bereich
        case warning    // 8 Stunden erreicht (Versicherungsschutz-Gefahr)
        case reset      // 10 Stunden erreicht (Ausbildungsmodus startet)

        var sfSymbol: String {
            switch self {
            case .fresh:   return "heart.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .reset:   return "bolt.heart.fill"
            }
        }

        /// Soll der Trainingsmodus erzwungen werden?
        var forceTrainingMode: Bool {
            self == .reset
        }

        /// Empfohlene Jitter-Staerke (hoeher = mehr Schutz)
        var jitterStrength: Double {
            switch self {
            case .fresh:   return 0.05
            case .warning: return 0.10
            case .reset:   return 0.15
            }
        }
    }

    // MARK: Ermuedungs-Check

    /// Ermittelt das aktuelle Ermuedungs-Level basierend auf der Startzeit.
    static func checkWorkLifeBalance(startTime: Date) -> FatigueLevel {
        let hours = Date().timeIntervalSince(startTime) / 3600
        if hours >= 10 { return .reset }
        if hours >= 8  { return .warning }
        return .fresh
    }

    // MARK: Whisper Messages

    /// Die fluesternde Nachricht fuer den Menschen.
    /// Kein Befehl, sondern ein Anstoss zum Nachdenken.
    static func getWhisperMessage(for level: FatigueLevel) -> String? {
        switch level {
        case .fresh:
            return nil
        case .warning:
            return "Meister, 8 Stunden sind rum. " +
                   "Der Koerper ist kein Algorithmus. " +
                   "Denk an deinen Versicherungsschutz."
        case .reset:
            return "10 Stunden. Ein toter Handwerker haelt " +
                   "keine Versprechen mehr. Wir schalten " +
                   "zurueck auf Anfang - Praezision vor Speed."
        }
    }

    // MARK: Terminal Status

    /// Der technische Status-String fuer das iMOPS-Terminal.
    static func getStatusString(startTime: Date) -> String {
        let level = checkWorkLifeBalance(startTime: startTime)
        switch level {
        case .fresh:   return "MODUS: FRESH"
        case .warning: return "MODUS: MEIER (Achtung Versicherung)"
        case .reset:   return "MODUS: BOURDAIN (Praezision erzwungen)"
        }
    }

    // MARK: Task-Validierung (aus Gen 2 TaskRepository)

    /// Validiert eine Task-Aktion unter Beruecksichtigung der Ermuedung.
    static func validateTaskAction(startTime: Date)
        -> (forceTraining: Bool, jitterStrength: Double, whisper: String?) {
        let level = checkWorkLifeBalance(startTime: startTime)
        return (
            forceTraining: level.forceTrainingMode,
            jitterStrength: level.jitterStrength,
            whisper: getWhisperMessage(for: level)
        )
    }
}

// ============================================================
// MARK: - GuardReport (Gen 3 - NEU)
// Ergebnis einer Guard-Auswertung.
// ============================================================

struct GuardReport {
    let securityLevel: SecurityLevel
    let fatigueLevel: BourdainGuard.FatigueLevel
    let brigadeLoad: Double
    let forceTrainingMode: Bool
    let privacyShieldActive: Bool
    let jitterStrength: Double
    let whisperMessage: String?

    /// Kurzstatus fuer das Terminal
    var terminalStatus: String {
        var parts: [String] = []
        parts.append("SECURITY: \(securityLevel.displayName)")
        parts.append("FATIGUE: \(fatigueLevel.rawValue.uppercased())")
        parts.append("LOAD: \(Int(brigadeLoad * 100))%")
        if forceTrainingMode { parts.append("TRAINING: ERZWUNGEN") }
        if privacyShieldActive { parts.append("PRIVACY: SHIELD AKTIV") }
        return parts.joined(separator: " | ")
    }
}

// ============================================================
// MARK: - KernelGuards Orchestrator (Gen 3 - NEU)
// Kombiniert alle Guards zu einem einzigen Entry-Point.
// Adaptiert fuer iMOPS_OS_CORE: TheBrain statt KernelArbeitsschritt
// ============================================================

struct KernelGuards {

    /// Fuehrt alle Guards aus und erstellt einen Report.
    /// Adaptiert: Nutzt openTaskCount/totalTaskCount statt KernelArbeitsschritt-Array.
    ///
    /// - Parameters:
    ///   - openTaskCount: Anzahl offener Tasks im Kernel
    ///   - totalTaskCount: Gesamtzahl Tasks (offen + archiviert)
    ///   - securityLevel: Aktueller SecurityLevel
    ///   - sessionStart: Schicht-Beginn (fuer BourdainGuard)
    ///   - adminRequestCount: Anzahl Admin-Abfragen (fuer PrivacyShield)
    /// - Returns: GuardReport mit allen Empfehlungen
    static func evaluate(
        openTaskCount: Int,
        totalTaskCount: Int,
        securityLevel: SecurityLevel,
        sessionStart: Date,
        adminRequestCount: Int = 0
    ) -> GuardReport {

        // 1. MenschMeierModus: Brigade-Last berechnen
        let load = MenschMeierModus.calculateBrigadeLoad(
            openCount: openTaskCount,
            totalCount: totalTaskCount
        )

        // 2. BourdainGuard: Ermuedung pruefen
        let fatigue = BourdainGuard.checkWorkLifeBalance(startTime: sessionStart)
        let taskValidation = BourdainGuard.validateTaskAction(startTime: sessionStart)

        // 3. PrivacyShield: Missbrauch erkennen
        let privacyShield = MenschMeierModus.shouldTriggerPrivacyShield(
            requestCount: adminRequestCount
        )

        // 4. SecurityLevel eskalieren wenn noetig
        var effectiveLevel = securityLevel
        if privacyShield && securityLevel == .standard {
            effectiveLevel = .deEscalation
        }

        return GuardReport(
            securityLevel: effectiveLevel,
            fatigueLevel: fatigue,
            brigadeLoad: load,
            forceTrainingMode: taskValidation.forceTraining,
            privacyShieldActive: privacyShield,
            jitterStrength: taskValidation.jitterStrength,
            whisperMessage: taskValidation.whisper
        )
    }

    /// Anonymisiert einen Autorennamen basierend auf dem aktuellen Report.
    static func anonymize(author: String, report: GuardReport) -> String {
        return MenschMeierModus.anonymizeForAdmin(
            author: author,
            securityLevel: report.securityLevel
        )
    }
}
