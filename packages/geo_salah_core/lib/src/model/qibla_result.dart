import 'package:meta/meta.dart';

/// The direction of the Kaaba from an observer (§6.6, REQ-DOM-030).
@immutable
final class QiblaResult {
  /// Creates a [QiblaResult].
  const new({
    required this.bearingDeg,
    required this.distanceM,
    required this.kaabaRefVersion,
  });

  /// Initial azimuth of the WGS84 geodesic to the Kaaba, degrees clockwise
  /// from **true** north, `[0, 360)`.
  final double bearingDeg;

  /// Length of that geodesic in metres.
  final double distanceM;

  /// Version of the Kaaba reference point used (`Kaaba.refVersion`).
  final String kaabaRefVersion;

  @override
  bool operator ==(Object other) =>
      other is QiblaResult &&
      other.bearingDeg == bearingDeg &&
      other.distanceM == distanceM &&
      other.kaabaRefVersion == kaabaRefVersion;

  @override
  int get hashCode => Object.hash(bearingDeg, distanceM, kaabaRefVersion);
}

/// The Kaaba reference point of §6.6 (a geographic fact, not a profile
/// parameter): `21.422487° N, 39.826206° E`.
abstract final class Kaaba {
  /// Latitude, degrees.
  static const double latitudeDeg = 21.422487;

  /// Longitude, degrees.
  static const double longitudeDeg = 39.826206;

  /// Version of this reference point (`kaabaRefVersion`).
  static const String refVersion = '2026.1';
}
