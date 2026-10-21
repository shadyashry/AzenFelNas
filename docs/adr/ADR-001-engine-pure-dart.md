# ADR-001 · Engine: pure Dart, FFI-shaped API, Rust only on trigger

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-001 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

`geo_salah_core` is pure Dart; the public API takes/returns plain serialisable records (no object graphs, no callbacks). Native layers never calculate (ADR-002). Rust port trigger: standalone-watch (LTE) requirement, or a measured need to calculate inside a native extension; the golden corpus makes the port safe.

## Trade-offs

- **Win:** one hot-loop language, fast iteration, trivial desktop lab runs (`dart run`).
- **Lose:** engine cannot run in extensions — mitigated by the precomputed plan.

## Performance baseline (slice S06, 2026-10-21)

- `CalculateRange` (§6.3) calculates 1–400 days and shares SPA samples between neighbouring days through a per-call cache, without changing any value (§15 D47).
- `REQ-PERF-001` desktop baseline, AOT build, Intel Core Ultra 7 155H: a one-year range takes 27–39 ms per city, median of 5 (§15 D49). The Galaxy A50 measurement (< 500 ms) and the Pixel 8 one (< 150 ms) are still owed. Nothing so far points at the Rust trigger.

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

`REQ-PERF-001` (baseline only), `REQ-DOM-004` (range = days)

## Tests

- `packages/geo_salah_core/test/api/calculate_range_test.dart`: a range is bit-identical to `calculateDay` day by day; 2N + 3 SPA samples for N days.
- `packages/geo_salah_core/tool/range_baseline.dart`: the REQ-PERF-001 timing tool (not a CI gate).

## Supersedes

—
