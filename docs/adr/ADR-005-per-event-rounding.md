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

## Engine realisation (slice S06, 2026-10-21)

- **Values are data:** the rounding mode is profile data (`roundingDefault`, `roundingOverrides`) with no code default (§0.2 rule 1). The bench stand-in carries ADR-005's `ceil` with `sunrise: floor` (§15 D48).
- **Order:** rounding is the last step of every timed event. It runs after the rule and the per-event offset and works in local minutes (§15 D43). Each event gets exactly one `ROUNDING` adjustment step, and no rounded instant feeds another rule: interval rules read the base's raw instant.
- **Flag:** `nearRoundingBoundary` is set when the pre-rounding instant is < 500 ms from its nearest local minute boundary.
- **Budget:** a property test bounds `displayed − raw` to `[0, 60 s)` for `ceil` and `(−60 s, 0]` for `floor`. Over the golden corpus, the ceil events lie at +8 ms … +59 996 ms and Sunrise at −59 997 ms … −19 ms.

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

`REQ-DOM-003`, `REQ-ALM-001` (the displayed minute is the alarmed one)

## Tests

- `packages/geo_salah_core/test/policy/rounding_test.dart`: modes, boundaries, local minutes in a seconds offset, the 500 ms flag, budget and idempotence (properties).
- `packages/geo_salah_core/test/api/calculate_day_policy_test.dart`: exactly one rounding step, as the last step; the per-event mode; the flag; no rounded instant feeding an interval; offsets before rounding.

## Supersedes

—
