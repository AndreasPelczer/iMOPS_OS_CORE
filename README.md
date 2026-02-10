# iMOPS – In-Memory Operating Production System

A lightweight, deterministic production kernel for high-stress operational environments.

Originally designed for professional kitchens.
Works everywhere humans operate under pressure.

Built from 36 years of real-world production experience.

---

## Philosophy

Most software is built for offices.

Production environments are different:

- time critical
- noisy
- interrupted constantly
- gloves on, hands wet
- no patience for menus
- no tolerance for crashes

iMOPS does not try to be "feature rich".

It tries to be:

- fast
- predictable
- offline
- robust
- cognitively minimal

**Less UI. More system.**

---

## Core Idea

Instead of databases, ORMs, sync layers and network dependencies,
iMOPS uses a simple **in-memory kernel** inspired by classic systems like MUMPS:

`SET / GET / KILL`

Everything is:

- deterministic
- hierarchical
- instantly accessible
- offline-first

Think: Redis mindset + HACCP logic + production reality — inside a native iOS app.

---

## What problems does it solve?

In real production:

- tasks get lost
- documentation is forgotten
- HACCP logs are incomplete
- overload causes errors
- people improvise instead of following process

iMOPS provides:

- structured tasks
- immutable completion logs
- traceable responsibility
- simple state machine
- stress/load visibility
- zero network dependency

**Goal: Make correct behavior the easiest behavior.**

---

## Features

- In-memory kernel (no CoreData / SQL required)
- Deterministic SET / GET / KILL data model with type-safe DSL
- Offline-first architecture
- Typed task model (`KernelArbeitsschritt`) with 4-stage lifecycle
- Immutable HACCP archive ("Tresor") with Commander sign-off
- Timestamped audit trail with export function
- Responsibility tracking
- Pelczer-Matrix / JOSHUA-Matrix workload scoring (Meier-Score)
- Score history (last 50 data points for load visualization)
- **KernelGuards (Gen 3 Protection Stack):**
  - `SecurityLevel` – Ethical status with auto-escalation
  - `MenschMeierModus` – Rio Reiser Jitter (anti-tracking noise), anonymization ("Brigade" poison pill), Privacy Shield (anti-abuse detection)
  - `BourdainGuard` – Fatigue protection (8h warning, 10h reset), whisper messages, forced training mode
  - `KernelGuards` orchestrator – Single entry-point combining all guards into a `GuardReport`
- Guard integrity test suite (tamper detection, threshold validation, jitter verification)
- Zero-waste masterstroke system (staff canteen redistribution)
- Rush hour simulation for stress testing
- Minimal UI layer with reactive stress visualization
- Open Source (MIT)

---

## Architecture Overview

### Kernel Layer (`Kernel/`)

| File | Purpose |
|------|---------|
| `TheBrain.swift` | Memory engine (SET / GET / KILL), Pelczer-Matrix (Meier-Score), Score-History, BourdainGuard integration |
| `Syntax.swift` | Type-safe DSL paths, BrainNamespace, iMOPS command syntax |
| `KernelArbeitsschritt.swift` | Typed task model bridging `[String: Any]` storage to `KernelArbeitsschritt` structs |
| `TaskRepository.swift` | Task creation, 4-stage lifecycle transitions, HACCP archiving (immutable vault) |
| `KernelGuards.swift` | SecurityLevel, MenschMeierModus, BourdainGuard, GuardReport, KernelGuards orchestrator |
| `RootTerminalView.swift` | State-machine router based on `^NAV.LOCATION` |
| `ProductionTaskView.swift` | Active task display with stress visualization |
| `iMOPS_OS_COREApp.swift` | App entry point (kernel bootloader) |

### UI Layer (`TerminalViews/`)

| File | Purpose |
|------|---------|
| `HomeMenuView.swift` | Main menu, matrix display, stress pulse animation |
| `CommanderView.swift` | HACCP archive viewer, audit trail export, killswitch |
| `StaffGridView.swift` | Zero-waste masterstroke system, staff coordination |

### Data Flow

```
User Input → RootTerminalView (Router) → Brain.set() → Pelczer-Matrix calculation
                                                      ↓
                              archiveUpdateTrigger (SwiftUI refresh)
```

### Kernel Namespaces

| Prefix | Purpose |
|--------|---------|
| `^NAV` | Navigation state |
| `^SYS` | System status |
| `^TASK` | Active tasks |
| `^ARCHIVE` | Completed, locked tasks (immutable HACCP vault) |
| `^BRIGADE` | Staff information |

No backend required. No cloud required. System continues working even without internet.

---

## Example

```swift
// Direct kernel access (all paths require ^ prefix)
let brain = TheBrain.shared
brain.set("^TASK.042.TITLE", "Cool soup")
brain.set("^TASK.042.WEIGHT", 10)
brain.set("^TASK.042.STATUS", "OPEN")

let title: String? = brain.get("^TASK.042.TITLE")

// Or via type-safe DSL (recommended)
iMOPS.SET(.task("042", "TITLE"), "Cool soup")
iMOPS.SET(.task("042", "WEIGHT"), 10)
iMOPS.SET(.task("042", "STATUS"), "OPEN")

let title: String? = iMOPS.GET(.task("042", "TITLE"))
```

