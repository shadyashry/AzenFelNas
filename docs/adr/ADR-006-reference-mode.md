# ADR-006 · Reference mode is a profile field

- **Status:** `[DEFAULT · D2]`
- **Source:** `DESIGN.md` §4 ADR-006 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

`referenceMode ∈ {EXACT_COORDINATE, AUTHORITY_REFERENCE_POINT}`, default `EXACT_COORDINATE`. With `AUTHORITY_REFERENCE_POINT` the engine calculates at the profile's reference point for the resolved area; MVP resolves by **country** (admin-1 polygons `[DEFERRED V1]`). The UI always shows the mode; the alarm follows the displayed mode.

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
