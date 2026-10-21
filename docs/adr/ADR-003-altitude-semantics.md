# ADR-003 · Altitude semantics: geometric topocentric altitude everywhere; dip = 0 default

- **Status:** `[DECIDED] + [DEFAULT · D3]`
- **Source:** `DESIGN.md` §4 ADR-003 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Sunrise/sunset solve `h_geo = −(refractionArcmin + semidiameterArcmin)/60 − dip`, defaults 34′ + 16′ = 0.8333°, `dip = 0`. Fajr/Isha solve `h_geo = −α` with no refraction and no dip. Elevation is recorded in provenance only. Profile-level `horizon.elevationPolicy ∈ {NONE, ABOVE_LOCAL_TERRAIN, AUTHORITY_TABLE}`, default `NONE`; the other two are `[DEFERRED V2]` and the engine returns `EngineFailure.unsupportedPolicy` for them. A property test asserts no refraction model is ever combined with the 34′ constant.

## Trade-offs

- **Win:** matches authority tables; no DEM.
- **Lose:** no terrain dip until V2.

## Engine realisation (slice S05, 2026-10-21)

- `EventRule.horizon({refractionArcmin = 34, semidiameterArcmin = 16})` carries the ADR-003 defaults as the §6.2 type's defaults; profiles override them as data. `HorizonRuleSolver` solves the geometric topocentric altitude `−(refraction + semidiameter)/60 − dip` and applies no refraction model on top.
- `dip = 0` under `elevationPolicy = NONE`; `ABOVE_LOCAL_TERRAIN` and `AUTHORITY_TABLE` return `EngineFailure.unsupportedPolicy('horizon.elevationPolicy')`. The observer is placed on the ellipsoid at 0 m; `Observer.elevation` is not read.

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

`REQ-ERR-001` (typed `unsupportedPolicy`)

## Tests

- `packages/geo_salah_core/test/api/calculate_day_test.dart`: the horizon rule at −(34′ + 16′) geometric altitude with no dip and no refraction model (property over 12 cities × 2026–2028); refraction and semidiameter taken from the rule; `unsupportedPolicy` for the `[DEFERRED V2]` policies.

## Supersedes

—
