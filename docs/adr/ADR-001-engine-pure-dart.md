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

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

—

## Tests

—

## Supersedes

—
