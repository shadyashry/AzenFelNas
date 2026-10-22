import 'package:dm_civil_time/src/polygons/geo_point_e6.dart';
import 'package:dm_civil_time/src/polygons/locate_in_polygons.dart';
import 'package:dm_civil_time/src/polygons/polygon_match.dart';
import 'package:dm_civil_time/src/polygons/zone_resolution.dart';

/// Resolves the IANA zone of a coordinate over the `tz_polygons` index
/// (§8, REQ-TIME-001, §15 D70): the containing polygon; else the nearest
/// zone within [nearestRadiusM]; else the nautical `Etc/GMT±h` of the
/// longitude. Pure and deterministic.
final class ResolveZone {
  /// Resolves over [polygons] (a `tz_polygons` index).
  const new(this.polygons);

  /// "Nearest within 50 km" (§8).
  static const int nearestRadiusM = 50000;

  /// `zoneBoundaryProximity` radius: another zone within 10 km (§8).
  static const int boundaryRadiusM = 10000;

  /// The tz polygon index.
  final LocateInPolygons polygons;

  /// The zone of [point].
  ZoneResolution call(GeoPointE6 point) =>
      switch (polygons.locate(point, searchRadiusM: nearestRadiusM)) {
        InsidePolygon(:final name, :final otherDistanceM) => InZone(
          name,
          nearBoundary: _near(otherDistanceM),
        ),
        NearPolygon(:final name, :final distanceM, :final otherDistanceM) =>
          NearestZone(
            name,
            distanceM: distanceM,
            nearBoundary: _near(otherDistanceM),
          ),
        NoPolygon() => NauticalZone(nauticalZoneId(point.lonE6)),
      };

  /// `Etc/GMT±h` for [lonE6]; POSIX sign: `Etc/GMT-3` is UTC+3.
  static String nauticalZoneId(int lonE6) {
    final hours = (lonE6 / 15e6).round().clamp(-12, 12);
    if (hours == 0) return 'Etc/GMT';
    return hours > 0 ? 'Etc/GMT-$hours' : 'Etc/GMT+${-hours}';
  }

  static bool _near(double? otherDistanceM) =>
      otherDistanceM != null && otherDistanceM <= boundaryRadiusM;
}
