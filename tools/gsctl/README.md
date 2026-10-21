# gsctl

Builds, signs and verifies Daily Muslim's signed data packages (`DESIGN.md` §9.1–§9.2, Appendix C, ADR-008, ADR-009). Slice S09 delivers `validate`, `build`, `sign` and `verify`. `publish` and `promote` arrive with the distribution infrastructure (S25).

Run it from the repository root (`go.work`):

```
go run ./tools/gsctl validate -channel dev
go run ./tools/gsctl build -channel dev -repo out/dev -version 2026.10.1 -effective-from 2026-11-01 \
  -note-ar "…" -note-en "…"
go run ./tools/gsctl sign -repo out/dev -role root -key-dir tools/gsctl/keys/dev/private
go run ./tools/gsctl sign -repo out/dev -role targets -key-dir tools/gsctl/keys/dev/private
go run ./tools/gsctl sign -repo out/dev -role snapshot -key-dir tools/gsctl/keys/dev/private
go run ./tools/gsctl sign -repo out/dev -role timestamp -key-dir tools/gsctl/keys/dev/private
go run ./tools/gsctl verify -repo out/dev
```

| Command | Does | Fails with |
|---|---|---|
| `validate` | compiles `profiles/*/*.yaml` and checks it for a channel (§15 D61) | `PROFILE_INVALID`, one line per problem |
| `build` | `validate`, then writes `packages/prayer_profiles/<version>/<sha256>.dmpkg` and stages its target (§15 D60) | `PROFILE_INVALID`, an invalid release field |
| `sign` | signs one role. `targets` adds the staged targets; `snapshot` and `timestamp` pin the file below them (§15 D59) | `PKG_SEQUENCE_REGRESSION`, missing or mismatched keys, a timestamp beyond 7 days, a changed published target |
| `verify` | checks a channel as a client would: root against `root-keys.json`, the chain, every package and the `prayer_profiles` payload. `-after-<role> N` enforces trusted sequences | `PKG_SIG_INVALID`, `PKG_HASH_MISMATCH`, `PKG_SEQUENCE_REGRESSION`. An expiry prints `PKG_EXPIRED_WARNING` and still succeeds |

Exit codes: 0 success, 1 refused, 2 usage error. Private keys come from `-key-dir` or the `DM_DEV_<ROLE>_KEY_<N>` variables and never from the repository (`keys/dev/README.md`, §15 D62).

Layout (§17.5): `internal/domain` (pure rules: `jcs`, `trust`, `profileset`, `dmpkg`), `internal/app` (one use case per type), `internal/ports` (narrow interfaces), `internal/adapters` (YAML, filesystem repository, key files, PEM keys, clock), and `main.go` + `commands.go` as the composition root. `internal/schema` holds the hand-written wire models (§15 D24). `internal/testsupport` holds ephemeral keys, port fakes and the shared port contracts (REQ-TEST-004).

Checks: `golangci-lint run ./...` (config `.golangci.yml`), `go vet ./...` and `go test -race ./...` (`ci-go`).
