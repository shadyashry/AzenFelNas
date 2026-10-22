# S10 hand-over (tzdata pipeline + `dm_civil_time` TzDatabase + DST suite) → S11

Branch `slice/s10-tzdata`, cut from `slice/s09-gsctl-tuf` at `2f4f290`; draft PR against that branch. Setup for a new session: `docs/handover/cloud-environment.md`.

## Built
- **Pipeline** `data-pipelines` `dm-pipelines tzdata fetch|build` (§15 D66):
  - The pinned IANA **2026e** (53 files by sha256, `config/tzdata.v1.toml`) goes through `make rearguard.zi`, a zic built from the same release (`-b fat`) and `dm_civil_time/tool/encode_tzf.dart` (package:timezone's recipe).
  - Outputs: `tzdata.tzf`, `dst_oracle.json` (CPython zoneinfo, schema `tz_transition_oracle.v1`) and `manifest.json` (`pipeline_manifest.v1`), committed in `packages/dm_civil_time/data/tzdata/2026e/`.
- **`dm_civil_time`**: `ReadTzfDatabase` reads the payload into `PinnedTzDatabase` (the `TzDatabase` port) with typed failures. It also provides `localDateTimeOf`, `utcMsOfLocal` (PEP 495 fold=0) and `startOfDayUtcMs` (§15 D67). `package:timezone` 0.11.2 is a dev dependency only.
- **Engine bench**: `bin/bench` and `tool/range_baseline.dart` use the pinned TZDB through a dev dependency (§15 D68). The fixed-offset table now serves only the golden tool, and the golden corpus is unchanged.
- **gsctl**: `build -type tzdata -payload … -manifest …`. The target version is `<release>[.<n>]`, and gsctl checks it against the manifest. `verify` checks the tzdata payload framing (§15 D69).
- **CI**: `ci-lab` checks the data-pipelines models and adds the `tzdata-rebuild` job (fetch → byte-identical rebuild).

## Evidence (this session, Linux)
- **Done-test** `dm_civil_time/test/tzdb/dst_transition_suite_test.dart`: covers all 41 corpus zones. 15 of them have DST, giving 82 transitions and 1 230 days within ±7 d. For each day the suite checks the start of day and, for every local hour, local→UTC, UTC→local and the offset, against the oracle; an hourly scan finds no extra transitions. **Green.**
- **Differential test**: our reader against `package:timezone`, on our payload and on its own 2026e `latest_all.tzf`. It covers all 598 zones, every transition ±1 ms and 300 random instants per zone. **Green.**
- **Reproducibility**: two builds are byte-identical, and the opt-in rebuild test passes after a real `fetch`. With Ubuntu's zic the payload equals package:timezone's shipped file byte for byte (sha256 `86a4e2c9…`).
- **Lab** `lab benchmark --engine dart`: 4 188 cases, 12 564 events, 0 discrepancies, max |residual| 1 575 ms, unchanged. Golden regeneration: 0 changed lines.
- **Gates**:
  - `melos run ci` SUCCESS. arch_lint: 362 files, 0 violations. req_index: 0 problems. Tests: dm_civil_time 101, geo_salah_core 315, geo_salah_profiles 27, dm_packages 25, dm_core_types 36, dm_hijri 17, dm_lints 19, dm_contracts 17, app 1.
  - Go: `tools/gsctl` and `services/control-plane` green under vet and `-race`; golangci-lint 2.15.0 reports 0 issues.
  - data-pipelines: ruff, format and mypy clean; 35 passed, 1 skipped (the opt-in rebuild, which passes with `DM_TZ_SOURCE`).
  - `validate_fixtures.sh`: 135 ok, 0 FAIL.
  - **lab**: ruff, format and mypy clean. pytest has **44 failures/errors, all from fetching `de440s.bsp`** (JPL is denied by this environment's network policy). It is the same set as before S10; the code is not at fault.

## REQ IDs proved by named tests
REQ-TIME-020, REQ-TIME-001 (dm_civil_time, data-pipelines, bench); REQ-TEST-004 (`TzDatabase` contract, real and fake); REQ-DIST-003, REQ-GOV-004 (gsctl tzdata target).

## §15 rows and ADRs
- D66 (payload, pipeline, reader, limits), D67 (fold=0, start of day, oracle), D68 (bench on the pinned TZDB; replaces D40 (a)), D69 (gsctl tzdata target).
- D44 now moves `staleTzdb` to S14.
- ADR-011 table: `timezone` 0.11.2 (dev), data-pipelines `pydantic` 2.14.1, the IANA release pin. LICENSES: the tz row.

## Open / owed
- **Owner**: allow `ssd.jpl.nasa.gov` in the cloud environment, so the lab suite runs green here.
- **Owner**: merge `origin/slice/s09-gsctl-tuf` (commit `5a18a2c`, CLAUDE.md cloud workflow) into this branch. The session's permission classifier refused that merge as self-modification.
- **S14**:
  - Bundle `tzdata/2026e` as a seed package.
  - Take `tzdbVersion` from the active target's version (before the dot).
  - Activate the package (REQ-PKG-001).
  - Set `staleTzdb` (D44/D66).
- **S27**: the `tzdb-emergency` runbook should cite `data-pipelines/README.md` (new release steps) and `gsctl build -type tzdata`.
- **Device**: none for S10. REQ-PERF-001 is still owed on a Galaxy A50 (D49/D55); the baseline tool now includes TZ lookups.

## Inputs for S11 (tz/country polygons) exist
`data-pipelines` has the package skeleton, the manifest model, the `CommandRunner` port and the pin-file pattern. `dm_civil_time` exists and is wired into the bench, ready for polygon indexes. Appendix H zones are in `lab/benchmarks/cities.v1.json`. D64's `TzCoordinateDataPaths` already covers `data-pipelines/` and `packages/dm_civil_time/`. Natural Earth, timezone-boundary-builder and shapely downloads are not yet tried from this environment.
