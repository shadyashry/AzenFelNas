# gsctl

Builds, signs and verifies Daily Muslim's signed data packages (`DESIGN.md` §9.1–§9.2, Appendix C, ADR-008, ADR-009). Slice S09 delivers `validate`, `check-change`, `build`, `sign`, `verify`, and `publish` / `serve` against a local bucket (§15 D65). S10 adds `build -type tzdata` (§15 D69). S25 adds R2 (`-bucket s3://…`), `pull`, `promote` and the Cloud KMS signer (`sign -kms`) (§15 D85).

Run it from the repository root (`go.work`):

```
go run ./tools/gsctl validate -channel dev
go run ./tools/gsctl build -channel dev -repo out/dev -version 2026.10.1 -effective-from 2026-11-01 \
  -note-ar "…" -note-en "…"
go run ./tools/gsctl build -type tzdata -repo out/dev -version 2026e -effective-from 2026-11-01 \
  -payload packages/dm_civil_time/data/tzdata/2026e/tzdata.tzf \
  -manifest packages/dm_civil_time/data/tzdata/2026e/manifest.json -note-ar "…" -note-en "…"
go run ./tools/gsctl sign -repo out/dev -role root -key-dir tools/gsctl/keys/dev/private
go run ./tools/gsctl sign -repo out/dev -role targets -key-dir tools/gsctl/keys/dev/private
go run ./tools/gsctl sign -repo out/dev -role snapshot -key-dir tools/gsctl/keys/dev/private
go run ./tools/gsctl sign -repo out/dev -role timestamp -key-dir tools/gsctl/keys/dev/private
go run ./tools/gsctl verify -repo out/dev
go run ./tools/gsctl publish -repo out/dev -channel dev      # into dist/ (the local bucket)
go run ./tools/gsctl serve                                  # http://127.0.0.1:8787/dev/metadata/timestamp.json
```

Against R2 (or any S3 API): `-bucket s3://dm-dist[/<prefix>]` with `DM_S3_ENDPOINT` (`<account>.r2.cloudflarestorage.com`), `DM_S3_ACCESS_KEY_ID`, `DM_S3_SECRET_ACCESS_KEY`; `DM_S3_INSECURE=1` is accepted for a loopback test server only. The live `s3bucket` tests run when `GSCTL_S3_TEST_ENDPOINT`, `GSCTL_S3_TEST_ACCESS_KEY_ID` and `GSCTL_S3_TEST_SECRET_ACCESS_KEY` name such a server (CI: SeaweedFS, see `ci-go.yml`).

```
go run ./tools/gsctl pull -repo out/lab -channel lab -bucket s3://dm-dist        # a fresh runner continues the live sequences
go run ./tools/gsctl promote -repo out/lab -from dev -to lab -sequence 7 -bucket s3://dm-dist
tools/gsctl/scripts/lab-e2e.sh                                                    # S25 done-test: two lab releases, then the app syncs
```

`tools/gsctl/scripts/local-release.sh <dev|lab> <version> <effective-from> "<note ar>" "<note en>"` runs the whole release locally. Source `tools/gsctl/keys/dev/load-ci-env.sh` first to sign with CI-style `DM_DEV_*` variables instead of `-key-dir`.

| Command | Does | Fails with |
|---|---|---|
| `validate` | compiles `profiles/*/*.yaml` and checks it for a channel (§15 D61) | `PROFILE_INVALID`, one line per problem |
| `check-change` | refuses a PR that changes an existing profile's angle together with tz/coordinate data, given the base profiles and the changed paths (§9.2, §15 D64) | `PROFILE_INVALID`, naming both sides |
| `build` | `-type prayer_profiles` (default): `validate`, then writes `packages/prayer_profiles/<version>/<sha256>.dmpkg` and stages its target (§15 D60). `-type tzdata`: packs the pipeline's `-payload` when its `-manifest` lists the same bytes and IANA release; version `<release>[.<n>]` (§15 D69) | `PROFILE_INVALID`, an invalid release field, a payload or manifest mismatch |
| `sign` | signs one role (`-kms`: with Cloud KMS key versions `DM_KMS_<ROLE>_KEY_<N>` and the OIDC token `DM_KMS_ACCESS_TOKEN`). `targets` adds the staged targets; `snapshot` and `timestamp` pin the file below them (§15 D59) | `PKG_SEQUENCE_REGRESSION`, missing or mismatched keys, a timestamp beyond 7 days, a changed published target |
| `publish` | verifies a signed repository, then copies it into the bucket (`-bucket`, default `dist`): new packages first, then the changed metadata, root → targets → snapshot → timestamp, with the §9.1 cache policy. `dev` and `lab` only (§15 D65) | any `verify` failure, `PKG_SEQUENCE_REGRESSION` against the bucket, a package key holding other bytes |
| `pull` | verifies the published channel in the bucket and restores it into an empty repository (packages, then metadata), so the next `sign` continues its sequences (§15 D85). A never-published channel prints so and writes nothing | any `verify` failure of the published channel; a repository holding other metadata (unpublished signed work) |
| `promote` | stages the targets of the published `-from` channel into the repository of `-to`, the channel above, when its targets sequence equals the reviewed `-sequence`; bytes, hash and custom fields unchanged. Then `sign` targets, snapshot, timestamp and `publish`. `-to dev|lab` until the S27 keys | a skipped or reversed channel, a different sequence, any `verify` failure of the source |
| `serve` | serves a bucket read-only on `127.0.0.1:8787` like the CDN (GET/HEAD, Cache-Control, no listings) until Ctrl+C | a busy address |
| `verify` | checks a channel as a client would: root against `root-keys.json`, the chain, every package, the `prayer_profiles` payload and the `tzdata` payload framing. `-after-<role> N` enforces trusted sequences | `PKG_SIG_INVALID`, `PKG_HASH_MISMATCH`, `PKG_SEQUENCE_REGRESSION`. An expiry prints `PKG_EXPIRED_WARNING` and still succeeds |

Exit codes: 0 success, 1 refused, 2 usage error. Private keys come from `-key-dir` or the `DM_DEV_<ROLE>_KEY_<N>` variables and never from the repository (`keys/dev/README.md`, §15 D62).

Layout (§17.5): `internal/domain` (pure rules: `jcs`, `trust`, `profileset`, `dmpkg`, `distribution`), `internal/app` (one use case per type), `internal/ports` (narrow interfaces), `internal/adapters` (YAML, changed-path list, filesystem repository, local bucket, S3/R2 bucket, CDN stand-in handler, key files, PEM keys, Cloud KMS keys, clock), and `main.go` + `commands.go` as the composition root. `internal/schema` holds the hand-written wire models (§15 D24). `internal/testsupport` holds ephemeral keys, port fakes and the shared port contracts (REQ-TEST-004).

Checks: `golangci-lint run ./...` (config `.golangci.yml`), `go vet ./...` and `go test -race ./...` (`ci-go`).
