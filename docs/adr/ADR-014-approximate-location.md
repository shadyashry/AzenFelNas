# ADR-014 · Location: approximate by default; context pinning beats the resolver

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-014 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Accept a fix if `horizontalAccuracyM ≤ 5000` and age ≤ 15 min. Offer precise location only when (a) the point is within 10 km of a tz or country boundary, or (b) the user opens Qibla with `horizontalAccuracyM > 1000`. Pinned/manual contexts are never auto-replaced.

## Trade-offs

- **Win:** —
- **Lose:** —

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

`REQ-PRIV-002`, `REQ-TIME-010` (clock integrity lives in the same feature).

## Tests

S13 (§15 D73): `apps/mobile/test/features/contexts/contexts_done_test.dart` (pinned polygons + drift), `resolve_observer_context_test.dart` (fix acceptance, randomised REQ-PRIV-002 check, mock-location diagnostics), `pin_place_test.dart`, `platform_location_permissions_test.dart` (coarse / when-in-use only).

## Supersedes

—
