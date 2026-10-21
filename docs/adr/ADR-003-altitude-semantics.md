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

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

—

## Tests

—

## Supersedes

—
