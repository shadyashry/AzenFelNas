> Copied from the local session notes so that sessions running elsewhere (e.g. in the cloud) can read it. Paths under `C:\Users\hp\...` refer to the original Windows workstation.

# S09 hand-over (gsctl + TUF-lite) → S10

Branch `slice/s09-gsctl-tuf`, cut from `main` at `ceb0a69` (S01–S08). Worktree: `C:\Users\hp\Projects\daily_muslim\.claude\worktrees\s09-gsctl-tuf-3a142a`. The eight commits below are **not pushed**:

1. `8c1dcf3 refactor(dm_core_types)`: `CanonicalJson` (RFC 8785) moves from `geo_salah_core` to `dm_core_types`. The code is unchanged, and the Calculation ID vector still passes.
2. `175aa66 feat(gsctl)`: `validate | build | sign | verify`, hexagonal Go.
   - `internal/domain/{jcs,trust,profileset,dmpkg}`, `internal/app` (one use case per type), `internal/ports`.
   - `internal/adapters/{yamlprofiles,fsrepo,keyfiles,pemkeys,sysclock}`; `main.go` + `commands.go` are the composition root.
   - New dependency `go.yaml.in/yaml/v3` 3.0.5 (MIT + Apache-2.0, no transitive modules).
3. `e4bdb34 fix(dm_core_types)`: the shared JCS vectors found two `CanonicalJson` bugs. An integral double ≥ 2^63 saturated (`1e20` → `9223372036854775807`), and ints beyond 2^53 were written exactly. Both now follow ECMAScript. No engine input reaches those magnitudes, so IDs are unchanged.
4. `68a9992 feat(dm_packages)`: the minimal verifier.
   - `VerifyMetadataChain`, `VerifyTargetFile`, `TrustedRoot`, `PackageFailure` (PKG_* codes), and the `VerifyEd25519` port with its `CryptographyEd25519` adapter (`cryptography` 2.9.0, Apache-2.0).
   - Dev role keys: `targets-1`, `snapshot-1`, `timestamp-1` (public halves plus `roles.json`).
   - The signed round-trip vector `tools/gsctl/testdata/roundtrip/dev`.
5. `9eb7c47 test(gsctl)`: port contracts for every port (REQ-TEST-004).
8. `5b59db0 feat(gsctl)`: a local distribution plane, built at the owner's request ("create it locally here and later we can create remotely", §15 D65).
   - `gsctl publish`, into a `dist/` bucket in the §9.1 layout and cache policy, and `gsctl serve`, a loopback stand-in for the CDN.
   - `ports.ObjectStore`, behind which S25 adds R2.
   - `keys/dev/load-ci-env.sh` (the local CI secrets) and `scripts/local-release.sh`.
   - `release-package` publishes into a bucket artifact.
7. `9b9c9c5 feat(gsctl)`: `check-change`, the §9.2 rule against changing an angle together with tz/coordinate data (§15 D64), wired into `profiles-gate` against the merge base. Also `keys/dev/set-ci-secrets.sh`.
6. `fa224b1 docs`: §15 D59–D63; notes for ADR-008, ADR-009 and ADR-011 (dependency rows); `ci-go` paths; the `profiles-gate` compile stage; `release-package` build/sign/verify/artifact (still fails closed at publish); `ci-schemas` validates the signed vector; `tools/gsctl/README.md`.

## Done-test evidence (§13 S09)
- **Sign → verify, Go → Dart:** `gsctl` built the seed profiles and signed all four roles with the **real dev keys** (root 3 of 3, threshold 2).
  - `packages/dm_packages/test/tuf/go_round_trip_test.dart` verifies that vector in Dart. Dart's `CanonicalJson` also reproduces the `profiles.json` payload byte for byte.
  - `tools/gsctl/main_test.go` verifies the same vector in Go.
  - Both languages pass `tools/gsctl/testdata/jcs/vectors.json`.
  - ajv validates the four metadata files against `tuf_metadata.v1`.
