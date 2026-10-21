# geo_salah_core

Geo Salah Engine: ephemeris, solver, rules, rounding, Qibla, SolarState, provenance and PrayerProfile value types (DESIGN.md §6).

Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the platform. Holds the `calculation_trace.v1` wire model and shared wire codes since S02. Since S04 it also holds the astronomical core: `lib/src/astro/` (SPA from Reda & Andreas 2008, Espenak–Meeus ΔT, the §6.4 ¶2 interpolated day model) and `lib/src/solver/` (Brent, monotone-piece brackets, ADR-004 culmination segments).

Since S05 it exposes the §6.2 domain types (`lib/src/model/`), the Calculation ID and the `calculation_trace.v1` writer (`lib/src/trace/`).

Since S06 it calculates every event:
- `CalculateDay` and `CalculateRange` (`lib/src/api/`) run the §6.4 pipeline:
  - the rules (`lib/src/rules/`): solar altitude, transit, shadow factor, horizon and the interval rules on raw bases;
  - the policies (`lib/src/policy/`): per-event offsets, then per-event rounding as the last step with `nearRoundingBoundary`, then the day flags, the §6.2 confidence mapping and the REQ-DOM-001 ordering guard.
- `CalculateRange` shares SPA samples between neighbouring days and returns exactly what `CalculateDay` returns.
- High-latitude fallbacks and Ramadan rule replacement arrive in S08 (§15 D41–D47).

## Lab bench

`dart run geo_salah_core:bench` speaks the §15 D29 JSONL contract (`bench_request.v1` in, one `calculation_trace.v1` or `bench_failure.v1` line out per request) for every event. It runs with these stand-ins:
- fixed standard-offset zones (`lib/src/bench/`, §15 D40);
- the profile **data** in `bench/profiles/`: an `engine.default` stand-in whose values cite §6.5, ADR-003 and ADR-005 (§15 D48, `bench/profiles/README.md`).

The Accuracy Lab drives it with `uv run --frozen lab benchmark --engine dart` from `lab/`.

## Performance baseline

`tool/range_baseline.dart` times a one-year `calculateRange` (REQ-PERF-001, median of 5) when compiled with `dart compile exe`; the recorded baseline is in §15 D49.

## Golden corpus

`test/golden/<city>/<profileId>/<year>.json` holds the engine's raw instants and origins, frozen after the lab confirmed them (ADR-019, §15 D40); `test/golden_corpus_test.dart` requires exact equality. Regenerate only in a `golden-update` change (§0.2 rule 3): `dart run tool/update_golden.dart`.
