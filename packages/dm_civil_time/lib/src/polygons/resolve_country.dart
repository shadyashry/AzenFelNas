import 'package:dm_civil_time/src/polygons/country_resolution.dart';
import 'package:dm_civil_time/src/polygons/geo_point_e6.dart';
import 'package:dm_civil_time/src/polygons/locate_in_polygons.dart';
import 'package:dm_civil_time/src/polygons/polygon_match.dart';

/// Resolves the country of a coordinate over the `country_polygons` index
/// (§8, ADR-006, §15 D70): the containing polygon; else the nearest country
/// within the 12-nautical-mile territorial sea; else none. Pure and
/// deterministic.
final class ResolveCountry {
  /// Resolves over [polygons] (a `country_polygons` index).
  const new(this.polygons);

  /// 12 nautical miles (UNCLOS art. 3), metres (§15 D70).
  static const int territorialSeaM = 22224;

  /// `zoneBoundaryProximity` radius: another country within 10 km (§8).
  static const int boundaryRadiusM = 10000;

  /// The country polygon index.
  final LocateInPolygons polygons;

  /// The country of [point].
  CountryResolution call(GeoPointE6 point) =>
      switch (polygons.locate(point, searchRadiusM: territorialSeaM)) {
        InsidePolygon(:final name, :final otherDistanceM) => InCountry(
          name,
          nearBoundary: _near(otherDistanceM),
        ),
        NearPolygon(:final name, :final distanceM, :final otherDistanceM) =>
          OffshoreCountry(
            name,
            distanceM: distanceM,
            nearBoundary: _near(otherDistanceM),
          ),
        NoPolygon() => const NoCountry(),
      };

  static bool _near(double? otherDistanceM) =>
      otherDistanceM != null && otherDistanceM <= boundaryRadiusM;
}
