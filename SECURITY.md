# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.0.x   | Yes       |

## Reporting a Vulnerability

If you discover a security vulnerability in the Guard system (SecurityLevel, MenschMeierModus, BourdainGuard, KernelGuards), **do not open a public issue.**

Contact: **a.pelczer@gmail.com**

Subject line: `[iMOPS SECURITY] <brief description>`

Plain email accepted. No PGP required.

## Disclosure Timeline

| Step | Timeframe |
|------|-----------|
| Acknowledgement | Within 72 hours |
| Assessment & classification | Within 7 days |
| Fix (if confirmed) | As soon as feasible, target 30 days |
| Coordinated disclosure | After fix is released, or 90 days after report — whichever comes first |

If you do not receive acknowledgement within 72 hours, send a follow-up.

## Severity

**Critical** — Any issue that allows personal identification in de-escalation mode, suppresses allergen data, bypasses SecurityLevel, or disables BourdainGuard thresholds. These affect human safety or legal compliance (DSGVO Art. 25).

**High** — Deterministic jitter, Privacy Shield triggering at wrong threshold, tamper detection bypass, personal data in HACCP archive.

**Out of scope** — UI styling, feature requests, performance optimization.

## What Counts as a Security Issue

- Guard bypass (SecurityLevel can be circumvented)
- Jitter disabled or deterministic (Rio Reiser Jitter returns predictable values)
- Privacy Shield threshold manipulated (triggers at wrong count)
- Anonymization leak (real names visible in de-escalation mode)
- Allergen data hidden by Privacy Shield (life-threatening)
- BourdainGuard thresholds altered (8h/10h boundaries moved)
- Tamper detection tests can be bypassed
- Personal data in HACCP archive (names instead of roles, milliseconds instead of hour windows)

## Philosophy

The guard system protects individuals from micro-tracking, fatigue, and management abuse.
A vulnerability in the guards is not a bug — it is a breach of trust.
