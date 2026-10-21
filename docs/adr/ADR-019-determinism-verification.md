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

The lab side of this ADR is frozen in S03, before the engine exists (kickoff §C). It is realised as follows (no change to the decision above):

- **Reference:** Skyfield 1.55 over JPL `de440s.bsp`, pinned by sha256 and never committed (§15 D28). Positions are the apparent topocentric Sun centre, observer on WGS84 at 0 m, geometric altitude with no refraction (ADR-003).
- **Time scales:** UT1 ≡ UTC is realised as ΔT = 69.184 s, guarded against the leap-second table (§15 D25).
- **Prayer day:** ADR-004 culmination segments; sunrise and sunset at −(34′ + 16′) from `lab/config/harness.v1.toml`.
- **Tolerance:** `tol_s = clamp(0.001° / |rate|, 0.2 s, 60 s)`. The rate is the altitude rate for sunrise/sunset and the local hour-angle rate for the transit (§15 D26).
- **Frozen artifact:** `lab/reference/sun_events.2026-2028.v1.jsonl` (`lab_reference.v1`, 4 188 city-days) with a `pipeline_manifest.v1` of input hashes. Regeneration with the same inputs is byte-identical.
- **Comparison:** `lab benchmark` runs the engine bench JSONL contract (§15 D29) and writes `discrepancy_report.v1`.
- **Done-test evidence:** published equinox/solstice sunrise (MET Norway, §15 D31) for Cairo, Makkah and London is reproduced within 60 s.

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

`REQ-TEST-003`, `REQ-TIME-002`, `REQ-DOM-002` (comparator)

## Tests

- `lab/tests/test_published_sun_events.py` — S03 done-test against published sunrise.
- `lab/tests/test_reference.py`, `test_tolerance.py`, `test_segment.py` — segments, polar outcomes, tolerance properties.
- `lab/tests/test_compare.py`, `test_bench.py` — comparator and bench contract.
- `lab/tests/test_frozen_reference.py` — artifact integrity, coverage and regeneration.

## Supersedes

—
