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

## Engine and resolver (slice S07, 2026-10-21)

- `ResolveProfile` narrows an `AUTHORITY_REFERENCE_POINT` profile's points to the observer's country (MVP). The engine calculates at that single point; zero or several points is `invalidProfile` (§15 D53).
- The Calculation ID and the trace `inputs` carry the point's coordinates, so every observer of the area shares one ID. Every time carries `referenceModeAuthorityPoint`.
- All seed profiles are `EXACT_COORDINATE` (§15 D2).

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

`REQ-DOM-004` (one ID per area)

## Tests

- `packages/geo_salah_core/test/api/calculate_day_reference_test.dart`: calculation at the point, the flag, the shared ID, `invalidProfile` without exactly one point.
- `packages/geo_salah_profiles/test/resolve_profile_test.dart`: points narrowed to the country; a country without a point is refused.

## Supersedes

—
