# ADR-007 · `PrayerProfile` replaces `CountryProfile`

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-007 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Scope: `countries[]` (ISO 3166-1 alpha-2) resolved offline via the `country_polygons` package; `adminAreas[]` (ISO 3166-2) and `polygonsRef` `[DEFERRED V1]`. `authorityType ∈ {GOVERNMENT, RECOGNIZED_BODY, COMMUNITY_CONVENTION, ENGINE_DEFAULT}`. `Authority aligned` only for the first two with a `benchmarkReportId`. Non-overlap: exactly one profile per (point, date); overlap is a pipeline build error; no match ⇒ `engine.default` (`ENGINE_DEFAULT`, labelled `Calculated`, user told no local authority profile exists).

## Trade-offs

- **Win:** —
- **Lose:** —

## Engine subset (slice S06, 2026-10-21)

- The engine's `PrayerProfile` carries `status`, `authorityType` and `benchmarkReportId`, read only by `ConfidenceMapper`. `Authority aligned` requires `approved`, a `government` or `recognizedBody` authority, and a report id; every other primary time of an `ENGINE_DEFAULT` or `COMMUNITY_CONVENTION` profile is `Calculated` (REQ-DOM-050, §15 D46).
- S07 completes the model and the loader, and replaces the bench stand-in data (§15 D48).

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

`REQ-DOM-050`, `REQ-DOM-010`

## Tests

- `packages/geo_salah_core/test/policy/confidence_mapper_test.dart`: the four §6.2 rows and every non-aligned standing.
- `packages/geo_salah_core/test/api/calculate_day_policy_test.dart`: `Authority aligned` and `Unknown` through `CalculateDay`; `engine.default` is `Calculated`.

## Supersedes

—
