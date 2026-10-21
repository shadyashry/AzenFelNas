# dm_hijri

Tabular Hijri calendar, announcements model and HijriState builder (DESIGN.md §5.2, ADR-016).

Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the platform. Holds the `hijri_package.v1` wire model since S02. Since S08: `TabularHijriCalendar` (ADR-016: 30-year cycle, leap years {2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29}, astronomical epoch JDN 1948439) and `BuildHijriState`, which gives the engine `hijri(D)` and `hijri(D + 1)` labelled `expected`, or `userOverride` after the ±1-day setting (§9.5). Confirmed month starts from the `hijri` package are read by the package client (DESIGN.md §15 D57).
