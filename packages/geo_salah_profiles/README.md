# geo_salah_profiles

Parses and validates prayer profiles and resolves point + date to a profile (DESIGN.md §6.5, ADR-007).

Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the platform.

Since S07 it holds the use cases over profile data (§15 D52):

| Use case | What it does |
|---|---|
| `ParsePrayerProfile` | decoded `prayer_profile.v1` → validated `PrayerProfile`: the wire model and mapping from `geo_salah_core`, plus the §9.2 checks, the Appendix A CI gate, scope, reference-point and compatibility rules |
| `ValidateProfileSet` | non-overlap: one profile per (country, day); an `engine.default` to fall back on |
| `CheckProfileChannel` | `DRAFT_UNVERIFIED` and `CANDIDATE` load on `dev`/`lab` only (Appendix E) |
| `ResolveProfile` | country + day → profile; `engine.default` when no authority profile applies; reference points narrowed to the country (ADR-006) |

The `prayer_profile.v1` wire model moved to `geo_salah_core` in S07 (§15 D51), which breaks the dependency cycle the engine bench would otherwise need.

`tool/sync_bench_profiles.dart` compiles the bench's seed profiles (`profiles/*.yaml`) to JSON for `geo_salah_core/bench/profiles/`. The tests read the YAML seeds directly (`yaml` is a dev dependency only; the app reads compiled JSON, ADR-008).
