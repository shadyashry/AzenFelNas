# Bench profiles (compiled seeds)

The profile **data** read by the engine bench (`bin/bench.dart`), the golden corpus tool, the perf tool and the tests (`DESIGN.md` §15 D48, D51). No religious value is written in Dart (§0.2 rule 1).

Since S07 each file here is the compiled JSON of a seed profile in the repository's `profiles/`. It is a full Appendix A `prayer_profile.v1` document, read through the same wire model and `PrayerProfileMapper` as the app's profiles. The value sources are in `profiles/README.md`.

| File | Source |
|---|---|
| `engine.default.json` | `profiles/engine/engine.default.yaml` |

Do not edit these files. Change the YAML seed, then run `dart run tool/sync_bench_profiles.dart` in `packages/geo_salah_profiles`; `test/bench_profiles_fresh_test.dart` there fails while a copy is stale. A changed bench profile changes the golden corpus (`profileVersion` is checked), so it ships with a `golden-update` change.
