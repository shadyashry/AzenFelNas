# ADR-010 · Control plane: Go + Postgres, hexagonal, three endpoints

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-010 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

The app needs exactly three non-static writes or reads that a CDN cannot serve: explicit user corrections, opt-in aggregate telemetry and evidence summaries (§9.3). Everything religious or time-related stays on the static, signed distribution plane (ADR-009). The service must never create or need a user identity (REQ-API-006) while still limiting abuse.

## Decision

Only non-static writes: corrections, aggregate telemetry, evidence summaries. Device attestation replaces accounts for rate limiting (`REQ-PRIV-007`).

## Trade-offs

- **Win:** boring, one binary.
- **Lose:** a fourth language (Go server/CLI only; Python lab/pipelines only).

## Consequences

See the `DESIGN.md` sections referenced above.

## Implementation (slice S26, 2026-10-24)

Hexagonal as §9.3 lays out: `cmd/api` is the only composition root (`serve`, `migrate`, `purge`); `internal/domain` holds the pure rules (corrections, the daily pseudonym, retention cutoffs, telemetry flattening); `internal/app` has one use case per type (`SubmitCorrection`, `RecordTelemetry`, `GetEvidence`, `PurgeExpired`); `internal/ports` declares nine small interfaces; adapters are `http` (thin handlers, problem details, limits, idempotency), `postgres` (pgx + sqlc + goose), `memory` (the test fake, contract-tested against the same suite as Postgres), and `attest` (Play Integrity, App Attest). Wire contracts are JSON Schemas in `schemas/`, validated at the edge. Mechanics and every engineering default are in §15 D86.

## REQ tags

`REQ-PRIV-007`, `REQ-API-001`..`REQ-API-006`, `REQ-DATA-002`

## Tests

`services/control-plane/internal/adapters/http/router_test.go` (REQ-API-001..006, REQ-PRIV-007 over HTTP), `internal/ports/porttest` run by `memory` and `postgres` (REQ-TEST-004, REQ-DATA-002), `internal/adapters/attest` (REQ-API-004), `cmd/api/main_test.go` (composition root).

## Supersedes

—
