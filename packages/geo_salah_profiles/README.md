# geo_salah_profiles

Parses and validates prayer profiles and resolves point + date to a profile (DESIGN.md §6.5, ADR-007).

Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the platform. Holds the `prayer_profile.v1` wire model since S02; parsing, validation and the resolver arrive in S07.
