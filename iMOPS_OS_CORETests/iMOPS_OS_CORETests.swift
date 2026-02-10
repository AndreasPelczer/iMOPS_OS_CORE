//
//  iMOPS_OS_CORETests.swift
//  iMOPS_OS_CORETests
//
//  Created by Andreas Pelczer on 18.01.26.
//  Guard-Layer Integrity Tests – Kernel 3.0
//
//  Philosophie: Wenn diese Tests fehlschlagen,
//  ist das System kompromittiert. Kein Deploy.
//

import Testing
import Foundation
@testable import iMOPS_OS_CORE

// ============================================================
// MARK: - SecurityLevel Tests
// ============================================================

struct SecurityLevelTests {

    @Test("SecurityLevel hat genau zwei Cases – nicht mehr, nicht weniger")
    func securityLevelCaseCount() {
        #expect(SecurityLevel.allCases.count == 2,
                "Jemand hat einen dritten SecurityLevel eingebaut. Das ist nicht erlaubt.")
    }

    @Test("De-Eskalation aktiviert den Schutzschild")
    func deEscalationShieldActive() {
        #expect(SecurityLevel.deEscalation.isShieldActive == true)
        #expect(SecurityLevel.standard.isShieldActive == false)
    }

    @Test("SecurityLevel ist Codable – Persistenz muss funktionieren")
    func securityLevelCodable() throws {
        let original = SecurityLevel.deEscalation
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SecurityLevel.self, from: data)
        #expect(decoded == original,
                "SecurityLevel ueberlebt Encode/Decode nicht. Gefahr: Level geht beim Neustart verloren.")
    }
}

// ============================================================
// MARK: - MenschMeierModus Tests (Das Immunsystem)
// ============================================================

struct MenschMeierModusTests {

    // MARK: - Rio-Reiser-Jitter

