# ADR-002 · Native alarm layer consumes a precomputed `SchedulePlan`

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-002 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

The application layer generates a 30-day plan (platform-fitted) and writes it to native-readable storage (§8). Kotlin/Swift schedule from it and re-read it on every system event.

## Trade-offs

- **Win:** survives reboot, direct boot, weeks unopened.
- **Lose:** a plan can go stale after travel or a profile change between opens — mitigated by `STALE_PLAN`, zone-change receivers and the horizon warning.

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

—

## Tests

—

## Supersedes

—

## S27 note

Dart hands a plan to native code through one consumer-defined port, `ApplySchedulePlan` (`apps/mobile/lib/features/athan/application/apply_schedule_plan.dart`). Its contract is the one `PlanStore` already enforces: the document is replaced whole and an older generation is refused. A package rollback builds the plan before the pointer flips (`RollBackAndReplan`, §15 D87). The pigeon adapter is owed with the native wiring.
