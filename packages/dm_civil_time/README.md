# dm_civil_time

The app's pinned TZDB (DESIGN.md §5.2, §6.2 `TzDatabase`, REQ-TIME-020), plus tz and country polygon indexes from S11 (ADR-015).

Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the platform.

- `ReadTzfDatabase` reads a `tzdata` package payload, the `package:timezone` `.tzf` database, into a `PinnedTzDatabase`. Every offset, length and index is checked, and a bad payload is a typed `TzdbFailure`, never an exception (§15 D66).
- `PinnedTzDatabase` implements the engine's `TzDatabase` port. It also derives local time for display and day boundaries: `localDateTimeOf`, `utcMsOfLocal` (PEP 495 `fold = 0`) and `startOfDayUtcMs` (§15 D67).
- `data/tzdata/<version>/` holds the pinned build from `data-pipelines` (`tzdata.tzf`, `dst_oracle.json`, `manifest.json`). The bench, the baseline tool and the tests read it; the app gets the same bytes as a bundled seed package (S14).
- `ReadPolygonIndex` reads a `tz_polygons` or `country_polygons` payload (`schemas/tz_polygons.v1.ksy`) into a `PolygonIndex`, the `LocateInPolygons` adapter; a bad payload is a typed `PolygonIndexFailure` (§15 D70).
- `ResolveZone` and `ResolveCountry` apply the §8 fallbacks: nearest zone within 50 km, else the nautical `Etc/GMT±h`; nearest country within the 12 nmi territorial sea, else none; `zoneBoundaryProximity` within 10 km of another zone or country. Distances use the `LocalProjection` of §15 D71.
- `data/tz_polygons/<version>/` and `data/country_polygons/<version>/` hold the pinned builds (payload, `lookup_oracle.json`, `manifest.json`).
- `tool/encode_tzf.dart` is the pipeline's encoder: `package:timezone`'s own all-locations step. `package:timezone` is a dev dependency only.

Tests: the DST transition suite (`test/tzdb/dst_transition_suite_test.dart`, §13 S10), a differential test against `package:timezone` for all 598 zones, payload fuzzing and the `TzDatabase` port contract. S11: the polygon lookup suite against shapely (`test/polygons/polygon_lookup_suite_test.dart`, §13 S11), the corpus cities, payload validation, the `LocateInPolygons` contract (real and fake) and the resolvers.
