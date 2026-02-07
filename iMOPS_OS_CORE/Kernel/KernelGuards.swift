//
//  KernelGuards.swift
//  iMOPS_OS_CORE
//
//  KERNEL_26 // OMNI_GRID
//  NO SQL // NO LATENCY // NO POWER FOR NOBODY
//
//  Fehlende Kern-Elemente der Philosophie:
//  - SecurityLevel (Eskalationsstufen)
//  - MenschMeierModus (Rio Reiser Prinzip)
//  - BourdainGuard (Altgesellen-Schutz)
//

import Foundation

// MARK: - SecurityLevel

/// Eskalationsstufen im Kernel.
/// Bestimmt, wie das System mit Identität und Sichtbarkeit umgeht.
enum SecurityLevel {
    /// Normalbetrieb — volle Transparenz
    case normal
    /// De-Eskalation — Individuum verschwindet hinter der Brigade
    case deEscalation
    /// Guerilla — maximale Unschärfe, minimale Angriffsfläche
    case guerilla
}

// MARK: - MenschMeierModus (Rio Reiser Prinzip)

/// Schutz vor Mikromanagement durch gezielte Unschärfe.
/// "Alles was ich will, ist meine Ruhe haben."
struct MenschMeierModus {

    /// Rio-Reiser-Jitter: +/- 5% Rauschen gegen die Stoppuhr.
    /// Verhindert exaktes Tracking individueller Leistung.
    static func applyRioReiserJitter(value: Double) -> Double {
        let jitter = Double.random(in: -0.05...0.05)
        return min(max(value + jitter, 0.0), 1.0)
    }

    /// Im Guerilla-Modus verschwindet der Einzelne hinter der Brigade.
    /// Bei De-Eskalation wird der Autor anonymisiert.
    static func anonymizeForAdmin(author: String, security: SecurityLevel) -> String {
        return security == .deEscalation ? "Brigade" : author
    }
}

// MARK: - BourdainGuard (Der Altgesellen-Schutz)

/// "Ein toter Handwerker hält keine Versprechen mehr."
/// Schützt die Brigade vor Überarbeitung durch klare Stufenlogik.
struct BourdainGuard {

    /// Ermüdungsstufen nach dem Altgesellen-Prinzip.
    enum FatigueLevel {
        /// Unter 8h — alles im grünen Bereich
        case fresh
        /// 8-10h — Hinweis auf Versicherungsschutz und nachlassende Präzision
        case warning
        /// Ab 10h — Erzwungene Pause / Ausbildungsmodus
        case reset
    }

    /// Prüft die Work-Life-Balance anhand der Schichtdauer.
    /// - Parameter start: Schichtbeginn
    /// - Returns: Aktuelle Ermüdungsstufe
    static func checkWorkLifeBalance(start: Date) -> FatigueLevel {
        let hours = Date().timeIntervalSince(start) / 3600
        if hours >= 10 { return .reset }
        if hours >= 8  { return .warning }
        return .fresh
    }
}
