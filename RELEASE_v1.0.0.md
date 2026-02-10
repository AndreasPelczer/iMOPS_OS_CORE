# iMOPS_OS_CORE v1.0.0

**Release Date:** February 2026

## What This Is

A deterministic in-memory production kernel for high-stress operational environments.
Built from 36 years of professional kitchen and production management experience.

This is not a framework. This is not a library. This is a complete, self-contained system kernel
with an integrated protection stack that travels with every fork.

## What You Get

### Kernel
- `TheBrain` — In-memory MUMPS-style storage engine (`[String: Any]`, Serial Queue, `@Observable`)
- `Syntax` — Type-safe DSL (`iMOPS.SET(.task("001", "TITLE"), "value")`)
- `KernelArbeitsschritt` — Typed task model with 4-stage lifecycle (offen, inArbeit, erledigt, abgenommen)
- `TaskRepository` — Task creation, lifecycle transitions, HACCP archiving

### Guard System (Gen 3 Protection Stack)
- `SecurityLevel` — 2 ethical states (standard, deEscalation). Codable. Tested. No third level allowed.
- `MenschMeierModus` — Rio Reiser Jitter (anti-tracking noise), anonymization ("Brigade" poison pill), Privacy Shield (auto-escalation at >50 admin queries, allergen always transparent)
- `BourdainGuard` — Fatigue protection (8h warning, 10h forced training mode), whisper messages, escalating jitter strength
- `KernelGuards` — Single entry-point orchestrator returning `GuardReport`
- 22 integrity tests including tamper detection
- In-app Self-Check (13 steps) with boot verification sealed in HACCP archive

### Export
- 3 formats: Tagesbericht (text), Audit CSV, Journal JSON
- SHA-256 sealed
- DSGVO guards applied before any data leaves the system

### Multi-Industry Seeds
- Kitchen, Healthcare, Construction, Manufacturing
- Each with domain-specific brigade and tasks

## What You Do NOT Get

- No CoreData
- No CloudKit
- No network layer
- No authentication system
- No user database
- No cloud sync
- No analytics
- No tracking

These are intentional absences, not missing features.

## API Stability Promise

The following are stable and will not change until v2.0:

| Component | Guarantee |
|-----------|-----------|
| `TheBrain.set/get/kill/killTree` | Stable |
| `iMOPS.SET/GET/KILL/KILLTREE/GOTO` | Stable |
| `BrainPath` factory methods | Stable |
| `BrainNamespace` cases | Stable (additive changes allowed) |
| `KernelArbeitsschritt` struct | Stable |
| `ArbeitsschrittStatus` 4-stage lifecycle | Stable |
| `TaskRepository.createProductionTask/transitionTask/completeTask` | Stable |
| `SecurityLevel` (exactly 2 cases) | Stable |
| `MenschMeierModus` public methods | Stable |
| `BourdainGuard` public methods | Stable |
| `KernelGuards.evaluate()` signature | Stable |
| `GuardReport` properties | Stable |
| `exportLog/exportCSV/exportJSON` signatures | Stable |

"Stable" means: no breaking changes. Additive extensions are allowed.

## What Would Constitute v2.0

- Changing the storage model from `[String: Any]`
- Adding a third SecurityLevel
- Altering BourdainGuard thresholds (8h/10h)
- Changing the HACCP archive structure
- Introducing mandatory dependencies

## Requirements

- iOS 17+
- Xcode 16+
- Swift 5.9+
- Zero external dependencies

## License

MIT. Use it. Fork it. Build on it. The guard stack travels with you.
