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
- Immutable HACCP archive ("Tresor")
- Timestamped audit trail with export function
- Responsibility tracking
- Pelczer-Matrix / JOSHUA-Matrix workload scoring (Meier-Score)
- Score history (last 50 data points for load visualization)
- KernelGuards: SecurityLevel escalation, Rio Reiser Jitter, BourdainGuard fatigue protection
- Zero-waste masterstroke system (staff canteen redistribution)
- Rush hour simulation for stress testing
- Minimal UI layer with reactive stress visualization
- Open Source (MIT)

---

## Architecture Overview

### Kernel Layer (`Kernel/`)

| File | Purpose |
|------|---------|
| `TheBrain.swift` | Memory engine (SET / GET / KILL), Pelczer-Matrix (Meier-Score), Score-History |
| `Syntax.swift` | Type-safe DSL paths, BrainNamespace, iMOPS command syntax |
| `TaskRepository.swift` | Task creation, HACCP archiving (immutable vault) |
| `KernelGuards.swift` | SecurityLevel, MenschMeierModus (Rio Reiser Jitter), BourdainGuard (fatigue protection) |
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

## HACCP Vault (Immutable Archive)

When a task is completed, it is:

- timestamped
- assigned to a responsible person
- archived
- locked

This creates traceability, audit safety, legal defensibility, and inspection readiness.

Data is not edited retroactively. History remains history.

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

---

## Requirements

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
