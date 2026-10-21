# geo_salah_core

Geo Salah Engine: ephemeris, solver, rules, rounding, Qibla, SolarState, provenance and PrayerProfile value types (DESIGN.md §6).

Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the platform. Holds the `calculation_trace.v1` wire model and shared wire codes since S02. Since S04 it also holds the astronomical core: `lib/src/astro/` (SPA from Reda & Andreas 2008, Espenak–Meeus ΔT, the §6.4 ¶2 interpolated day model) and `lib/src/solver/` (Brent, monotone-piece brackets, ADR-004 culmination segments).

Since S05 it exposes the §6.2 domain types (`lib/src/model/`), the `CalculateDay` use case (`lib/src/api/`) for Sunrise, Dhuhr and Maghrib from the transit and horizon rules (`lib/src/rules/`), the Calculation ID and the `calculation_trace.v1` writer (`lib/src/trace/`). S05 output carries no rounding, flags or adjustments yet (§15 D39).

## Lab bench

`dart run geo_salah_core:bench` speaks the §15 D29 JSONL contract (`bench_request.v1` in, one `calculation_trace.v1` or `bench_failure.v1` line out per request). It runs with the S05 stand-ins in `lib/src/bench/`: fixed standard-offset zones and an `engine.default` stand-in (§15 D40). The Accuracy Lab drives it: `uv run --frozen lab benchmark --engine dart` from `lab/`.

## Golden corpus

`test/golden/<city>/<profileId>/<year>.json` holds the engine's raw instants and origins, frozen after the lab confirmed them (ADR-019, §15 D40); `test/golden_corpus_test.dart` requires exact equality. Regenerate only in a `golden-update` change (§0.2 rule 3): `dart run tool/update_golden.dart`.
