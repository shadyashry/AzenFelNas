import 'package:meta/meta.dart';

/// A position in integer micro-degrees (1e-6°), the unit of the polygon
/// payloads (§9.5, `schemas/tz_polygons.v1.ksy`).
///
/// Invariant: `-90e6 ≤ latE6 ≤ 90e6` and `-180e6 ≤ lonE6 ≤ 180e6`; the
/// constructor throws [RangeError] otherwise.
@immutable
final class GeoPointE6 {
  /// The point (`latE6`, `lonE6`).
  new(this.latE6, this.lonE6) {
    RangeError.checkValueInInterval(latE6, -maxLatE6, maxLatE6, 'latE6');
    RangeError.checkValueInInterval(lonE6, -maxLonE6, maxLonE6, 'lonE6');
  }

  /// The point nearest to (`latitudeDeg`, `longitudeDeg`), rounded half away
  /// from zero to micro-degrees.
  factory fromDegrees(double latitudeDeg, double longitudeDeg) =>
      GeoPointE6((latitudeDeg * 1e6).round(), (longitudeDeg * 1e6).round());

  /// 90° in micro-degrees.
  static const int maxLatE6 = 90000000;

  /// 180° in micro-degrees.
  static const int maxLonE6 = 180000000;

  /// Latitude, micro-degrees north.
  final int latE6;

  /// Longitude, micro-degrees east.
  final int lonE6;

  @override
  bool operator ==(Object other) =>
      other is GeoPointE6 && other.latE6 == latE6 && other.lonE6 == lonE6;

  @override
  int get hashCode => Object.hash(latE6, lonE6);

  /// Never printed in logs (§0.2): for tests and debugging only.
  @override
  String toString() => 'GeoPointE6($latE6, $lonE6)';
}
