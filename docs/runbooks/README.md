# Runbooks (DESIGN.md §19.4)

Each runbook names its trigger, its owner role, the exact commands and how to verify the result. Named owners are filled in at the go/no-go (`docs/release/checklist.md`); until then the role in the table is accountable (§23.1).

| Runbook | Trigger | Owner role | Severity (§19.3) |
|---|---|---|---|
| [tzdb-emergency.md](tzdb-emergency.md) | IANA release or a TZ-law change in a launch country | Backend/Data | SEV2 (SLA 48 h, REQ-OPS-001) |
| [package-rollback.md](package-rollback.md) | A published package gives wrong times or breaks the app | Release manager | SEV1 on `production` |
| [key-rotation.md](key-rotation.md) | Planned rotation, root expiry within 60 days, a holder leaves | Security | — |
| [key-compromise.md](key-compromise.md) | A signing key is exposed or suspected exposed | Security | SEV1 |
| [hijri-announcement.md](hijri-announcement.md) | Official month announcement in a launch country | Backend/Data + Sharia board | SEV2 (SLA 6 h, REQ-OPS-002) |
| [wrong-time-report.md](wrong-time-report.md) | A correction or support report says a time is wrong | Accuracy lead | SEV1 if a pattern on `production` |
| [control-plane-restore.md](control-plane-restore.md) | Control plane data loss, region failure, bad migration | Backend | SEV3 |

## Alert catalogue (§19.2) → where it is implemented

| Alert | Implemented by | Runbook |
|---|---|---|
| `timestamp` expiring < 48 h | `refresh-timestamp.yml` re-signs daily; a failed run notifies through GitHub (owner: enable workflow failure e-mail) | package-rollback.md §Timestamp |
| publish job failed | `release-package.yml` / `promote-package.yml` failure | package-rollback.md |
| verification-canary signature mismatch | `gsctl verify` step in every release job; a scheduled canary is **open** (§15 D87) | key-compromise.md |
| attestation failure rate > 20 % | `control-plane attestation failure rate above 20 %`: log-based metrics over the D86 access log (401 share of POSTs, 1 h, ≥ 20 writes) in `infra/terraform/control-plane/dashboard.tf` (S28, §15 D88) | key-compromise.md (attestation keys), control-plane-restore.md |
| control plane 5xx > 1 % | `control-plane SLO burn rate` (99.5 % SLO, 1 h burn > 10×) in `infra/terraform/control-plane/observability.tf` | control-plane-restore.md |
| `/readyz` failing | `control-plane /readyz failing` uptime alert | control-plane-restore.md |
| Postgres disk > 80 % | `control-plane Postgres disk above 80 %` (`cloudsql.googleapis.com/database/disk/utilization` > 0.8 for 10 min) in `dashboard.tf` (S28) | control-plane-restore.md |
| upstream IANA release detected | **open**: `git ls-remote https://github.com/eggert/tz` tag watch (§15 D87) | tzdb-emergency.md |
| Hijri boundary within 3 days without confirmation | **open**: needs the `hijri` package type (no reader in this build, REQ-PKG-006) | hijri-announcement.md |

## Ops dashboard (S28)
`google_monitoring_dashboard.ops` ("Daily Muslim ops (V1)") in `infra/terraform/control-plane/dashboard.tf`: requests by response class, p95 latency, the 99.5 % SLO error budget, attestation failure share, Postgres disk, attested writes per hour and the `/readyz` check. Distribution alerts stay in the GitHub workflows above. Applied with the rest of the control plane (owner: `terraform apply`).

## On-call and drills
- Weekly rotation across the mobile and backend leads in Ramadan ± 2 weeks and in release weeks; business hours otherwise (§19.4).
- Quarterly drills: Cloud SQL restore (control-plane-restore.md), package rollback on `lab` (package-rollback.md), timestamp expiry rehearsal. The automated half of the rollback drill is `apps/mobile/test/features/packages/rollback_drill_test.dart` (S27 done-test).
- Blameless review within 5 working days; findings become ADRs or tests.
