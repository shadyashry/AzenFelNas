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

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

—

## Tests

—

## Supersedes

—
