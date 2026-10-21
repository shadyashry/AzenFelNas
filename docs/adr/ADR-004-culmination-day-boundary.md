# ADR-004 · Prayer-day boundary by solar culmination segments

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-004 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Day `D`: upper transit `T₀` with `localDate(T₀, zone) == D`; lower transits `A₋ < T₀ < A₊`. Ascending events (Imsak, Fajr, Sunrise) in `[A₋, T₀]`; Dhuhr = `T₀` + offset; descending (Asr, Maghrib, Isha) in `[T₀, A₊]`. Isha may have `localDate == D+1` (shown `+1`).

## Trade-offs

- **Win:** correct at high latitude in summer and in zones like `Pacific/Kiritimati`.
- **Lose:** slightly more code than civil-day search.

## Engine realisation (slice S04, 2026-10-21)

- `CulminationSegments.locate` (`geo_salah_core/lib/src/solver/culmination_segments.dart`) starts at mean solar noon of `D` at the observer's longitude. It solves `H = 0°` on the interpolated day model (§6.4 ¶2), refines with one exact SPA step, and moves by whole days until `localDate(T₀, zone) == D`. `A₋` and `A₊` solve `H = 180°` from `T₀ ∓ 12 h` the same way.
- A zone that skips a calendar day (e.g. `Pacific/Apia` 2011-12-30) has no `T₀` on it; `locate` returns `null`, and S05 decides how `calculateDay` reports it (§15 D35).
- Each half segment is split at the altitude's stationary points into monotone pieces, so every crossing is bracketed (§15 D34). Ascending events take the rising crossing in `[A₋, T₀]`, descending ones the setting crossing in `[T₀, A₊]`.
- Consecutive days tile time: `A₊(D)` and `A₋(D+1)` agree to < 1 ms.

## Day calculation (slice S05, 2026-10-21)

- `CalculateDay` takes Dhuhr as `T₀` plus the transit rule's offset, Sunrise as the last rising crossing in `[A₋, T₀]` and Maghrib as the first setting crossing in `[T₀, A₊]` (§15 D37). Without a crossing in the event's direction the event is `NoEvent(polarDay | polarNight)`, by the altitude at `T₀`.
- A skipped calendar day has no `T₀`, so `calculateDay` returns a `DayResult` without times (§15 D36). The zone selects the day only: raw instants do not change with the zone offset (property test).
- `dayOffset` is the local date of the displayed instant, by the injected TZDB, minus `D`.

## Every event (slice S06, 2026-10-21)

- Fajr (and Imsak) are searched in `[A₋, T₀]`, and Asr and Isha in `[T₀, A₊]`. The crossing is chosen as for the horizon rule (§15 D37, D41), and the choice is shared through `HalfSegmentCrossing`. The shadow-factor rule defines descending events only.
- An interval event takes its base's raw instant (§15 D42), so Isha after Maghrib may carry `dayOffset` +1 like a late Isha.
- `dayOffset` now comes from the **displayed** instant, after rounding.

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

`REQ-TIME-002`, `REQ-DOM-002` (no root ⇒ no event, never an extrapolation)

## Tests

- `packages/geo_salah_core/test/solver/culmination_segments_test.dart`: local-date rule, hour angles at `T₀` and `A±`, day tiling, Kiritimati (UTC+14 at 157° W), the skipped Apia day.
- `packages/geo_salah_core/test/api/calculate_day_test.dart`: Dhuhr at `T₀`, Sunrise and Maghrib in their halves, typed polar day and night at Tromsø, zone independence of raw instants, `dayOffset` +1 after local midnight, the skipped Apia day.
- `packages/geo_salah_core/test/api/calculate_day_rules_test.dart`: Fajr rising in `[A₋, T₀]`, Isha setting and Asr between Dhuhr and `A₊`, interval events on the base's raw instant.
- `packages/geo_salah_core/test/solver/crossings_test.dart`: bracket exhaustiveness against a dense scan, including grazing targets; monotone pieces; polar day and night; continuity.

## Supersedes

—
