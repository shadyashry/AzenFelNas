# ADR-019 · Determinism and verification policy

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-019 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Cross-platform conformance: raw instants truncated to 1 ms must be identical. Golden corpus = the **engine's own outputs**, frozen after the lab confirms each within tolerance of Skyfield + JPL `de440s.bsp`: altitude 0.001°, time `tol_s = clamp(0.001° / |dh/dt|, 0.2 s, 60 s)` with `dh/dt` in °/s at the event. SPA (Reda & Andreas 2008) is implemented **from the paper** — no NREL source code is ported. ΔT = Espenak–Meeus (2006) polynomials (`deltaTModel = "espenak-meeus-2006"`); UT1−UTC ignored (≤ 0.9 s, documented).

## Trade-offs

- **Win:** —
- **Lose:** —

## Reference harness (slice S03, 2026-10-21)

The lab side of this ADR is frozen in S03, before the engine exists (kickoff §C). It is realised as follows; the tolerance part of the decision was amended on 2026-10-21 (§15 D26, §4 text updated):

- **Reference:** Skyfield 1.55 over JPL `de440s.bsp`, pinned by sha256 and never committed (§15 D28). Positions are the apparent topocentric Sun centre, observer on WGS84 at 0 m, geometric altitude with no refraction (ADR-003).
- **Time scales:** UT1 ≡ UTC is realised as ΔT = 69.184 s, guarded against the leap-second table (§15 D25).
- **Prayer day:** ADR-004 culmination segments; sunrise and sunset at −(34′ + 16′) from `lab/config/harness.v1.toml`.
- **Tolerance (decision amended 2026-10-21, §15 D26):**
  - Sunrise/sunset: `clamp(0.001° / |dh/dt|, 0.2 s, 60 s)` where `|dh/dt| ≥ 0.001° / 60 s`. Slower crossings are reported `NEAR_TANGENT` and graded explicitly, never with a capped tolerance.
  - Dhuhr: not altitude-defined, so it has a fixed 0.2 s time tolerance (required accuracy and reference precision, not an angle rate). A Dhuhr offset is checked separately (`DHUHR_OFFSET`).
- **Frozen artifact:** `lab/reference/sun_events.2026-2028.v1.jsonl` (`lab_reference.v1`, 4 188 city-days) with a `pipeline_manifest.v1` of input hashes. Two runs on one platform are byte-identical; across platforms, regeneration is checked within 1 ms (libm), as §15 D25 states. The manifest also hashes the reference-deciding lab code, and changes under `lab/reference/` need the `reference-update` label (CODEOWNERS `/lab/`).
- **Comparison:** `lab benchmark` runs the engine bench JSONL contract (§15 D29) and writes `discrepancy_report.v1`.
- **Done-test evidence:** published equinox/solstice sunrise (MET Norway, §15 D31) for Cairo, Makkah and London falls in the published (truncated) minute; a wiring check matches Skyfield's own rise/set/transit finders to ≤ 2 ms.

## Engine side (slice S04, 2026-10-21)

Written without reading `lab/` beyond `lab/README.md` (kickoff §C).

- **SPA from the paper:** the term tables (A4.2, A4.3) were transcribed from the paper's text (NREL/TP-560-34302, revised January 2008), not from NREL code. The implementation reproduces Table A5.1 to its printed precision: L, B, R, Δψ, Δε, ε, λ, α, δ, α′, δ′, zenith, azimuth, and the L0–R4 partial sums. One erratum is recorded in the test: the table's H′ disagrees with its own H − Δα by 2·10⁻⁵°.
- **ΔT:** Espenak–Meeus at a continuous decimal year (§15 D32).
- **Interpolation and EoT:** §15 D33. The exact-hour-angle EoT keeps the transit exact. The paper's A1 approximation would cost ≈ 0.2 s, the whole Dhuhr tolerance. The engine's transit for the paper example is 0.02 s from the paper's A.2 value.
- **Solver:** Brent to 100 ms on the interpolated altitude, one exact SPA Newton step, then floor to 1 ms. Brackets come from monotone pieces (§15 D34).
- **Determinism:** inside the engine, repeated runs give bit-identical instants. Across platforms, `dart:math` uses the platform libm, so an instant within about 1 µs of a millisecond boundary can truncate differently. This is the same ±1 ms caveat as D25, to be measured by the golden corpus in S05.

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

`REQ-TEST-003`, `REQ-TIME-002`, `REQ-DOM-002` (comparator; engine solver), `REQ-DOM-004` (engine truncation)

## Tests

- `lab/tests/test_published_sun_events.py` — S03 done-test against published sunrise.
- `lab/tests/test_reference.py`, `test_tolerance.py`, `test_segment.py` — segments, polar outcomes, tolerance properties.
- `lab/tests/test_compare.py`, `test_bench.py` — comparator and bench contract.
- `lab/tests/test_frozen_reference.py` — artifact integrity, coverage and regeneration.
- `packages/geo_salah_core/test/astro/spa_paper_example_test.dart` — SPA paper Tables A4.1 and A5.1.
- `packages/geo_salah_core/test/solver/crossings_test.dart` — exhaustiveness, accuracy against exact SPA, determinism, and the paper's A.2 sunrise and sunset.

## Supersedes

—
