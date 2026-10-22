import 'dart:math' as math;

import 'package:dm_civil_time/src/polygons/geo_point_e6.dart';

/// The local equirectangular projection around a point P that every polygon
/// distance uses (§15 D71); the data pipeline's oracle uses the same one.
///
/// `k = R·π/180` metres per degree, `c = max(cos lat_P, cos 89°)`,
/// `x = wrap(lon − lon_P)·c·k`, `y = (lat − lat_P)·k`. A segment is
/// projected from its first point's wrapped longitude plus its own
/// longitude delta, so no segment is torn at the antimeridian. Accurate to
/// well under 1 % within 50 km away from the poles; it is a definition, not
/// a geodesic.
final class LocalProjection {
  /// The projection around [origin].
  new(this.origin)
    : cos = math.max(
        math.cos(origin.latE6 / 1e6 * math.pi / 180),
        math.cos(89 * math.pi / 180),
      );

  /// Mean Earth radius (IUGG), metres.
  static const double earthRadiusM = 6371008.8;

  /// Metres per micro-degree of latitude.
  static const double metresPerE6 = earthRadiusM * math.pi / 180 / 1e6;

  static const int _fullTurnE6 = 360000000;

  /// P.
  final GeoPointE6 origin;

  /// `c`.
  final double cos;

  /// Half-height in micro-degrees of the box holding everything within
  /// [radiusM].
  int latSpanE6(int radiusM) => (radiusM / metresPerE6).ceil();

  /// Half-width in micro-degrees of that box, at most 180°.
  int lonSpanE6(int radiusM) =>
      math.min((radiusM / (metresPerE6 * cos)).ceil(), GeoPointE6.maxLonE6);

  /// Longitude difference `lonE6 − lon_P` wrapped to [-180°, 180°).
  int wrappedLonE6(int lonE6) {
    final delta = lonE6 - origin.lonE6 + GeoPointE6.maxLonE6;
    return delta % _fullTurnE6 - GeoPointE6.maxLonE6;
  }

  /// Distance in metres from P to the segment (aLon, aLat)–(bLon, bLat).
  double segmentDistanceM(int aLon, int aLat, int bLon, int bLat) {
    final ax0 = wrappedLonE6(aLon);
    final ax = ax0 * cos * metresPerE6;
    final bx = (ax0 + bLon - aLon) * cos * metresPerE6;
    final ay = (aLat - origin.latE6) * metresPerE6;
    final by = (bLat - origin.latE6) * metresPerE6;
    final dx = bx - ax;
    final dy = by - ay;
    final lengthSquared = dx * dx + dy * dy;
    final t = lengthSquared == 0
        ? 0.0
        : ((-ax * dx - ay * dy) / lengthSquared).clamp(0.0, 1.0);
    final px = ax + t * dx;
    final py = ay + t * dy;
    return math.sqrt(px * px + py * py);
  }
}
