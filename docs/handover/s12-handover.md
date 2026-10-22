# S12 hand-over (gazetteer pipeline + drift import + normalised search) → S13

Branch `slice/s12-gazetteer`, cut from `slice/s11-polygons` at `7f3f44c`. No pull request (owner rule in `CLAUDE.md`). Setup: `docs/handover/cloud-environment.md` (unchanged; its script worked as written).

## Built
- **Pipeline** `dm-pipelines gazetteer fetch|build` (§15 D72). `download.geonames.org` is denied here (HTTP 403), so the source is GeoNames `cities15000` in the sha256-pinned PyPI wheel `geonamescache` **3.0.2** (`data-pipelines/config/gazetteer.v1.toml`). Arabic and English alternate names are picked by script and `asciiName` is derived. Output: `apps/mobile/assets/packages/gazetteer/3.0.2/{gazetteer.json, manifest.json}`, with 34 006 places, 8.2 MB raw and 1.7 MB gzipped. The Python wire model is generated from `gazetteer_package.v1`.
- **App feature `contexts`** (`apps/mobile/lib/features/contexts/`):
  - **domain**: `SearchKey` (Arabic and Latin folding, plus an article-less key for «ال…»), `GazetteerPlace`, `GazetteerHit`, the sealed `GazetteerFailure` (`PKG_SIG_INVALID` / `PKG_STORAGE`), and the ports `FindGazetteerPlaces`, `StoreGazetteer` and `DecodeGazetteerPayload`.
  - **application**: `SearchGazetteer` and `ImportGazetteer`.
  - **data**: `GazetteerDatabase` (drift), which holds the §7.3 `gazetteer` table and a `gazetteer_names` WITHOUT ROWID key table. `DriftGazetteerStore` does a one-transaction replace and a prefix range scan that ranks exact matches first, then by population. `JsonGazetteerPayloadDecoder` decodes through the `dm_contracts` wire model and adds the schema's range and pattern checks.
- **Dependencies**: drift 2.35.2 and drift_dev 2.35.1 (dev), with sqlite3 3.7.1 transitive (all MIT). The app also gains direct dependencies on dm_civil_time, dm_contracts, dm_core_types, json_annotation and meta.
- **CI**: the `ci-lab` job `tzdata-rebuild` now also checks that the gazetteer rebuilds byte for byte. `apps/mobile/assets/packages/**` was added to its paths.

## Evidence (this session, Linux)
- **Done-test** `apps/mobile/test/features/contexts/gazetteer_search_done_test.dart`: the full pinned payload is imported through the production decoder and the drift store, in memory. «القاهرة», "Cairo", «القاهره», "cairo" and "Le Caire" all rank Cairo (360630, EG, `Africa/Cairo`) first. Over 16 queries, every median of 5 runs is ≤ 10.3 ms, against a limit of < 50 ms. One-letter prefixes are the slowest; whole words take under 1 ms. **Green.**
- **Gates**:
  - `melos run ci` SUCCESS: the app has 42 tests (1 before); other packages unchanged; arch_lint and req_index report 0 problems.
  - data-pipelines: ruff, format and mypy clean; 61 passed, 4 skipped (the opt-in rebuilds).
  - `DM_GAZETTEER_SOURCE=… pytest -k "rebuild and gazetteer"`: byte-identical against the real fetched wheel.
  - `validate_fixtures.sh`: 138 ok, 0 FAIL.
  - Go and the lab were not run, because nothing in them changed.

## REQ IDs proved by named tests
- REQ-TEST-004: the gazetteer port contract runs against both drift and the fake.
- REQ-PKG-001: invalid payloads and fixtures are refused with typed failures, and the previous places are kept.
- REQ-ERR-001: storage failure comes back as `Err`.
- REQ-TIME-020: every gazetteer zone is in the pinned TZDB 2026e.
- REQ-DIST-003: the committed output matches its manifest, and the rebuild is byte-identical.

There is no gazetteer REQ in Appendix F, so the done-tests are named `S12` (D72).

## §15 rows and ADRs
- D72 covers the source, name selection, sizes, search keys, the names table, ranking and speed.
- ADR-011 table: drift, drift_dev and sqlite3; the geonamescache source pin.
- LICENSES: the GeoNames attribution text.

## Open / owed
- **Owner**:
  - Allow `download.geonames.org`, then rebuild from `cities15000.zip` + `alternateNamesV2.zip` to get true `ar`/`en` language tags. The payload format stays the same.
  - The S10/S11 items still stand: allow `ssd.jpl.nasa.gov`, and merge `slice/s09-gsctl-tuf` `5a18a2c`.
- **Product**:
  - Ranking puts an exact alternate-name match above a larger prefix match ("cair" returns Čair, MK, first).
  - Which Arabic name to display (`matchedName` is the smallest matching name).
- **Legal**: the GeoNames CC BY attribution screen (UI slices / S27).
- **Device**: search and import time on the Galaxy A50, measured with REQ-PERF-001.
- **S14**: gsctl `build -type gazetteer` (version `3.0.2`) and bundling the seed. At 1.7 MB gzipped it is under the 2 MB REQ-PKG-004 threshold.
- **S16**: fold the `gazetteer` / `gazetteer_names` tables into `dm.sqlite` (drift_flutter, migrations), and wire `ImportGazetteer` into package activation.
- **Attribution slip**: commit `91c6d49` carries the session's default attribution lines instead of the `CLAUDE.md` ones. It was not rewritten, because slice branches are never force-pushed.

## Inputs for S13 (location contexts + resolver + pinning + clock skew)
- `SearchGazetteer` returns `GazetteerHit` (`GeoPointE6`, `zoneId`, `country`), which a manual or pinned context can be built from (REQ-PRIV-002).
- The `contexts` feature directory and its layering already exist; `ResolveZone` and `ResolveCountry` come from S11 in `dm_civil_time`.
- `places.sqlite` is not created yet (S16). S13 can define the `location_contexts` tables the same way as `GazetteerDatabase`.
