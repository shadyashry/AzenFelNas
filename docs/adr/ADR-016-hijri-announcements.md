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

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

—

## Tests

—

## Supersedes

—