    @Test("Jitter bleibt im erlaubten Bereich 0.0...1.0")
    func jitterClamping() {
        // Extremwerte: Jitter darf nie unter 0 oder ueber 1 gehen
        for _ in 0..<1000 {
            let jittered0 = MenschMeierModus.applyRioReiserJitter(value: 0.0)
            let jittered1 = MenschMeierModus.applyRioReiserJitter(value: 1.0)
            #expect(jittered0 >= 0.0 && jittered0 <= 1.0,
                    "Jitter hat den Boden durchbrochen: \(jittered0)")
            #expect(jittered1 >= 0.0 && jittered1 <= 1.0,
                    "Jitter hat die Decke durchbrochen: \(jittered1)")
        }
    }

    @Test("Jitter ist nicht deterministisch – Rio Reiser lebt")
    func jitterIsRandom() {
        // 100 Durchlaeufe: Mindestens 2 verschiedene Werte
        let values = (0..<100).map { _ in
            MenschMeierModus.applyRioReiserJitter(value: 0.5)
        }
        let unique = Set(values)
        #expect(unique.count > 1,
                "Jitter liefert immer denselben Wert. Das ist kein Rauschen, das ist Ueberwachung.")
    }

    @Test("Jitter-Amplitude ist maximal 5%")
    func jitterAmplitude() {
        let base = 0.5
        for _ in 0..<1000 {
            let jittered = MenschMeierModus.applyRioReiserJitter(value: base)
            #expect(abs(jittered - base) <= 0.05 + 0.0001, // Float-Toleranz
                    "Jitter ueberschreitet 5%: \(jittered) (Basis: \(base))")
        }
    }

    // MARK: - Anonymisierung (Die Giftpille)

    @Test("Standard-Modus zeigt den echten Namen")
    func standardShowsRealName() {
        let name = MenschMeierModus.anonymizeForAdmin(
            author: "Klaus",
            securityLevel: .standard
        )
        #expect(name == "Klaus")
    }

    @Test("De-Eskalation anonymisiert IMMER zu 'Brigade'")
    func deEscalationAnonymizes() {
        let name = MenschMeierModus.anonymizeForAdmin(
            author: "Klaus",
            securityLevel: .deEscalation
        )
        #expect(name == "Brigade",
                "Die Giftpille ist kaputt. Name '\(name)' ist sichtbar im Guerilla-Modus.")
    }

    @Test("Anonymisierung leakt keinen Teilnamen")
    func noPartialNameLeak() {
        let testNames = ["Andreas", "Maria", "Chef-Spezial", ""]
        for testName in testNames {
            let result = MenschMeierModus.anonymizeForAdmin(
                author: testName,
                securityLevel: .deEscalation
            )
            #expect(!result.contains(testName) || testName.isEmpty,
                    "Name '\(testName)' leakt durch die Anonymisierung: '\(result)'")
        }
    }

    // MARK: - Privacy Shield

    @Test("Privacy Shield triggert bei >50 Abfragen")
    func privacyShieldThreshold() {
        #expect(MenschMeierModus.shouldTriggerPrivacyShield(requestCount: 50) == false,
                "Shield triggert zu frueh (bei genau 50)")
        #expect(MenschMeierModus.shouldTriggerPrivacyShield(requestCount: 51) == true,
                "Shield triggert nicht bei 51 Abfragen. Der Admin kann ungebremst schnueffeln.")
        #expect(MenschMeierModus.shouldTriggerPrivacyShield(requestCount: 0) == false)
    }

    @Test("Allergen-Schritte sind NIEMALS geschuetzt – Menschenleben > Datenschutz")
    func allergenAlwaysTransparent() {
        #expect(MenschMeierModus.isPrivacyShieldActive(priority: "allergen") == false,
                "KRITISCH: Allergen-Schritt wurde vom Privacy Shield versteckt. Das kann toedlich sein.")
    }

    @Test("Routine-Schritte sind geschuetzt")
    func routineIsProtected() {
        #expect(MenschMeierModus.isPrivacyShieldActive(priority: "routine") == true)
        #expect(MenschMeierModus.isPrivacyShieldActive(priority: "normal") == true)
        #expect(MenschMeierModus.isPrivacyShieldActive(priority: "niedrig") == true)
    }
}

// ============================================================
// MARK: - BourdainGuard Tests (Ermuedungsschutz)
// ============================================================

struct BourdainGuardTests {

    // MARK: - Schwellenwerte

    @Test("Unter 8 Stunden: fresh")
    func freshUnder8Hours() {
        let sevenHoursAgo = Date().addingTimeInterval(-7 * 3600)
        let level = BourdainGuard.checkWorkLifeBalance(startTime: sevenHoursAgo)
        #expect(level == .fresh)
    }