- **Tampered byte fails:**
  - Go flips every bit of every metadata file (`trust_test.go`, root signed at exactly its threshold); every flip fails with a PKG_* code. Every package byte fails too.
  - Dart samples about 24 bytes per file (pure-Dart Ed25519 is about 6 ms per check) and tests every package byte. The dev root carries 3 signatures and needs 2, so one broken root signature verifies and two fail; a test covers that.
- **Sequence regression rejected:**
  - Signing at a sequence not above the previous one fails (`PKG_SEQUENCE_REGRESSION`, REQ-DIST-002).
  - Verifying with trusted sequences that are not strictly exceeded fails in Go and in Dart (REQ-PKG-005).
  - A rollback is a new higher sequence that points at old content, and it is accepted.
- REQ IDs proved by named tests: REQ-DIST-001, -002, -003, -004; REQ-PKG-002, REQ-PKG-005; REQ-GOV-001 (signing-time gate); REQ-TEST-004 (ports). All are in Appendix F; `req_index` finds 0 problems.

## Checks (logs in this session's scratchpad)
- `melos run ci`: SUCCESS. Format 0 changed, analyze clean, arch_lint 350 files with 0 violations, req_index 0 problems.
  - Dart tests: dm_core_types 36, dm_hijri 17, dm_packages 25, geo_salah_profiles 27, geo_salah_core 314 (the 3 JCS tests moved to dm_core_types), dm_lints 19.
  - Flutter tests: dm_contracts 17, app 1.
  - Log: `C:\Users\hp\AppData\Local\Temp\claude\C--Users-hp-Projects-daily-muslim--claude-worktrees-s09-gsctl-tuf-3a142a\68b69e2a-009c-492a-8707-8c9b08f3edd9\scratchpad\melos_ci.log`.
- Go, for `tools/gsctl` and `services/control-plane`: golangci-lint 2.15.0 reports 0 issues, and `go vet` and `go test` are green.
  - `go vet` + `go test -race` for both modules ran green in Docker `golang:1.27.3` (Linux), because this Windows host has no gcc. Log: `go_race.log` in the same scratchpad.
  - Log: `go_ci.log` in the same scratchpad.
- `schemas/tools/validate_fixtures.sh` (now also checks the signed vector): 132 ok, 0 FAIL, exit 0 (`validate_fixtures.log`, same scratchpad).
- A clean clone of the branch at `fa224b1` passes the Go suite and the dm_packages/dm_core_types Dart suites, and the vector's pinned hashes survive checkout.

## Local distribution plane (live in this worktree, gitignored)
- `dist/dev` and `dist/lab` each hold `prayer_profiles/2026.10.1`, signed with the dev keys. The package sha `ed7d7cb8…` equals the committed round-trip vector's, so the build is deterministic. The signing state, which keeps sequences increasing, is in `out/dev` and `out/lab`. All of it is in the s09 worktree and is lost if the worktree is removed; to recreate it elsewhere, run `local-release.sh` again.
- How it was checked: `gsctl serve` ran on 127.0.0.1:8787. A client downloaded `lab` over HTTP and `gsctl verify` accepted it. Headers: `timestamp.json` `max-age=300`, packages `max-age=31536000, immutable`; traversal and sidecar paths answered 404.
- To recreate it, from the repository root: `source tools/gsctl/keys/dev/load-ci-env.sh <private-dir>`, then `tools/gsctl/scripts/local-release.sh <dev|lab> <version> <effective-from> "<ar>" "<en>"`, then `go run ./tools/gsctl serve`.

## Decisions recorded (§15)
- **D59**, metadata mechanics:
  - JCS details; signatures over the file's own `signed` member.
  - A metaRef `version` is the pinned file's sequence.
  - Per-role sequences, previous + 1 by default.
  - Lifetimes: root 365 d, targets 90 d, snapshot 30 d, timestamp 7 d (the maximum).
  - Malformed metadata maps to `PKG_SIG_INVALID`; expiry only warns.
