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

## Profiles, set and resolver (slice S07, 2026-10-21)

- `PrayerProfile` has the full §6.2 shape. The `prayer_profile.v1` wire model and `PrayerProfileMapper` live in `geo_salah_core` (§15 D51).
- `geo_salah_profiles` provides four use cases (§15 D52):
  - `ParsePrayerProfile`: schema-inexpressible rules;
  - `ValidateProfileSet`: non-overlap per country and day (`PROFILE_OVERLAP`), plus a live `engine.default`;
  - `CheckProfileChannel`;
  - `ResolveProfile`: country + day, falling back to `engine.default`, which the engine flags `noLocalProfile`.
- Seeds: `engine.default`, `eg.egas.standard`, `sa.ummalqura.standard` and `ae.awqaf.standard` in `profiles/`, all `DRAFT_UNVERIFIED`. Values DESIGN.md does not give are §15 D50 engineering defaults.

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

`REQ-DOM-050`, `REQ-DOM-010`, `REQ-ERR-002` (profile failure codes)

## Tests

- `packages/geo_salah_profiles/test/seed_profiles_test.dart`: the S07 done-test; every seed and its Ramadan variant parses, validates and calculates every benchmark city of its scope.
- `packages/geo_salah_profiles/test/validate_profile_set_test.dart`: the overlap fixture is `PROFILE_OVERLAP`; consecutive and retired versions pass.
- `packages/geo_salah_profiles/test/resolve_profile_test.dart`, `parse_prayer_profile_test.dart`.

- `packages/geo_salah_core/test/policy/confidence_mapper_test.dart`: the four §6.2 rows and every non-aligned standing.
- `packages/geo_salah_core/test/api/calculate_day_policy_test.dart`: `Authority aligned` and `Unknown` through `CalculateDay`; `engine.default` is `Calculated`.

## Supersedes

—
