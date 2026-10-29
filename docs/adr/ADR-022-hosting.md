# ADR-022 · Hosting: Cloudflare R2 + CDN for distribution; Google Cloud Run + Cloud SQL (Postgres 16) for the control plane; Terraform IaC

- **Status:** `[DECIDED · revisit D13]`
- **Source:** `DESIGN.md` §4 ADR-022 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Recorded in `DESIGN.md` §4; no further text in the index.

## Trade-offs

- **Win:** zero-egress object storage for a global free app; managed Postgres; one container.
- **Lose:** two vendors (acceptable — distribution and control plane are independent by design). Region `europe-west1`; no identity is stored, so residency concerns are limited to transient IP (§24).

## Local stand-in before S25 (slice S09, 2026-10-22)

Until S25 provisions R2 and the CDN, the distribution plane runs locally: `gsctl publish` writes channels into a bucket directory in the §9.1 layout with each object's Cache-Control, and `gsctl serve` serves it on loopback (§15 D65). The R2 adapter replaces the local bucket behind the same `ObjectStore` port. Layout, cache policy and publish rules carry over unchanged.

## Infrastructure as code (slice S25, 2026-10-24)

`infra/terraform/distribution` declares the R2 bucket `dm-dist` (location hint WEUR, a per-channel lock on `packages/`), the custom domain `cdn.azenfelnas.app` (r2.dev off), one cache rule that respects the Cache-Control `gsctl publish` stores, a GET/HEAD-only rule, and the Cloud KMS key ring with an Ed25519 targets key per beta/production, reachable only from the matching GitHub environment through workload identity federation. `ci-infra` runs `fmt` and `validate`; nothing is applied from CI. `gsctl` reaches R2 through `s3bucket` behind `ports.ObjectStore`, unchanged elsewhere (§15 D85).

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

—

## Tests

—

## Supersedes

—

## Control plane (slice S26, 2026-10-24)

`infra/terraform/control-plane` (validate only, like `distribution`): Cloud Run service `control-plane` (internal-LB ingress, 0–3 instances, OpenTelemetry collector sidecar), Cloud Run jobs `control-plane-migrate` and `control-plane-purge` (hourly via Cloud Scheduler), Cloud SQL `POSTGRES_16` in europe-west1 with PITR 7 d, Artifact Registry with immutable tags, Secret Manager for `DM_DATABASE_URL`, and a global external Application Load Balancer with a Google-managed certificate and a Cloud Armor throttle for `api.azenfelnas.app` (DNS-only record in Cloudflare). Control-plane logs live 24 h in a dedicated bucket. The deploy identity is a workload-identity binding on the existing `github` pool for the `control-plane` GitHub environment. Rationale and defaults: §15 D86.

