/// TzDatabase over the app's pinned TZDB, plus tz and country polygon indexes
/// (DESIGN.md §5.2, ADR-015).
///
/// S10: `ReadTzfDatabase` turns the `tzdata` package payload into a
/// `PinnedTzDatabase`, the engine's `TzDatabase` port (REQ-TIME-020), with
/// local-time derivation for display and day boundaries (§15 D66, D67).
///
/// S11: `ReadPolygonIndex` turns a `tz_polygons` or `country_polygons`
/// payload into a `PolygonIndex` (the `LocateInPolygons` port);
/// `ResolveZone` and `ResolveCountry` apply the §8 ocean and boundary
/// fallbacks (§15 D70–D71).
///
/// Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the
/// platform.
library;

export 'package:dm_civil_time/src/polygons/country_resolution.dart';
export 'package:dm_civil_time/src/polygons/geo_point_e6.dart';
export 'package:dm_civil_time/src/polygons/local_projection.dart';
export 'package:dm_civil_time/src/polygons/locate_in_polygons.dart';
export 'package:dm_civil_time/src/polygons/polygon_dataset.dart';
export 'package:dm_civil_time/src/polygons/polygon_index.dart';
export 'package:dm_civil_time/src/polygons/polygon_index_failure.dart';
export 'package:dm_civil_time/src/polygons/polygon_match.dart';
export 'package:dm_civil_time/src/polygons/read_polygon_index.dart';
export 'package:dm_civil_time/src/polygons/resolve_country.dart';
export 'package:dm_civil_time/src/polygons/resolve_zone.dart';
export 'package:dm_civil_time/src/polygons/zone_resolution.dart';
export 'package:dm_civil_time/src/tzdb/local_date_time.dart';
export 'package:dm_civil_time/src/tzdb/pinned_tz_database.dart';
export 'package:dm_civil_time/src/tzdb/read_tzf_database.dart';
export 'package:dm_civil_time/src/tzdb/tzdb_failure.dart';
