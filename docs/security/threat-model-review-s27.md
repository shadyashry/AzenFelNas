# Threat-model review before MVP beta (S27)

**Scope:** DESIGN.md §10.1 controls against what S01–S26 built. This is an engineering review written from the repository; **sign-off by Security (A) and the Architect (R) is owed** (§23.1). STRIDE per asset; "Evidence" names the test or file that holds the control.

| # | Asset / flow | Threat (STRIDE) | Control | Evidence | Status |
|---|---|---|---|---|---|
| 1 | Packages from the CDN | Tampering, Spoofing | TUF-lite chain, Ed25519 over JCS, sha256 content addressing, schema + compat check before activation | `dm_packages` verify tests, `gsctl` round-trip vectors (REQ-DIST-001/003/004, REQ-PKG-001/006) | Held |
| 2 | Packages from the CDN | Freeze / rollback attack | strictly higher sequence; expiry warns, never blocks; signed rollback is a higher sequence | REQ-PKG-005, REQ-PKG-002, REQ-DIST-002 tests; S27 rollback drill | Held |
| 3 | Signing keys | Theft of root | 3 offline root holders, threshold 2; ceremony on air-gapped hardware tokens | `docs/release/key-ceremony.md` | **Owed** (ceremony not held) |
| 4 | Signing keys | Theft of targets | Cloud KMS, signable only by the GitHub environment through WIF with required reviewers | `infra/terraform/distribution/kms.tf`, §15 D85 | Held in code; **owed** apply + reviewers |
| 5 | Signing keys | Theft of timestamp/snapshot | Environment secrets; 168 h / 720 h lifetimes bound the damage | `refresh-timestamp.yml`, key-compromise.md | Held |
| 6 | Alarm path | Spoofing a broadcast | `exported=false` receivers, `FLAG_IMMUTABLE`, ids derived from entry ids | REQ-ALM-021 Kotlin tests | Held (device run owed, S21) |
| 7 | Native plan | Tampering / partial write | whole-document replace (write + rename); older generation refused; app plans before flipping a package pointer | Kotlin `PlanStoreTest`, Swift plan store tests, `plan_host_contract_test.dart`, `rollback_drill_test.dart` (REQ-ALM-035) | Held |
| 8 | Deep links | Elevation via crafted link | allow-list + validation before navigation | REQ-SEC-010 test in `app_shell_test.dart` | Held |
| 9 | Logs / telemetry / diagnostics | Information disclosure of location | ≤ 2 decimals schema ban, egress allow-list, diagnostic rounding to 0.01°, 24 h logs | REQ-PRIV-001/005/006 tests; D86 access-log scan | Held |
| 10 | Control plane API | Spoofed client / abuse | Play Integrity / App Attest on writes, fail-closed per platform; 10 corrections per key per UTC day | REQ-API-004, REQ-PRIV-007 tests | Held; iOS root CA **owed** |
| 11 | Control plane API | Telemetry flood (unattested) | Cloud Armor edge throttle only | `infra/terraform/control-plane` | **Residual**, accepted for beta (Security to confirm) |
| 12 | Control plane API | Pseudonym linkability | `sha256(keyId + dailySalt)`, salt rotates daily, rows purged at 24 h | REQ-PRIV-007, REQ-DATA-002 tests | Held |
| 13 | Corrections | Disclosure via free-text `note` | none beyond length limit | D86 | **Open**: Privacy review (S26 hand-over) |
| 14 | Supply chain | Malicious dependency | lockfiles in every ecosystem, pinned versions, digest-pinned images, licence table (ADR-011) | `pubspec.lock`, `go.sum`, `uv.lock`, Dockerfile digests | Held |
| 15 | Supply chain | No SBOM per release | syft SBOM + licence notices per release | none yet | **Open** (REQ-SEC-040, §15 D87) |
| 16 | CI | Secret in repo / long-lived creds | OIDC/WIF only; no private keys committed; dev keys only for dev/lab | REQ-SEC-030; `tools/gsctl/keys/dev/README.md` | Held |
| 17 | Local data | Device theft | platform file encryption; `places.sqlite` excluded from backup | ADR-024, REQ-PRIV-003 | Held |

## Decisions asked of Security
1. Accept #11 for beta, or require attestation on telemetry before beta.
2. #15: the SBOM job (syft, Apache-2.0) before closed beta. The engineering default is a release-workflow step, recorded in §15 D87.
3. #13: drop `note`, or keep it with a client-side length cap and a warning that says "no personal details".
