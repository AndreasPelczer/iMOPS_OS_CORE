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
- Deterministic SET / GET data model
- Offline-first architecture
- Immutable HACCP archive ("Tresor")
- Timestamped audit trail
- Responsibility tracking
- JOSHUA-Matrix workload scoring
- Minimal UI layer
- Open Source (MIT)

---

## Architecture Overview

Kernel structure:

- `TheBrain.swift` → memory engine (SET / GET / KILL)
- `Syntax.swift` → hierarchical key logic
- `TaskRepository.swift` → task abstraction
- `HACCPVault.swift` → immutable archive
- `JOSHUA-Matrix.swift` → workload calculation
- `TerminalViews.swift` → minimal UI

Flow:

```
User Input → Kernel → Task State → Archive (sealed) → Metrics
```

No backend required. No cloud required. System continues working even without internet.

---

## Example

```swift
brain.set("task.42.title", "Cool soup")
brain.set("task.42.status", "inProgress")

let title = brain.get("task.42.title")
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

## JOSHUA-Matrix (Workload Score)

Production errors rarely come from bad intentions. They come from overload.

The matrix estimates stress level based on:

- active tasks
- interruptions
- task complexity
- concurrency

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
