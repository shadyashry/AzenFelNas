# ADR-017 · Privacy controls are mechanical

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-017 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Places in a separate `places.sqlite` excluded from backup; country-level packages; CDN logs without IP retention > 24 h; diagnostics round coordinates to 0.01°; CI egress allow-list test (`cdn.dailymuslim.app`, `api.dailymuslim.app` only); no crash SDK by default.

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