Direct. Predictable. No hidden layers.

---

## Task Lifecycle (KernelArbeitsschritt)

Every task in iMOPS follows a strict 4-stage lifecycle:

```
offen → inArbeit → erledigt → abgenommen
```

| Stage | Storage Value | Meaning |
|-------|--------------|---------|
| `offen` | `OPEN` | Created, waiting for assignment |
| `inArbeit` | `IN_ARBEIT` | Claimed by a brigade member |
| `erledigt` | `ERLEDIGT` | Completed, sealed in HACCP archive |
| `abgenommen` | `ABGENOMMEN` | Commander sign-off (final stamp) |

Tasks are bridged from the raw `[String: Any]` kernel storage to typed `KernelArbeitsschritt` structs via `fromStorage(id:storage:)`. This gives downstream projects type safety without replacing the MUMPS-style storage model.

```swift
// Typed task from raw storage
let schritte = TheBrain.shared.getArbeitsschritte()
let active = schritte.filter { $0.status.isActiveLoad }

// Status transition with validation
TaskRepository.transitionTask(id: "001", to: .inArbeit)
TaskRepository.transitionTask(id: "001", to: .erledigt) // → HACCP sealed
```

Only valid transitions are allowed. Invalid transitions are rejected with a kernel error.

---

## HACCP Vault (Immutable Archive)

When a task is completed, it is:

- timestamped (hour window, not milliseconds)
- assigned by **role** (e.g. "Gardemanger"), not by personal name
- archived with medical/SOP snapshots
- locked (KILLTREE removes the active task)
- optionally signed off by the Commander (`.abgenommen`)

This creates traceability, audit safety, legal defensibility, and inspection readiness.

Data is not edited retroactively. History remains history.

### DSGVO / Privacy by Design (Art. 25 DSGVO)

The archive stores **functional data**, not personal data:

| Stored | Not Stored | Reason |
|--------|------------|--------|
| `ROLE: "Gardemanger"` | ~~`USER: "Harry Meier"`~~ | Roles are not personal data (Art. 5 Abs. 1 lit. c) |
| `TIME: "14:00-14:59"` | ~~`TIME: "14:23:07.442"`~~ | Hour windows prevent performance profiling |
| `TITLE`, `SOP`, `MEDICAL` | — | Required for HACCP compliance |

The export function (`exportLog()`) applies KernelGuards **before** data leaves the system. In de-escalation mode, even role assignments are anonymized to "Brigade".

**Principle:** Protection applies at the point of storage AND at the point of export. No backdoors.

---

## KernelGuards (Gen 3 Protection Stack)

The guard system protects individuals from micro-tracking, fatigue, and management abuse. Anyone who forks iMOPS_OS_CORE inherits the complete protection stack.

### SecurityLevel

Two levels. No more, no less.

| Level | Meaning |
|-------|---------|
| `.standard` | Normal operation, names visible |
| `.deEscalation` | Guerrilla mode, names anonymized to "Brigade" |

SecurityLevel is `Codable` and `CaseIterable`. The test suite verifies that no third level can be added.

### MenschMeierModus (The Immune System)

Three protection mechanisms:

**1. Rio Reiser Jitter** – Every aggregated value gets +/- 5% random noise. Nobody gets reduced to a number. The jitter is:
- clamped to 0.0...1.0
- non-deterministic (verified over 1000 iterations in tests)
- amplitude-limited to exactly 5%

**2. Anonymization (The Poison Pill)** – In de-escalation mode, all author names are replaced with "Brigade". No partial name leaks.

**3. Privacy Shield (Anti-Abuse)** – If more than 50 detail queries arrive in a session, the system auto-escalates to de-escalation mode. Exception: Allergen steps are ALWAYS transparent (human life > data privacy).

### BourdainGuard (Fatigue Protection)

*"A dead craftsman keeps no promises."*

| Hours | Level | Effect |
|-------|-------|--------|
| < 8h | `.fresh` | Normal operation |
| >= 8h | `.warning` | Insurance warning, +15% matrix load, whisper message |
| >= 10h | `.reset` | Forced training mode, +30% matrix load, maximum jitter |

Jitter strength escalates with fatigue: 0.05 (fresh) → 0.10 (warning) → 0.15 (reset).

Whisper messages are gentle nudges, not commands. They appear in the kernel log.

### KernelGuards Orchestrator

Single entry-point that combines all guards:

