# ADR-013 · iOS: AlarmKit on iOS 26+, local notifications on iOS 18; absolute-instant triggers; 64-slot budget

- **Status:** `[DECIDED · revisit D6]`
- **Source:** `DESIGN.md` §4 ADR-013 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Support matrix iOS 18 / 26 / 27. The notification path reports `Scheduled (unverifiable)` and never `Ready`. iOS notification Athan is a ≤ 29 s clip; AlarmKit long-audio behaviour validated in S19. Critical-alerts entitlement is **not** requested for MVP.

## Trade-offs

- **Win:** —
- **Lose:** —

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

—

## Tests

—

## Supersedes

—
