# ADR-005 · Per-event rounding, asymmetric error budget, alarm on displayed minute

- **Status:** `[DEFAULT · D4]`
- **Source:** `DESIGN.md` §4 ADR-005 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Default `rounding.default = ceil`, `rounding.sunrise = floor`. Entry-event budget `−0 s / +60 s`. Flag `nearRoundingBoundary` when `|raw − minute boundary| < 500 ms`.

## Trade-offs

- **Win:** never shows an entry before it has entered.
- **Lose:** up to 59 s later than nearest-minute tables; disclosed in Passport.

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

—

## Tests

—

## Supersedes

—
