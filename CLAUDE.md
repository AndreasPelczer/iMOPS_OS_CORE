# CLAUDE.md – iMOPS_OS_CORE Projekt-Anweisungen

## Was ist dieses Projekt?

iMOPS_OS_CORE ist der **Open-Source-Referenz-Prototyp** fuer Mitarbeitersoftware
in Produktionsumgebungen (Kuechen, HACCP, Fertigung). Wer dieses Repo forkt,
erbt den kompletten Schutz-Stack. Der Code IST die Dokumentation.

## Architektur (nicht aendern)

- **TheBrain.swift** – In-Memory-Kernel mit `[String: Any]` Storage (MUMPS-Stil).
  SET / GET / KILL. Serial `kernelQueue` fuer Thread-Safety. `@Observable` fuer SwiftUI.
- **Syntax.swift** – Type-safe DSL (`iMOPS.SET(.task(...))`)
- **KernelArbeitsschritt.swift** – Typisiertes Task-Model. Bridge von `[String: Any]` zu Struct.
- **TaskRepository.swift** – 4-Stufen-Lebenszyklus: `offen → inArbeit → erledigt → abgenommen`
- **KernelGuards.swift** – Konsolidierter Gen 3 Schutz-Stack (siehe unten)
- **RootTerminalView.swift** – Router basierend auf `^NAV.LOCATION`

## KernelGuards – Was existiert und wie es funktioniert

Alles in einer Datei: `KernelGuards.swift`

### SecurityLevel
- Genau 2 Stufen: `.standard` und `.deEscalation`
- KEINE dritte Stufe einfuehren (Tests pruefen das)
- `Codable`, `CaseIterable`

### MenschMeierModus
- `calculateBrigadeLoad(from: [KernelArbeitsschritt])` → 0.0...1.0 mit Jitter
- `applyRioReiserJitter(value:)` → +/- 5% Rauschen, geclamped auf 0.0...1.0
- `anonymizeForAdmin(author:, securityLevel:)` → "Brigade" bei deEscalation
- `shouldTriggerPrivacyShield(requestCount:)` → true wenn > 50
- `isPrivacyShieldActive(priority:)` → false fuer "allergen" (immer transparent)

### BourdainGuard
- `checkWorkLifeBalance(startTime:)` → `.fresh` / `.warning` (8h) / `.reset` (10h)
- `validateTaskAction(startTime:)` → Tuple mit forceTraining, jitterStrength, whisper
- `getWhisperMessage(for:)` → Sanfte Warnung oder nil
- FatigueLevel hat: `sfSymbol`, `forceTrainingMode`, `jitterStrength`

### KernelGuards Orchestrator
- `evaluate(schritte:, securityLevel:, sessionStart:, adminRequestCount:)` → `GuardReport`
- `anonymize(author:, report:)` → Wendet Report-Level auf Namen an

### GuardReport (Ergebnis)
- `securityLevel`, `fatigueLevel`, `brigadeLoad`, `forceTrainingMode`
- `privacyShieldActive`, `jitterStrength`, `whisperMessage`
- `terminalStatus` → Formatierter String fuer UI

## Was bereits integriert ist

- BourdainGuard in `refreshMeierScore()` (TheBrain.swift): Fatigue-skalierter Jitter,
  Load-Multiplikator (+15%/+30%), Whisper Messages im Kernel-Log
- Schicht-Start in `seed()` registriert (`^SYS.SHIFT_START`)
- HACCP-Archiv: Rolle statt Name, Stundenfenster statt Millisekunden (DSGVO-konform)
- Export: Guards werden vor Ausgabe angewendet (alle drei Formate)
- **ExportView** (CommanderView.swift): Tagesbericht (Text), Audit CSV, Journal JSON
  mit SHA-256 Versiegelung. Import CryptoKit. NICHT AENDERN.
- `exportLog()`, `exportCSV()`, `exportJSON()` in TheBrain.swift:
  Alle drei wenden DSGVO-Guards an (PrivacyShield + SecurityLevel).
  `prepareExport()` ist die gemeinsame Guard-Vorbereitung. NICHT AENDERN.
- `ArchiveRow` liest `^ARCHIVE.*.ROLE` (nicht USER). NICHT AENDERN.

