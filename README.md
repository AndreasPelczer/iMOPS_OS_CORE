# iMOPS

**In-Memory Operating Production System**

Ein iOS-Kernel für Produktionsumgebungen. Gebaut für Küchen, nutzbar überall wo Menschen unter Druck arbeiten.

---

## Was ist das?

iMOPS ist ein In-Memory-Datensystem, inspiriert von MUMPS - der Sprache die seit 50 Jahren Krankenhäuser und Banken am Laufen hält. Nur eben für iOS. Und für normale Menschen lesbar.

```swift
// So einfach ist das
iMOPS.SET(.task("001", "TITLE"), "Matjes wässern")
iMOPS.SET(.task("001", "STATUS"), "OPEN")

let title: String? = iMOPS.GET(.task("001", "TITLE"))
```

Kein CoreData. Kein SQL. Kein Backend. Alles im RAM, alles sofort.

---

## Warum?

Ich hab 30 Jahre in Profiküchen gearbeitet. Die Software dort ist Müll. Entweder zu langsam, zu kompliziert, oder offline nicht nutzbar.

iMOPS ist das Gegenteil:
- **Schnell** - Nanosekunden, nicht Millisekunden
- **Offline** - Funktioniert im Keller ohne Netz
- **Einfach** - SET, GET, KILL. Mehr brauchst du nicht.

---

## Die Pelczer-Matrix

Das System misst kognitive Belastung in Echtzeit. Nicht weil Big Brother cool ist, sondern weil müde Menschen Fehler machen.

```
Score 0-40:   Grün.  Alles gut.
Score 40-70:  Orange. Aufpassen.
Score 70+:    Rot.   Jemand braucht Pause.
```

Der Score basiert auf: offene Aufgaben × Gewicht × Zeit. Je länger was offen ist, desto schwerer wiegt es. Wie im echten Leben.

---

## Architektur

```
iMOPS_OS_CORE/
├── Kernel/
│   ├── TheBrain.swift       # Der Kern. In-Memory-Store + Matrix.
│   ├── Syntax.swift         # DSL für typsichere Pfade
│   ├── TaskRepository.swift # HACCP-Logik für Archivierung
│   └── ...
└── TerminalViews/
    ├── HomeMenuView.swift   # Hauptmenü
    ├── CommanderView.swift  # Archiv-Einsicht (HACCP-Tresor)
    └── StaffGridView.swift  # Zero-Waste-Modul
```

**TheBrain** ist der Kernel. Ein Thread-sicherer Dictionary mit reaktiver UI-Anbindung. Jede Änderung triggert die Matrix-Berechnung.

**Namespaces:**
- `^TASK.*` - Aktive Aufgaben
- `^ARCHIVE.*` - Versiegelte Einträge (HACCP-konform, unveränderbar)
- `^BRIGADE.*` - Personal
- `^NAV.*` - Navigation
- `^SYS.*` - Systemstatus

---

## HACCP-Tresor

Wenn eine Aufgabe erledigt wird, wandert sie ins Archiv. Mit Zeitstempel, wer es gemacht hat, welche Allergene relevant waren. Unveränderbar. Revisionssicher.

Das ist keine Überwachung. Das ist Schutz - für den Mitarbeiter der beweisen kann dass er alles richtig gemacht hat.

---

## Bau was du willst

iMOPS ist MIT-lizenziert. Nimm es, fork es, verkauf es. Mir egal.

**Ideen:**
- Wattwanderer-App (Gezeiten + GPS + Sicherheit)
- Lager-Verwaltung
- Event-Catering-Steuerung
- Krankenhaus-Logistik
- Alles wo Menschen unter Zeitdruck Dinge abarbeiten

---

## Anforderungen

- iOS 17+
- Xcode 15+
- Swift 5.9+

---

## Installation

```bash
git clone https://github.com/AndreasPelczer/iMOPS_OS_CORE.git
cd iMOPS_OS_CORE
open iMOPS_OS_CORE.xcodeproj
```

Fertig. Keine Pods, keine Packages, keine Dependencies.

---

## Philosophie

> "Die Suppe lügt nicht."

Code auch nicht. Dieses System zeigt was ist, nicht was sein sollte. Es misst echte Belastung, speichert echte Aktionen, und funktioniert wenn alles andere versagt.

Gebaut für die Leute die den Laden am Laufen halten. Nicht für die die davon reden.

---

## Autor

**Andreas Pelczer**
30 Jahre Küche. Jetzt Code.

[GitHub](https://github.com/AndreasPelczer)

---

*Keine Macht für niemand. Wissen für alle.*
