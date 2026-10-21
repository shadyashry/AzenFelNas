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

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

—

## Tests

—

## Supersedes

—
