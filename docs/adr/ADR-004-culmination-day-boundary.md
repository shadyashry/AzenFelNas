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

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

—

## Tests

—

## Supersedes

—