- **D60**, the `prayer_profiles` layout:
  - `profiles.json` is the JCS array sorted by profileId and then version.
  - The deterministic `.dmpkg` is gzip with the name `profiles.json`, no mtime and OS byte 255.
  - Target `prayer_profiles/<version>` takes its release inputs from the release manager; compat is the strictest of the set.
  - The channel's on-disk layout includes `staged/`.
- **D61**, the split between Go and Dart:
  - Go checks shape, identity and path, uniqueness, compat fields, the governance gate and the channel gate.
  - Ranges and the D52 semantics stay in Dart (`geo_salah_profiles`), which `release-package` runs first.
- **D62**, the dev key set and key loading: `-key-dir` or `DM_DEV_<ROLE>_KEY_<N>`. The round-trip vector is frozen, and `regenerate.sh` rebuilds it.
- **D63**, the scope of the Dart verifier, and what S14 owns.
- **D65**, the local distribution plane until S25. It covers the `ObjectStore` port, the bucket layout and sidecars, the publish order and its monotonic and immutable rules, publishing to dev/lab only, `serve`, and the local secrets loader.
- **D64**, the §9.2 PR rule: the angle members and the tz/coordinate paths it watches. D61's owed check is now resolved.

## Open items handed on
- **S10/S11:** when you add tz or coordinate data outside the D64 path list, extend `profileset.TzCoordinateDataPaths` and D64.
- **S14:** download, root-rotation chains (S09 verifies root against the anchor only), persisting trusted sequences, and the "unchanged snapshot/targets behind a new timestamp" case (D59). Also the compat check (REQ-PKG-006), pure-Dart gzip (`archive` 4), staging, activation and rollback.
- **S25:** an R2 adapter for `ports.ObjectStore`. With it, `gsctl publish` already compares against the live channel, so sequences increase across CI runs; the CI job also needs the channel's signing state, e.g. pulled from the bucket. Also `gsctl promote`, and a KMS `Signer` for the production targets key.
- **S27:** the root-rotation ceremony (old threshold plus new keys).
- **GitHub secrets (user action):** a repository admin runs `tools/gsctl/keys/dev/set-ci-secrets.sh tools/gsctl/keys/dev/private` from the main checkout after `gh auth login`. It creates the `dev`/`lab` environments and the six `DM_DEV_*_KEY_*` secrets; a dry run against a stub `gh` made the expected 14 calls. The session could not do this itself: no `gh`, and the repository is private.
- The round-trip timestamp expires on 2026-10-28. Tests pass their own "now", and `gsctl verify` then only prints `PKG_EXPIRED_WARNING`.

## Inputs for S10 (`tzdata` pipeline + `dm_civil_time` TzDatabase; DST suite)
- **S09:** `gsctl` can sign and verify any target (`sign`/`verify` are type-agnostic), and the dev keys and channel layout exist.
- **S10 must add** a `tzdata` build path to `gsctl build`, which today compiles only `prayer_profiles` (§15 D60). Suggested shape: a payload-file build with `-type tzdata -payload-format bin`, with the payload produced by the Python pipeline.
- **Existing package:** `dm_civil_time` (S01 skeleton), together with the fixed-offset `TzDatabase` fake in `geo_salah_core/lib/src/bench` (§15 D40) that S10 replaces.
- **Where the payload format lives:** `tzdata` is `package:timezone` database bytes (§9.5); `timezone` 0.10 is a §5.4 floor, "first use" in ADR-011.

## Environment notes
- Go tests and lint: `export PATH=/c/Users/hp/sdk/go/bin:$HOME/go/bin:$PATH GOTOOLCHAIN=local`; golangci-lint is at `~/go/bin`.
- The Bash heredocs in this environment ate backslashes inside quoted Python and Dart strings. Write such files with the editor tool.
