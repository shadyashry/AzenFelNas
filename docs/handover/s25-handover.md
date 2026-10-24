# S25 hand-over (distribution infra + release-package + promote) → S26

Branch `slice/s25-distribution-infra`, cut from `slice/s24-privacy-hardening` at `0d0add2`. No PR, per the owner rule of 2026-10-22 (S17 hand-over): review the branch directly. Setup: `docs/handover/cloud-environment.md`. Its script worked as written; the S25 section adds Terraform and an S3 test server. Mechanics are in §15 **D85**.

## Built
- **gsctl:**
  - `s3bucket` is the R2 adapter behind `ports.ObjectStore` (minio-go 7.3.0), selected with `-bucket s3://…`.
  - `cdnstandin` is the shared read-only handler, so `serve` can front R2.
  - `pull` restores a verified live channel, so sequences continue on fresh runners.
  - `promote -from -to -sequence N` stages the reviewed targets unchanged (dev→lab until S27).
  - `kmskeys` and `sign -kms` sign through the Cloud KMS REST API with an OIDC token. `Signer.Sign` now takes a context.
- **infra/terraform/distribution** (validate only):
  - R2 `dm-dist` with a lock on packages and the custom domain `cdn.dailymuslim.app`.
  - A cache rule that respects the stored Cache-Control, a GET/HEAD-only rule, and no Logpush.
  - A KMS Ed25519 targets key per beta/production, with workload-identity signers bound to their GitHub environment.
- **Workflows:**
  - `release-package` now does pull → build → sign → verify → publish to R2 (it no longer fails closed).
  - New: `promote-package`, `refresh-timestamp` (daily) and `ci-infra`.
  - `ci-go` gains SeaweedFS for the live S3 tests and a `lab-e2e` job.
- **App:**
  - `SyncPackages` is wired in `di.dart` and runs once per process on open (`packageSyncProvider`).
  - dev and lab embed the dev root keys (test-guarded); `AssumeMeteredNetwork` stands in for a connectivity plugin; `HttpCdnChannel.cdn` owns its client.
- **Done-test:** `tools/gsctl/scripts/lab-e2e.sh`:
  - Ephemeral keys, then two lab releases (the second on a fresh runner after `pull`) into a bucket.
  - `gsctl serve` fronts the bucket, and `lab_sync_end_to_end_test.dart` syncs with the app's wiring.
  - The test checks that the newest package activates, a re-open inside 6 h is skipped, and the 6 h re-sync reports `upToDate`.

## Evidence (this session, Linux)
- `dart run melos run ci`: **SUCCESS**.
  - App: 391 passed + 1 skipped (390 before; +1 dev-root-keys test, +1 env-gated e2e).
  - analyze clean; arch_lint 0 violations in 632 files; req_index 0 problems in 1629 files.
- Go `tools/gsctl` and `services/control-plane`: vet, `test -race` and golangci-lint 0 issues. gsctl has 91 top-level tests passing with the live S3 tests on.
- `lab-e2e.sh`: exit 0 with the local bucket, and exit 0 with `s3://dm-dist-e2e` on SeaweedFS 4.00: `+1: All tests passed!`.
- `terraform fmt -check` and `validate`: "Success! The configuration is valid." (providers from a local mirror, checksums verified).
- No schema changed, so `validate_fixtures.sh` was not needed. The engine and lab are untouched.

## REQ IDs proved by named tests
REQ-DIST-002, REQ-DIST-003, REQ-DIST-004 (KMS), REQ-DIST-005 (R2 cache policy), REQ-GOV-004 (promotion keeps `effectiveFrom`), REQ-PKG-001, REQ-PKG-004, REQ-PKG-005 (e2e), REQ-SEC-030 (KMS config), REQ-DIST-001 (embedded root), REQ-TEST-004 (S3 and KMS contracts).

## §15 rows and ADRs
- **D85** (new). D65 now points to it.
- ADR-009 and ADR-022 gain S25 sections.
- ADR-011 lists minio-go 7.3.0 (Apache-2.0, transitive licences checked) and Terraform 1.16.5 / cloudflare 5.27.0 / google 8.6.0.
- `.tool-versions` adds terraform. §5.3 lists the new workflows.

## Owed / open
- **Owner, cloud accounts:**
  - Create the state bucket, then `terraform init -backend-config=bucket=…` and `apply` (never run here).
  - Create the bucket-scoped R2 token and set `DM_S3_ACCESS_KEY_ID`/`DM_S3_SECRET_ACCESS_KEY` secrets and the `DM_S3_ENDPOINT` variable in the `dev`/`lab` environments.
  - Required reviewers on the beta and production environments (dual control).
  - Confirm that Cloud KMS accepts EC_SIGN_ED25519 at HSM level; otherwise set `kms_protection_level=SOFTWARE`.
  - **The `dev`/`lab` channels are not live yet:** the first `release-package` run makes them live.
- **Owner/Data (blocks testers on lab):** seed profiles declare `minAppVersion "1.0.0"`, the app is 0.1.0, and the app correctly refuses them (PKG_INCOMPATIBLE, observed). Lower the seeds' value through the profiles gate, or ship 1.0.0. The e2e uses a work copy.
- **Privacy:** Cloudflare's own log processing versus ADR-017's 24 h promise.
- **Security:** the R2 token is long-lived (no OIDC exchange for R2), an exception to REQ-SEC-030.
- **S27:**
  - Production root and targets keys; embed the beta/production roots (sync is off there until then).
  - Promotion to beta/production via `sign -kms`, plus the Appendix E payload check on promotion.
- **Carried:**
  - `CheckClockIntegrity` from `serverDateUtcMs`.
  - A connectivity adapter (payloads > 2 MB wait for `urgent`).
  - Activated packages take effect at the next start.
  - The earlier S17/S23/S24 items (compileSdk, `ApplyAthanPlan`, merged-manifest check).

## Inputs for S26 (control plane)
- Same Terraform conventions: `infra/terraform/<module>`, exact pins, `ci-infra` matrix entry, GCS backend prefix, validate only.
- The workload identity pool `github` already exists; reuse it for the deploy service account, with a condition on `assertion.environment`.
- Region europe-west1; `api.dailymuslim.app` is the only other allowed host.
