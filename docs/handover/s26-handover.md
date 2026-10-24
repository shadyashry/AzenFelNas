# S26 hand-over (control plane: API, attestation, Postgres, OTel, Cloud Run) → S27

Branch `slice/s26-control-plane`, cut from `slice/s25-distribution-infra` at `ff48b9d`. No PR (owner rule of 2026-10-22, S17 hand-over); review the branch directly. Setup: `docs/handover/cloud-environment.md`; its script worked as written, and the new S26 section adds Postgres and sqlc. Mechanics and every engineering default are in §15 **D86**.

## Built
- **Schemas first (ADR-023):** `correction_request.v1`, `correction_receipt.v1`, `problem_details.v1`, `evidence_summary.v1`, each with valid and invalid fixtures. The API validates bodies against byte-identical embedded copies (REQ-API-005).
- **`services/control-plane`** (hexagonal, §9.3):
  - `domain`: corrections with ≤ 2-decimal coordinates, the daily pseudonym, retention cutoffs and telemetry rows.
  - `app`: four use cases. `ports`: nine small interfaces, with a shared contract suite in `porttest`.
  - Adapters: `http`, `memory`, `postgres` (pgx + sqlc + goose) and `attest` (Play Integrity, App Attest).
  - The `http` adapter returns RFC 9457 problem details with the trace id, enforces 5 s and 64 kB, requires `Idempotency-Key` with replay/422/409, and logs one line per request with no address, agent, keys or body.
  - `cmd/api serve|migrate|purge` is the composition root. Each platform's attestation fails closed until it is configured.
- **Deploy:**
  - A distroless Dockerfile pinned by digest. It was built here, and `migrate`, `serve` and `purge` were smoke-run against Postgres 16.15.
  - `infra/terraform/control-plane` (validate only) contains:
    - Cloud Run with an OTel collector sidecar, the migrate and purge jobs, and an hourly scheduler.
    - Cloud SQL PG16 with PITR, Artifact Registry and Secret Manager.
    - A global LB with a managed certificate and Cloud Armor throttle, plus the Cloudflare DNS record.
    - A 24 h log bucket, the 99.5 % SLO with burn-rate and uptime alerts, and the WIF deploy identity.
  - `deploy-control-plane.yml` runs test → build/push → migrate job → roll → smoke test. `ci-go` gains Postgres and an sqlc drift check; `ci-infra` validates the new module.

## Evidence (this session, Linux)
- `dart run melos run ci`: **SUCCESS**.
  - App: 391 passed + 1 skipped (unchanged).
  - arch_lint 0 violations in 632 files; req_index 0 problems in 1697 files.
- `services/control-plane`: vet, `test -race` and golangci-lint 0 issues. **44 top-level tests (64 subtests) pass** with `DM_PG_TEST_URL` set; without it, 3 Postgres tests skip.
- `tools/gsctl`: vet, `test -race` and golangci-lint 0 issues (untouched).
- `schemas/tools/validate_fixtures.sh`: exit 0 (167 ok).
- `terraform fmt -check` and `validate`: "Success! The configuration is valid." for both `distribution` and `control-plane`.
- `docker build services/control-plane`: OK.
- The engine and lab are untouched, so the lab was not run.

## REQ IDs proved by named tests
- REQ-API-001: problem details for every error class, plus incoming trace id propagation.
- REQ-API-002: 413 over 64 kB; deadline → 503 problem.
- REQ-API-003: replay, mismatch, in-flight, release.
- REQ-API-004: missing, forged and malformed attestations; Play Integrity verdicts; App Attest attestation, assertion, replay and forgery cases; fail-closed wiring; rejected attestations spend no allowance.
- REQ-API-005: fixtures pass or fail in Go; unknown keys; trailing data.
- REQ-API-006: no identity; telemetry needs no attestation.
- REQ-PRIV-001: coordinate precision; access-log scan.
- REQ-PRIV-007: 10 per key per UTC day with `Retry-After`; atomic under 25 concurrent requests; the pseudonym changes with the salt.
- REQ-DATA-002: purge cutoffs on both stores.
- REQ-TEST-004: memory and Postgres pass one port contract.

