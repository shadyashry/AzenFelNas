# geo_salah_core

Geo Salah Engine: ephemeris, solver, rules, rounding, Qibla, SolarState, provenance and PrayerProfile value types (DESIGN.md §6).

Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the platform. Holds the `calculation_trace.v1` wire model and shared wire codes since S02. Since S04 it also holds the astronomical core: `lib/src/astro/` (SPA from Reda & Andreas 2008, Espenak–Meeus ΔT, the §6.4 ¶2 interpolated day model) and `lib/src/solver/` (Brent, monotone-piece brackets, ADR-004 culmination segments).

Since S05 it exposes the §6.2 domain types (`lib/src/model/`), the Calculation ID and the `calculation_trace.v1` writer (`lib/src/trace/`).

Since S06 it calculates every event:
- `CalculateDay` and `CalculateRange` (`lib/src/api/`) run the §6.4 pipeline:
  - the rules (`lib/src/rules/`): solar altitude, transit, shadow factor, horizon and the interval rules on raw bases;
  - the policies (`lib/src/policy/`): per-event offsets, then per-event rounding as the last step with `nearRoundingBoundary`, then the day flags, the §6.2 confidence mapping and the REQ-DOM-001 ordering guard.
- `CalculateRange` shares SPA samples between neighbouring days and returns exactly what `CalculateDay` returns.

Since S07 the package also holds:
- the full §6.2 `PrayerProfile` (`lib/src/model/`);
- the `prayer_profile.v1` wire model (`lib/src/wire/profile/`, moved from `geo_salah_profiles`);
- `PrayerProfileMapper` (`lib/src/profile/`), the one document → domain mapping.

The engine calculates at the authority reference point under `AUTHORITY_REFERENCE_POINT` (ADR-006) and flags `referenceModeAuthorityPoint` and `noLocalProfile` (§15 D51, D53).

Since S08 the rule step and the steps after it also cover:
- **Ramadan rule replacement** (`lib/src/rules/ramadan_rules.dart`, §6.4 ¶6): `ramadanAtNight` governs Isha and `ramadanAtDawn` governs Imsak/Fajr. Each replacement is traced as `ramadanRuleReplacement` and flagged `hijriExpected` under an Expected Hijri state (§15 D56).
- **The high-latitude chain** (`lib/src/rules/high_latitude.dart`, §6.4 ¶7): Imsak, Fajr and Isha without a root walk the profile's ordered chain over UTC nights, giving `Fallback(method)` or `NoEvent(chainExhausted)`. A fallback is flagged `highLatitudeFallback`, traced, and labelled `Estimated` with its ±1 km sensitivity (§15 D54, D55).
- `SolvedDays` memoises the days and sites the chain solves; a range shares it, so results stay bit-identical to `CalculateDay`.

## Lab bench

`dart run geo_salah_core:bench` speaks the §15 D29 JSONL contract (`bench_request.v1` in, one `calculation_trace.v1` or `bench_failure.v1` line out per request) for every event. It runs with these stand-ins:
- fixed standard-offset zones (`lib/src/bench/`, §15 D40);
- the profile **data** in `bench/profiles/`: since S07, the compiled JSON of the seed `profiles/engine/engine.default.yaml`. It is read through the same wire model and `PrayerProfileMapper` as the app's profiles (§15 D48, D51, `bench/profiles/README.md`).

The Accuracy Lab drives it with `uv run --frozen lab benchmark --engine dart` from `lab/`.

## Performance baseline

`tool/range_baseline.dart` times a one-year `calculateRange` (REQ-PERF-001, median of 5) when compiled with `dart compile exe`; the recorded baseline is in §15 D49.

## Golden corpus

`test/golden/<city>/<profileId>/<year>.json` (v2, S06) holds the engine's origins (a fallback with its method, S08), raw instants and displayed instants of every `engine.default` event. Sunrise, Dhuhr and Maghrib were frozen after the lab confirmed them (ADR-019, §15 D40). Fajr, Asr and Isha, fallbacks included, have no lab reference yet (§15 D48). `test/golden_corpus_test.dart` requires exact equality. Regenerate only in a `golden-update` change (§0.2 rule 3): `dart run tool/update_golden.dart`.
