# S11 hand-over (tz_polygons + country_polygons pipelines, Dart readers, ocean/boundary fallbacks) → S12

Branch `slice/s11-polygons`, cut from `slice/s10-tzdata` at `f9eca5a`. No pull request (owner rule in `CLAUDE.md`). Setup for a new session: `docs/handover/cloud-environment.md` (unchanged; its script worked as written).

## Built
- **Schema** `polygon_lookup_oracle.v1` (+ fixtures, Python model): the S11 oracle format (§15 D71).
- **Pipeline** `dm-pipelines polygons fetch|build --dataset tz|country` (§15 D70). Pins in `data-pipelines/config/polygons.v1.toml`: timezone-boundary-builder **2026e** `timezones.geojson.zip` (no oceans) and Natural Earth **5.1.2** admin-0 **map units** (`ISO_A2_EH`; the countries layer merged Svalbard into NO). `make_valid` → Douglas-Peucker 0.001° per polygon → micro-degree rings → 1° grid in the ksy layout. Outputs are committed in `packages/dm_civil_time/data/{tz_polygons/2026e,country_polygons/5.1.2}/` (payload, `lookup_oracle.json`, `manifest.json`).
- **`dm_civil_time`**:
  - `ReadPolygonIndex` returns a `PolygonIndex` (the `LocateInPolygons` port) or a typed `PolygonIndexFailure` (`PKG_SIG_INVALID`).
  - `ResolveZone` returns `InZone`, `NearestZone` (≤ 50 km) or `NauticalZone` (`Etc/GMT±h`). Both fallbacks set `manualCoordinateResolution`.
  - `ResolveCountry` returns `InCountry`, `OffshoreCountry` (≤ 22 224 m, 12 nmi) or `NoCountry`.
  - `zoneBoundaryProximity` is set when another name lies within 10 km. Coastlines do not count.
  - `GeoPointE6` and the `LocalProjection` of D71.
- **CI**: the `ci-lab` `tzdata-rebuild` job now also fetches both sources and checks that the polygon rebuild is byte-identical.

## Evidence (this session, Linux)
- **Done-test** `test/polygons/polygon_lookup_suite_test.dart` covers both packages, each with a `sphere` and a `land` sample of 1 000 points. **0 disagreements in 4 000 points** (threshold ≤ 1 per 1 000). The 10 km flag agrees with shapely outside ±150 m. The largest distance difference is 102 m. **Green.**
- **Corpus**: all 49 `cities.v1.json` cities resolve to their `zoneId` and `country`.
- **Speed**: 2 000 lookups take about 100 ms per package on this VM, a desktop CPU and not a phone.
- **Sizes**: `tz_polygons.bin` is 7.3 MB (4.5 MB gzipped) and `country_polygons.bin` is 4.4 MB (2.4 MB gzipped). Both are above the §9.5 estimates (D70).
- **Reproducibility**: real `fetch` of both sources passes the pins. `DM_POLYGON_SOURCES=… pytest -k "rebuild and polygons"`: 2 passed (byte-identical).
- **Gates**:
  - `melos run ci` SUCCESS. dm_civil_time has 134 tests (101 before); the other packages are unchanged.
  - data-pipelines: ruff, format and mypy clean; 48 passed, 3 skipped (the opt-in rebuilds).
  - `validate_fixtures.sh`: 138 ok, 0 FAIL.
  - Go and the lab were not run: nothing in them changed.

## REQ IDs proved by named tests
REQ-TIME-001 (zone/country resolution, done-test, corpus), REQ-TIME-020 (nautical zones exist in the pinned TZDB), REQ-TEST-004 (`LocateInPolygons` contract, real and fake), REQ-PKG-001 (malformed payloads are typed failures), REQ-DIST-003 (committed outputs match their manifests; byte-identical rebuild).

## §15 rows and ADRs
- D70 (sources, build, sizes, runtime, fallbacks, radii) and D71 (projection, oracle, done-test).
- ADR-011 table: shapely 2.2.0, numpy 2.5.4, types-shapely (dev), and the two source pins.
- LICENSES: the release notes on the ODbL and Natural Earth rows.

## Open / owed
- **Legal/Product** (D70):
  - Confirm that `-99` areas resolve to *no country*: Somaliland, N. Cyprus, Siachen, Bir Tawil, the reefs, the Korean DMZ and the SBAs.
  - Confirm the 12 nmi territorial-sea radius for the country fallback.
- **ODbL**: the attribution screen and the publication of the produced `tz_polygons` database under ODbL (§10) are owed with the UI slices and S27.
- **S14**:
  - Add gsctl `build -type tz_polygons|country_polygons` (target versions `2026e`, `5.1.2`).
  - Bundle both payloads as seeds.
  - Their size (> 2 MB) matters for REQ-PKG-004.
- **Device**: none for S11. Measure lookup and read time on the Galaxy A50 with REQ-PERF-001.
- **Owner** items from S10 still stand: allow `ssd.jpl.nasa.gov`, and merge `slice/s09-gsctl-tuf` `5a18a2c`.

## Inputs for S12 (gazetteer + drift import + search)
- The `data-pipelines` polygon pattern is ready to copy for the gazetteer: a pin file with URL and sha256, a curl fetch through `CommandRunner`, a deterministic build, a manifest and an opt-in byte-identical rebuild.
- `ResolveCountry` can stamp each gazetteer place with its ISO code, and `GeoPointE6` is the coordinate unit.
- Not yet tried from this environment: whether `download.geonames.org` (`cities15000`, `alternateNamesV2`) is reachable.
- The location resolver that consumes `ResolveZone`/`ResolveCountry` and their flags comes in a later slice (§8).