## §15 rows and ADRs
- **D86** (new). The §26 sketch line now points to it.
- ADR-010 gets its long form and S26 implementation notes; ADR-022 gets an S26 section.
- ADR-011 table:
  - pgx 5.11.0 and goose 3.28.0 (3.29.0 was < 2 weeks old).
  - sqlc 1.31.1 (tool only), jsonschema 6.0.3, zerolog 1.35.1, OTel 1.47.0 / otelhttp 0.72.0 and cbor 2.9.6.
  - The pinned images.
  - All 41 linked modules are MIT, Apache-2.0 or BSD (checked from their LICENSE files).

## Owed / open
- **Owner, cloud:**
  - Run `terraform apply` for `control-plane` with `db_password` (write-only), `alert_email`, `workload_identity_pool_name` and `otel_collector_image` (pin a Google-built collector by digest).
  - Add the `control-plane-database-url` secret version (`host=/cloudsql/<connection> user=api dbname=controlplane password=…`).
  - Create the GitHub environment `control-plane` with required reviewers and the variables `GCP_PROJECT_ID`, `GCP_WORKLOAD_IDENTITY_PROVIDER` and `GCP_DEPLOY_SERVICE_ACCOUNT`.
  - Link the GCP project in Play Console (Play Integrity).
  - Nothing was applied or deployed from here.
- **Owner/Security:**
  - Supply the **Apple App Attestation Root CA** PEM from apple.com (`appattest_root_ca_pem`) and the iOS `<team>.<bundle>` id. iOS writes return 503 until then.
  - Optionally list the Android signing digests.
- **Device (owed, never simulated):**
  - The app client for the attestation headers, the corrections UI and the telemetry sender. No Dart client was written in S26.
  - A real Play Integrity token round-trip, and a real App Attest attestation/assertion on a device. The App Attest signature form follows Apple's documentation and published server libraries and must be confirmed on a device.
- **Open:**
  - Wire the lab's evidence publish step to `PutEvidence`.
  - Abuse of unattested telemetry relies on the edge throttle only.
  - A correction review tool (`status`/`reviewed_by`) for the weekly triage (§9.3).
  - The free-text `note` is a privacy item for the Privacy reviewer.
- **Carried:** every S25 owed item (state bucket, R2 token, KMS level, `minAppVersion` of the seeds, production keys) and the earlier S17/S23/S24 items.

## §17.8 self-review
1. **One reason to change per type:** yes. Platforms are dispatched through `attest.ByPlatform`, and claim outcomes use an exhaustive switch.
2. **Layer boundaries:** wiring happens only in `cmd/api`, and use cases depend on ports only.
3. **Error handling:** every ignored error carries a justification comment. There are no `any` in the domain or app layers (only JSON helpers).
4. **Failure mapping:** every error maps to a catalogued problem.
5. **Contracts:** contracts are schemas, and port contract tests run on both adapters.
6. **Hard-coded values:** nothing religious, locational or zone-related is hard-coded.
7. **Test names:** tests are named by REQ and behaviour, with fakes only at ports (verifier, clock, slow evidence store).
8. **Contract changes:** schemas came first, the ADRs were updated, and sqlc and the schema copies are drift-checked.

## Inputs for S27 (key ceremony, runbooks, release checklist, beta)
- The runbook `control-plane-restore.md` (§19.4) can use Cloud SQL PITR, `terraform apply`, `deploy-control-plane` and its smoke test.
- Alerts exist for the SLO burn rate and `/readyz`; the alert catalogue (§19.2) should reference them.
- The threat-model review should cover the D86 attestation design, the edge throttle, the 24 h logs and the pseudonym.
