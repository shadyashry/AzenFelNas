# Accuracy Lab (`lab/`)

Reference harness and engine benchmark runner (`DESIGN.md` §9.4, ADR-019). It was written and frozen in slice S03, before the engine. The engine slices (S04–S06) **run** the lab; they do not read or change its code (`docs/prompts/claude-code-kickoff.md` §C). This file, the schemas and `DESIGN.md` §15 D25–D31 are everything the engine author needs.

## What is frozen

| File | What it is |
|---|---|
| `benchmarks/cities.v1.json` | Appendix H cities (IANA zone, ISO country) and the date-set rule (§15 D30) |
| `config/harness.v1.toml` | Cited constants only: ADR-003 horizon, ADR-019 time scales and tolerances, ADR-016 calendar, ephemeris pin |
| `reference/sun_events.2026-2028.v1.jsonl` | Skyfield + `de440s.bsp` sunrise, transit and sunset for every city and benchmark day, 2026–2028 (`schemas/lab_reference.v1`) |
| `reference/sun_events.2026-2028.v1.manifest.json` | Input, tool, harness-code and output sha256s of that run (`schemas/pipeline_manifest.v1`) |

Changing anything under `reference/` needs the `reference-update` label and CODEOWNERS review. The manifest hashes the cities, the config, the ephemeris pin and the reference-deciding code, so changing any of those also changes `reference/`.

## Commands (from `lab/`, uv 0.13.4)

```bash
uv sync --frozen
uv run --frozen lab benchmark --engine dart --tags DAY_OF_MONTH   # S05 done-test: 49 cities × 12 monthly dates per year
uv run --frozen lab benchmark --engine dart                      # every reference case (stricter superset)
uv run --frozen lab benchmark --engine dart --years 2026-2026 --profile engine.default --dhuhr-offset-minutes 0 --out out/x
uv run --frozen lab reference --years 2026-2028                  # rebuild the reference (≈ 4 min; reference-update PRs only)
bash scripts/gen_models.sh                                       # regenerate pydantic models from ../schemas
```

Outputs of `lab benchmark` (default `out/benchmark/`): `requests.jsonl`, `responses.jsonl`, `discrepancy_report.json` (`schemas/discrepancy_report.v1`), `manifest.json`.

Exit status: 0 = no blocking discrepancy, 1 = blocking discrepancies (`UNKNOWN`, §6.7), 2 = usage error or contract violation.

## The bench contract (§15 D29)

The lab runs `dart run geo_salah_core:bench` in `packages/geo_salah_core`. The bench must:
- **Read** one `bench_request.v1` line per case: `{observer, profileId, day, hijri}`.
  - Use the `hijri` state as given and echo it in `inputs.hijri`. Until the hijri package exists it is the ADR-016 tabular state, `EXPECTED`.
- **Write** exactly one line per request, in order: a `calculation_trace.v1` document, or a `bench_failure.v1` document with an Appendix J code.
- **Shape each time by its origin:**
  - A time whose origin is `NO_EVENT` has no `rawUtcMs`, `displayedUtcMs` or `dayOffset`.
  - Every other time has all three. `rawUtcMs` is the rule's instant before rounding, truncated to 1 ms.
- **Keep compared events clean:** Sunrise, Dhuhr and Maghrib carry no adjustment other than `ROUNDING`.

## What agrees

The engine's **raw** Sunrise, Dhuhr and Maghrib are compared with the reference's sunrise, transit and sunset. Each half of the prayer day (ADR-004) is judged on its own. On a polar-transition day, for example, sunrise can be `PRIMARY` while sunset is `NO_EVENT POLAR_DAY`.

| Reference event | Engine answer that agrees | Otherwise |
|---|---|---|
| `PRIMARY` sunrise/sunset | `PRIMARY`, `\|raw − reference\| ≤ toleranceMs` (ADR-019 altitude formula, 0.2–60 s) | `INSTANT` or `ORIGIN`, `UNKNOWN`, blocks |
| `PRIMARY` transit (Dhuhr) | `PRIMARY`, `\|raw − reference − offset\| ≤ 200 ms` | whole-minute residual: `DHUHR_OFFSET`; else `INSTANT`; `UNKNOWN`, blocks |
| `NO_EVENT` (`POLAR_DAY` / `POLAR_NIGHT`) | `NO_EVENT` with the **same** reason, or a typed `FALLBACK` | `ORIGIN`, `UNKNOWN`, blocks |
| `NEAR_TANGENT` (grazing crossing) | `PRIMARY` within 60 s | `NEAR_TANGENT`, `REFERENCE_AMBIGUITY`, does not block |
| `AMBIGUOUS` | — | `AMBIGUOUS_REFERENCE`, `REFERENCE_AMBIGUITY`, does not block |

A `FALLBACK` where the reference has a root is always a mismatch (`REQ-DOM-002`). A bench failure line blocks. Only allow-listed profiles are compared: `[benchmark] profiles`, currently `engine.default`.

The ephemeris is cached in `.cache/` (or `$DM_LAB_CACHE`) and verified by sha256 before every use.
