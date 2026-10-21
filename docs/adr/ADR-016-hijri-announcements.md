# ADR-016 · Hijri: signed per-country announcements + tabular fallback flagged `Expected`

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-016 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Fallback = tabular ("Kuwaiti") Islamic calendar: 30-year cycle, leap years {2,5,7,10,13,16,18,21,24,26,29}, astronomical epoch (1 Muharram 1 AH = 15 July 622 CE Julian, JDN 1948439). The Umm al-Qura table itself is not shipped in MVP. Confirmed month starts arrive in the `hijri` package. Ramadan rules for launch countries are in MVP.

## Trade-offs

- **Win:** —
- **Lose:** —

## Tabular fallback and HijriState (slice S08, 2026-10-21)

- `dm_hijri` `TabularHijriCalendar` implements the decision exactly: the leap-year set, 30/29-day months with a 30-day month 12 in leap years, epoch JDN 1948439. `BuildHijriState` gives the engine `hijri(D)` at dawn and `hijri(D + 1)` at night, labelled `expected`, or `userOverride` after the ±1-day setting (§15 D57).
- The engine's Ramadan rule replacement reads `ramadanAtNight` for Isha and `ramadanAtDawn` for Imsak/Fajr, and flags replaced events `hijriExpected` under an `expected` state (§15 D56).
- Every Hijri state the lab supplied in the S08 benchmark runs (4188 requests over 363 days, including the tabular Ramadan starts and ends of 1447–1449) equals `BuildHijriState`.
- Confirmed month starts (`hijri_package.v1`) are read by the package client, S14 (§15 D57).

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

`REQ-DOM-004` (the Hijri state is part of the Calculation ID)

## Tests

- `packages/dm_hijri/test/tabular_hijri_calendar_test.dart`: epoch, leap years, month lengths, the 10 631-day cycle, a worked date, round trip and day-advance properties.
- `packages/dm_hijri/test/build_hijri_state_test.dart`: dawn/night dates, Ramadan eve and last fast, the user override.
- `packages/geo_salah_core/test/rules/ramadan_rules_test.dart`, `packages/geo_salah_profiles/test/seed_profiles_test.dart`: Ramadan replacement through the engine.

## Supersedes

—