    @Test("Ab 8 Stunden: warning")
    func warningAt8Hours() {
        let eightHoursAgo = Date().addingTimeInterval(-8 * 3600)
        let level = BourdainGuard.checkWorkLifeBalance(startTime: eightHoursAgo)
        #expect(level == .warning,
                "8-Stunden-Warnung fehlt. Der Versicherungsschutz ist gefaehrdet.")
    }

    @Test("Ab 10 Stunden: reset – kein Verhandeln")
    func resetAt10Hours() {
        let tenHoursAgo = Date().addingTimeInterval(-10 * 3600)
        let level = BourdainGuard.checkWorkLifeBalance(startTime: tenHoursAgo)
        #expect(level == .reset,
                "10-Stunden-Reset fehlt. 'Ein toter Handwerker haelt keine Versprechen mehr.'")
    }

    @Test("14-Stunden-Schicht ist immer noch reset, nicht irgendwas anderes")
    func extremeHoursStillReset() {
        let fourteenHoursAgo = Date().addingTimeInterval(-14 * 3600)
        let level = BourdainGuard.checkWorkLifeBalance(startTime: fourteenHoursAgo)
        #expect(level == .reset,
                "Bei 14 Stunden wird nicht zurueckgesetzt? Das ist fahrlässig.")
    }

    // MARK: - Trainingsmodus

    @Test("Reset erzwingt Trainingsmodus")
    func resetForcesTraining() {
        #expect(BourdainGuard.FatigueLevel.reset.forceTrainingMode == true,
                "Reset erzwingt keinen Trainingsmodus. Die Sicherheit ist kompromittiert.")
        #expect(BourdainGuard.FatigueLevel.fresh.forceTrainingMode == false)
        #expect(BourdainGuard.FatigueLevel.warning.forceTrainingMode == false)
    }

    // MARK: - Jitter-Staerke eskaliert mit Ermuedung

    @Test("Jitter-Staerke steigt mit Ermuedung")
    func jitterEscalation() {
        let fresh = BourdainGuard.FatigueLevel.fresh.jitterStrength
        let warning = BourdainGuard.FatigueLevel.warning.jitterStrength
        let reset = BourdainGuard.FatigueLevel.reset.jitterStrength

        #expect(fresh < warning,
                "Warning-Jitter (\(warning)) ist nicht staerker als Fresh (\(fresh))")
        #expect(warning < reset,
                "Reset-Jitter (\(reset)) ist nicht staerker als Warning (\(warning))")
    }

    // MARK: - Whisper Messages

    @Test("Fresh hat keine Whisper-Message")
    func freshNoWhisper() {
        #expect(BourdainGuard.getWhisperMessage(for: .fresh) == nil)
    }

    @Test("Warning und Reset haben Whisper-Messages")
    func fatigueHasWhisper() {
        #expect(BourdainGuard.getWhisperMessage(for: .warning) != nil,
                "Keine Warnung bei 8 Stunden? Das System schweigt, wenn es reden muesste.")
        #expect(BourdainGuard.getWhisperMessage(for: .reset) != nil,
                "Keine Nachricht bei 10 Stunden? Bourdain wuerde sich im Grab umdrehen.")
    }

    // MARK: - Task-Validierung

    @Test("validateTaskAction gibt konsistente Werte zurueck")
    func validateTaskActionConsistency() {
        let tenHoursAgo = Date().addingTimeInterval(-10 * 3600)
        let result = BourdainGuard.validateTaskAction(startTime: tenHoursAgo)

        #expect(result.forceTraining == true,
                "10h-Schicht ohne erzwungenen Trainingsmodus.")
        #expect(result.jitterStrength == 0.15,
                "Maximaler Jitter nicht bei 10h-Schicht.")
        #expect(result.whisper != nil,
                "Keine Whisper-Message bei 10h.")
    }
}

// ============================================================
// MARK: - KernelGuards Integrity Tests (Der Orchestrator)
// ============================================================

struct KernelGuardsIntegrityTests {

    // MARK: - Auto-Eskalation

