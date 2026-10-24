# ADR-009 · Distribution: static, signed, TUF-lite; no runtime prayer API

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-009 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Object storage + CDN; four metadata roles; monotonic `sequence`; signature envelope over JCS-canonical JSON (Appendix C). Rollback = new manifest with a higher sequence pointing at old content.

## Trade-offs

- **Win:** cheap, cacheable, resists freeze/rollback/CDN compromise.
- **Lose:** client-side verification code (small, specified).

## Implementation (slice S09, 2026-10-22)

- **Signing side, `tools/gsctl`** (Go, hexagonal, §17.5): `validate | build | sign | verify`. JCS is RFC 8785 (`internal/domain/jcs`). Signatures are Ed25519 over JCS of `signed`; keyId follows §15 D17. Each role signs separately with its own keys; roles have the Appendix C thresholds and strictly monotonic sequences (§15 D59). `build` turns the profiles into the `prayer_profiles` package (§15 D60).
- **Verifying side, `packages/dm_packages`**: the minimal `VerifyMetadataChain` and `VerifyTargetFile` (§15 D63). S14 builds the package client around them.
- **Cross-language evidence:** both languages pass one set of JCS vectors (`tools/gsctl/testdata/jcs`). A dev channel that gsctl signed with the dev keys (`tools/gsctl/testdata/roundtrip`) verifies in Go and in Dart.
- **Keys:** the dev key set and how gsctl loads private keys without them touching the repository are recorded in §15 D62. Production keys arrive with S25 (KMS) and S27 (root ceremony).

## Live channels and promotion (slice S25, 2026-10-24)

`release-package` pulls the live channel from R2 before signing, so sequences keep increasing on fresh runners (REQ-DIST-002); `promote-package` stages the reviewed targets sequence of the channel below unchanged; `refresh-timestamp` re-signs the timestamp daily. The app syncs on open with the dev root keys on `dev`/`lab`; `tools/gsctl/scripts/lab-e2e.sh` is the end-to-end done-test (§15 D85).

## Consequences

- A client verifies root against its embedded keys, then timestamp → snapshot → targets. It accepts only sequences strictly after the ones it trusts; expiry is a warning only.
- A rollback is `gsctl build -rollback-of <version>` of the old content under a new version, followed by new signatures with higher sequences. Published target names never change content.
- Until S25 the distribution plane is local (§15 D65). `gsctl publish` writes a verified channel into a bucket directory in the §9.1 layout and cache policy, and `gsctl serve` serves it on loopback like the CDN. `release-package` publishes into such a directory and uploads it as an artifact. S25 adds the R2 adapter behind the same `ObjectStore` port, plus `gsctl promote`.

## REQ tags

`REQ-DIST-001`, `REQ-DIST-002`, `REQ-DIST-003`, `REQ-DIST-004`, `REQ-DIST-005`, `REQ-DIST-006` (local stand-in), `REQ-PKG-002`, `REQ-PKG-005`

## Tests

- `tools/gsctl/internal/domain/trust/trust_test.go`: the sign → verify round trip and every flipped bit of every metadata file. Also sequence regression, Appendix C thresholds, target immutability, the 7-day timestamp limit and expiry warnings.
- `tools/gsctl/internal/app/app_test.go`: build → sign → verify over port fakes, rollback as a higher sequence, and refusal of a republished version or of key-config drift.
- `tools/gsctl/internal/domain/distribution/distribution_test.go`, `internal/app/publish_channel_test.go`, `internal/adapters/localbucket/localbucket_test.go`, `distribution_commands_test.go`: the bucket layout and cache policy, publish monotonicity and immutability, and the local CDN.
- `tools/gsctl/main_test.go`: the CLI done-test (sign → verify, tampered metadata and package, sequence regression) and the committed vector.
- `packages/dm_packages/test/tuf/go_round_trip_test.dart`: the Go-signed vector verifies in Dart, while tampering and sequence regressions fail.
- `tools/gsctl/internal/app/pull_promote_test.go`, `internal/adapters/s3bucket/s3bucket_test.go`, `internal/adapters/kmskeys/kmskeys_test.go`: pull continues the live sequences, promotion keeps targets unchanged, the R2 adapter contract and cache policy, the KMS signer (S25).
- `apps/mobile/test/features/packages/lab_sync_end_to_end_test.dart` via `tools/gsctl/scripts/lab-e2e.sh`: the app syncs a lab channel gsctl published (S25 done-test).
- `tools/gsctl/internal/domain/jcs/jcs_test.go` and `packages/dm_core_types/test/canonical_json_test.dart`: the shared JCS vectors.

## Supersedes

—
