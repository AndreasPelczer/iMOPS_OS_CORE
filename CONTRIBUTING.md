# Contributing to iMOPS_OS_CORE

## The Short Version

This is a reference kernel. It is intentionally small. It will stay small.

## What We Accept

- **Bug reports**: Yes. Open an issue. Describe what happened, what you expected, and your environment.
- **Guard integrity issues**: See [SECURITY.md](SECURITY.md). Private channel only.
- **Documentation fixes**: Typos, unclear wording, missing context. PRs welcome.
- **Test additions**: More guard integrity tests are always welcome. Use Swift Testing (`@Test`, `#expect`), not XCTest.

## What We Do NOT Accept

- **Feature requests**: This kernel is complete by design. Build extensions in your own fork.
- **New dependencies**: No pods, no packages, no frameworks. Zero dependencies is a feature.
- **CoreData / CloudKit / Network layers**: This is an offline-first in-memory kernel. Cloud sync belongs in downstream projects.
- **Changes to KernelGuards.swift**: The guard logic is tested and legally reviewed. If you believe a guard is wrong, open a security report.
- **Changes to export functions**: exportLog/exportCSV/exportJSON and their DSGVO guards are final.
- **Personal data in archives**: No names (roles only), no milliseconds (hour windows only). This is DSGVO Art. 25, not optional.

## Rules for PRs

- Swift, SwiftUI, iOS 17+, @Observable
- German in code (variables, comments), English in README/docs
- Tests must pass. All of them. No exceptions.
- One PR = one concern. No mega-PRs.

## How to Fork

The intended use of this project is forking. Take the entire kernel, build your domain-specific system on top. The guard stack travels with you.

```
iMOPS_OS_CORE (this repo)
    └── Your Fork (your domain logic, your UI, your sync layer)
```

You inherit: TheBrain, Syntax, KernelGuards, TaskRepository, KernelArbeitsschritt, Tests.

You add: Your industry logic, your UI, your data layer.
