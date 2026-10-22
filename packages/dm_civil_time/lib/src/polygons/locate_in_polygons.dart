import 'package:dm_civil_time/src/polygons/geo_point_e6.dart';
import 'package:dm_civil_time/src/polygons/polygon_match.dart';

/// Port: where a point lies among the polygons of one package (§8).
///
/// Contract (`locate_in_polygons_contract_test.dart`): pure and
/// deterministic; [InsidePolygon] when a polygon contains `point`;
/// otherwise [NearPolygon] for the nearest polygon within `searchRadiusM`
/// (`0 ≤ distanceM ≤ searchRadiusM`), else [NoPolygon]. Every
/// `otherDistanceM` is `null` or in `[0, searchRadiusM]`, and names a
/// polygon whose name differs from the match's.
abstract interface class LocateInPolygons {
  /// Locates [point]; [searchRadiusM] is positive.
  PolygonMatch locate(GeoPointE6 point, {required int searchRadiusM});
}