```swift
let report = KernelGuards.evaluate(
    schritte: brain.getArbeitsschritte(),
    securityLevel: .standard,
    sessionStart: shiftStart,
    adminRequestCount: requestCount
)

// report.securityLevel      → may auto-escalate
// report.fatigueLevel       → .fresh / .warning / .reset
// report.brigadeLoad        → 0.0...1.0 (with jitter)
// report.forceTrainingMode  → true if 10h+ shift
// report.privacyShieldActive → true if >50 queries
// report.jitterStrength     → fatigue-scaled noise
// report.whisperMessage     → optional gentle warning
// report.terminalStatus     → "SECURITY: ... | FATIGUE: ... | LOAD: ..."
```

---

## Guard Integrity Tests

The test suite (`iMOPS_OS_CORETests.swift`) uses the Swift Testing framework and acts as a tamper detection system. If these tests fail, the system is considered compromised. No deploy.

**What the tests verify:**

| Category | Tests |
|----------|-------|
| SecurityLevel | Exactly 2 cases, Codable roundtrip, shield activation |
| Rio Reiser Jitter | Clamping (1000 iterations), randomness, amplitude <= 5% |
| Anonymization | Standard shows real name, de-escalation always returns "Brigade", no partial leaks |
| Privacy Shield | Threshold at >50 queries, allergen always transparent, routine protected |
| BourdainGuard | 8h/10h thresholds, training mode enforcement, jitter escalation, whisper messages |
| KernelGuards | Auto-escalation at 100 queries, no escalation at 10, anonymization follows report |
| Terminal Status | Contains SECURITY, FATIGUE, LOAD, TRAINING, PRIVACY fields |
| Worst Case | 12h shift + 200 queries + de-escalation: all guards fire simultaneously |
| Tamper Detection | No hidden SecurityLevels, no hidden FatigueLevels, jitter never zero, sane thresholds |

---

## JOSHUA-Matrix / Pelczer-Matrix (Workload Score)

Production errors rarely come from bad intentions. They come from overload.

The matrix estimates stress level (Meier-Score, 0–100) based on:

- active tasks (weighted by individual task WEIGHT)
- fatigue factor (time pressure: +10% load per hour of oldest open task)
- staff capacity (brigade size: each member carries ~20 units)
- jitter protection (random noise at critical levels > 80 to prevent individual tracking)

The score drives real-time UI changes:

| Score | State | Visual |
|-------|-------|--------|
| 0–40 | Stable | Green indicators |
| 40–70 | Warning | Orange indicators |
| 70–100 | Critical | Red pulse, stress background, alarm quotes |

Result: A simple score that indicates risk of failure.

**Purpose: Prevent collapse before it happens.**

---

## Scientific / Validation Context

iMOPS is designed as a **systemic intervention tool**, not just task software.

It enables measurable evaluation of:

- task completion time
- error rates
- documentation completeness
- workload vs. mistakes
- compliance stability
- operator stress indicators

Possible study designs:

- before/after comparison
- pilot kitchen vs. control group
- HACCP documentation quality analysis
- workload correlation studies

The kernel is intentionally simple and transparent to support reproducibility and research.

---

## What iMOPS is NOT

- not employee surveillance
- not behavior scoring
- not cloud analytics
- not a management spying tool
- not an ERP

It is a **local operational aid**. It supports people. It does not monitor them.

This is not a claim — it is enforced by code:

- No personal names in the HACCP archive (roles only)
- No millisecond timestamps (hour windows only)
- Jitter prevents individual tracking on aggregated scores
- Privacy Shield auto-escalates when abuse patterns emerge
- Export applies the same guards as the live system
- Guard integrity tests prevent silent removal of protections

---

## Requirements

- iOS 17+
- Xcode 16+
- Swift 5.9+
- Swift Testing framework (for guard integrity tests)

---

## Installation

```bash
git clone https://github.com/AndreasPelczer/iMOPS_OS_CORE.git
cd iMOPS_OS_CORE
open iMOPS_OS_CORE.xcodeproj
```

No server setup required. No pods, no packages, no dependencies.

---

## Use Cases

Originally built for:

- professional kitchens
- food production
- HACCP environments

Also suitable for:

- labs
- workshops
- small manufacturing
- field operations
- anywhere offline reliability matters

---

## Design Principles

- offline first
- deterministic behavior
- low cognitive load
- minimal dependencies
- transparent logic
- small codebase
- understandable by humans

If you need a manual, it's already too complex.

---

## The Book

> **Thermodynamik der Arbeit – Warum Systeme kollabieren**
> *(Thermodynamics of Work – Why Systems Collapse)*

The theoretical foundation behind iMOPS. No motivation, no morals – just structure.

[Available on Amazon](https://www.amazon.de/dp/B0GK95MWB5)

---

## License

MIT

Use it. Fork it. Build your own system on top.

---

## Author

**Andreas Pelczer**
System Architect · Production Systems Specialist · Author

36 years of professional kitchen and production management experience.
Published: *Thermodynamik der Arbeit – Warum Systeme kollabieren* (2025).
Founder of Dead Rabbit Productions.

Interested in academic collaboration for methodology validation.

[GitHub](https://github.com/AndreasPelczer)