## DEIN AUFTRAG: Guards in die UI verdrahten

`KernelGuards.evaluate()` wird derzeit nirgends im App-Flow aufgerufen.
Die Guards existieren, sind getestet, aber die UI reagiert nicht darauf.

### Was du tun sollst:

1. **GuardReport beim View-Load abrufen**
   - In `RootTerminalView` oder den einzelnen Views: beim Erscheinen
     `KernelGuards.evaluate()` aufrufen
   - Das Ergebnis (`GuardReport`) fuer UI-Entscheidungen verwenden
   - Schicht-Start aus `^SYS.SHIFT_START` lesen

2. **SecurityLevel in der UI anzeigen**
   - `report.securityLevel.sfSymbol` und `report.securityLevel.displayName`
     sichtbar machen (z.B. in der HomeMenuView oder als Status-Zeile)

3. **BourdainGuard Whisper in der UI anzeigen**
   - Wenn `report.whisperMessage != nil`: sanfte Anzeige (kein Alert, kein Popup)
   - Vorschlag: dezenter Text am unteren Bildschirmrand oder im Terminal-Stil
   - Whisper ist eine Empfehlung, kein Befehl

4. **Privacy Shield Status anzeigen**
   - Wenn `report.privacyShieldActive`: visueller Hinweis (z.B. Shield-Icon)

5. **Training Mode anzeigen**
   - Wenn `report.forceTrainingMode`: UI-Hinweis dass Praezisionsmodus aktiv ist

6. **Export: SecurityLevel + adminRequestCount durchreichen**
   - Die ExportView ruft `brain.exportLog()`, `brain.exportCSV()`,
     `brain.exportJSON()` bereits korrekt auf (Default-Parameter).
   - OPTIONAL: Wenn du einen adminRequestCount-Zaehler einfuehrst,
     diesen an die Export-Methoden weitergeben.

### Was du NICHT tun darfst:

- **KEIN Hard-Lock bei meierScore > 80.** Der Jitter kann den Score ueber 80
  schieben und eine Sekunde spaeter wieder darunter. Eine Sperre wuerde
  flackern wie eine Tuer im Durchzug. Das Ampelsystem (gruen/orange/rot)
  ist die richtige Eskalation — warnen, nicht blockieren.

- **KEINE neue Authentifizierung erfinden.** Der Killswitch in der CommanderView
  kann sinnvoll gemacht werden, aber nicht als Login-System. iMOPS ist offline-first
  und hat keine User-Datenbank.

- **KEINE personenbezogenen Daten in neue Logs schreiben.** Das Archiv speichert
  bewusst nur Rollen, keine Namen. Das ist DSGVO-Pflicht, nicht optional.

- **KEINE neuen Dateien erstellen** ohne Grund. Aenderungen in bestehende Dateien
  integrieren. Das Projekt nutzt PBXFileSystemSynchronizedRootGroup (Xcode 16),
  neue .swift Dateien werden automatisch erkannt.

- **KEINEN bestehenden Guard-Code aendern.** Die Guard-Logik in KernelGuards.swift
  ist getestet und juristisch geprueft. Nur die UI-Anbindung ist dein Job.

- **ExportView, exportLog/CSV/JSON, ArchiveRow NICHT aendern.**
  Der Export ist fertig: 3 Formate, SHA-256, DSGVO-Guards. Finger weg.

- **KEINE Millisekunden-Zeitstempel einfuehren.** Archiv nutzt Stundenfenster
  ("14:00-14:59"). Das ist DSGVO Art. 5 Abs. 1 lit. c (Datenminimierung).

- **KEINE Namen in Archiv oder Export schreiben.** Nur Rollen (Gardemanger, Runner).
  Das Archiv-Feld heisst `ROLE`, nicht `USER`.

## Regeln

- Swift, SwiftUI, iOS 17+, @Observable
- Kein CoreData, kein CloudKit, kein Network-Layer
- Deutsch im Code (Variablen, Kommentare), Englisch in der README
- Frag IMMER bevor du codest. Beschreib was du vorhast und warte auf "ja".
- Tests: Swift Testing Framework (@Test, #expect), NICHT XCTest
