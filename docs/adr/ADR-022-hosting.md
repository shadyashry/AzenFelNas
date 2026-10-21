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

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

—

## Tests

—

## Supersedes

—
