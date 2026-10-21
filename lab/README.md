# Accuracy Lab (`lab/`)

Reference harness and engine benchmark runner (`DESIGN.md` §9.4, ADR-019). It was written and frozen in slice S03, before the engine. The engine slices (S04–S06) **run** the lab; they do not read or change its code (`docs/prompts/claude-code-kickoff.md` §C).

## What is frozen

| File | What it is |
|---|---|
| `benchmarks/cities.v1.json` | Appendix H cities (IANA zone, ISO country) and the date-set rule (§15 D30) |
| `config/harness.v1.toml` | Cited astronomy constants only: ADR-003 horizon, ADR-019 time scales and tolerance, ephemeris pin |
| `reference/sun_events.2026-2028.v1.jsonl` | Skyfield + `de440s.bsp` sunrise, transit and sunset for every city and benchmark day, 2026–2028 (`schemas/lab_reference.v1`) |
| `reference/sun_events.2026-2028.v1.manifest.json` | Input, tool and output sha256s of that run (`schemas/pipeline_manifest.v1`) |

## Commands (from `lab/`, uv 0.13.4)

```bash
uv sync --frozen
uv run --frozen lab benchmark --engine dart            # engine vs reference, writes out/benchmark/
uv run --frozen lab benchmark --engine dart --years 2026-2026 --profile engine.default --out out/x
uv run --frozen lab reference --years 2026-2028        # rebuild the reference (≈ 4 min); fetches de440s.bsp once
bash scripts/gen_models.sh                             # regenerate pydantic models from ../schemas
```

`lab benchmark` pipes `bench_request.v1` lines into `dart run geo_salah_core:bench` (run in `packages/geo_salah_core`). It expects exactly one line back per request, in order: a `calculation_trace.v1` document, or a `bench_failure.v1` document.

It compares the engine's **raw** Sunrise, Dhuhr and Maghrib against the reference's sunrise, transit and sunset, using each event's ADR-019 tolerance (§15 D29), and writes four files:
- `requests.jsonl`
- `responses.jsonl`
- `discrepancy_report.json` (`schemas/discrepancy_report.v1`)
- `manifest.json`

Exit status: 0 = everything agrees, 1 = blocking discrepancies (`UNKNOWN`, §6.7), 2 = usage error or contract violation.

The ephemeris is cached in `.cache/` (or `$DM_LAB_CACHE`) and verified by sha256 before every use.
