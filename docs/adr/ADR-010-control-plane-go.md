# ADR-010 · Control plane: Go + Postgres, hexagonal, three endpoints

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-010 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Only non-static writes: corrections, aggregate telemetry, evidence summaries. Device attestation replaces accounts for rate limiting (`REQ-PRIV-007`).

## Trade-offs

- **Win:** boring, one binary.
- **Lose:** a fourth language (Go server/CLI only; Python lab/pipelines only).

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

`REQ-PRIV-007`

## Tests

—

## Supersedes

—
