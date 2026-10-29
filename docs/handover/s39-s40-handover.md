# S39–S40 hand-over: UAE profile fitted to Awqaf (DESIGN.md §15 D99)

Branches `slice/s39-uae-profile` (profile data and the Go gate rule) and `slice/s40-uae-seed` (rebuilt bundled seed,
evidence table and accuracy test), stacked on `slice/s38-ux-compass`. Split so no commit changes an angle together
with tz/coordinate data (D64).

## What changed
- `ae.awqaf.standard`: Fajr 18.1° −1 min, Isha 18.2° −1 min, Sunrise −3 (floor), Dhuhr +2, Asr standard, Maghrib
  horizon 40′ refraction +2; entries round up. Evidence: 123 days of the Awqaf table for Abu Dhabi (Jan, Apr, Jul,
  Oct 2026) in `apps/mobile/test/fixtures/awqaf_musaffah_2026.csv`, sha256 in the profile.
- `gsctl validate` refuses nearest rounding of an entry event without a rounding approval (the app already did).

## Evidence
- 687 of 738 published times exact (93 %), all within one minute; Maghrib never before the authority's.
- Test `ae.awqaf.standard reproduces the Awqaf table …`; Go `TestNearestRoundingOfAnEntryNeedsARoundingApproval_AppendixA`.

## Owed
- Sharia board approval of the fitted values (the profile stays `DRAFT_UNVERIFIED`).
- Other emirates' district points are not published; single-day checks for Dubai and Al Ain agree within a minute.