    @Test("Privacy Shield eskaliert SecurityLevel automatisch")
    @available(iOS 17.0, *)
    func privacyShieldAutoEscalation() {
        let report = KernelGuards.evaluate(
            schritte: [],
            securityLevel: .standard,
            sessionStart: Date(),
            adminRequestCount: 100
        )

        #expect(report.securityLevel == .deEscalation,
                "KRITISCH: 100 Admin-Abfragen, aber System bleibt auf Standard. Der Schutz ist aus.")
        #expect(report.privacyShieldActive == true)
    }

    @Test("Normale Nutzung eskaliert NICHT")
    @available(iOS 17.0, *)
    func normalUsageNoEscalation() {
        let report = KernelGuards.evaluate(
            schritte: [],
            securityLevel: .standard,
            sessionStart: Date(),
            adminRequestCount: 10
        )

        #expect(report.securityLevel == .standard,
                "System eskaliert bei normaler Nutzung. Das nervt den Admin und ist kontraproduktiv.")
    }

    // MARK: - Anonymisierung via Report

    @Test("Anonymisierung respektiert den Report")
    @available(iOS 17.0, *)
    func anonymizationFollowsReport() {
        let report = KernelGuards.evaluate(
            schritte: [],
            securityLevel: .standard,
            sessionStart: Date(),
            adminRequestCount: 100
        )

        let name = KernelGuards.anonymize(author: "Klaus", report: report)
        #expect(name == "Brigade",
                "Name leakt trotz aktivem Privacy Shield: '\(name)'")
    }

    // MARK: - Terminal-Status

    @Test("Terminal-Status enthaelt alle relevanten Informationen")
    @available(iOS 17.0, *)
    func terminalStatusComplete() {
        let report = KernelGuards.evaluate(
            schritte: [],
            securityLevel: .deEscalation,
            sessionStart: Date().addingTimeInterval(-10 * 3600),
            adminRequestCount: 100
        )

        let status = report.terminalStatus
        #expect(status.contains("SECURITY:"),  "Security fehlt im Terminal-Status")
        #expect(status.contains("FATIGUE:"),   "Fatigue fehlt im Terminal-Status")
        #expect(status.contains("LOAD:"),      "Load fehlt im Terminal-Status")
        #expect(status.contains("TRAINING:"),  "Training fehlt im Terminal-Status (sollte erzwungen sein)")
        #expect(status.contains("PRIVACY:"),   "Privacy fehlt im Terminal-Status")
    }

    // MARK: - Kombinierte Eskalation (Worst Case)

    @Test("Worst Case: 10h-Schicht + Privacy Shield + De-Eskalation")
    @available(iOS 17.0, *)
    func worstCaseScenario() {
        let report = KernelGuards.evaluate(
            schritte: [],
            securityLevel: .deEscalation,
            sessionStart: Date().addingTimeInterval(-12 * 3600),
            adminRequestCount: 200
        )

        #expect(report.securityLevel == .deEscalation)
        #expect(report.fatigueLevel == .reset)
        #expect(report.forceTrainingMode == true)
        #expect(report.privacyShieldActive == true)
        #expect(report.jitterStrength == 0.15)
        #expect(report.whisperMessage != nil)
    }
}

// ============================================================
// MARK: - Tamper Detection (Integritaetspruefung)
// ============================================================

struct TamperDetectionTests {

    @Test("SecurityLevel kann nicht heimlich erweitert werden")
    func noHiddenSecurityLevels() {
        let allCases = SecurityLevel.allCases
        #expect(allCases.count == 2,
                "SecurityLevel hat \(allCases.count) Cases statt 2. Wurde ein Override eingebaut?")
        #expect(allCases.contains(.standard))
        #expect(allCases.contains(.deEscalation))
    }

    @Test("FatigueLevel kann nicht unterlaufen werden")
    func noHiddenFatigueLevels() {
        let allCases = BourdainGuard.FatigueLevel.allCases
        #expect(allCases.count == 3,
                "FatigueLevel hat \(allCases.count) Cases statt 3. Manipulation?")
    }

    @Test("Jitter kann nicht auf 0 gesetzt werden")
    func jitterNeverZero() {
        for level in BourdainGuard.FatigueLevel.allCases {
            #expect(level.jitterStrength > 0,
                    "Jitter bei \(level.rawValue) ist 0. Die Unschaerfe ist deaktiviert.")
        }
    }

    @Test("Privacy Shield Schwelle ist nicht manipulierbar auf absurde Werte")
    func privacyShieldThresholdSane() {
        #expect(MenschMeierModus.shouldTriggerPrivacyShield(requestCount: 200) == true,
                "Privacy Shield triggert nicht mal bei 200 Abfragen. Schwelle wurde manipuliert.")
        #expect(MenschMeierModus.shouldTriggerPrivacyShield(requestCount: 5) == false,
                "Privacy Shield triggert bei 5 Abfragen. Schwelle ist zu niedrig.")
    }
}
