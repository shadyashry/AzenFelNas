import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// The zone the resolver gives a coordinate (§8, §15 D70).
@immutable
sealed class ZoneResolution {
  const new();

  /// IANA zone id, present in the pinned TZDB.
  String get zoneId;

  /// The result flags this resolution sets (§8): `manualCoordinateResolution`
  /// for either fallback, `zoneBoundaryProximity` when another zone lies
  /// within the boundary radius.
  Set<ResultFlag> get flags => switch (this) {
    InZone(:final nearBoundary) => {
      if (nearBoundary) ResultFlag.zoneBoundaryProximity,
    },
    NearestZone(:final nearBoundary) => {
      ResultFlag.manualCoordinateResolution,
      if (nearBoundary) ResultFlag.zoneBoundaryProximity,
    },
    NauticalZone() => {ResultFlag.manualCoordinateResolution},
  };
}

/// A `tz_polygons` polygon contains the coordinate.
final class InZone extends ZoneResolution {
  /// The resolution.
  const new(this.zoneId, {required this.nearBoundary});

  @override
  final String zoneId;

  /// Another zone lies within the boundary radius.
  final bool nearBoundary;

  @override
  bool operator ==(Object other) =>
      other is InZone &&
      other.zoneId == zoneId &&
      other.nearBoundary == nearBoundary;

  @override
  int get hashCode => Object.hash(InZone, zoneId, nearBoundary);

  @override
  String toString() => 'InZone($zoneId, nearBoundary: $nearBoundary)';
}

/// No polygon contains the coordinate (sea, or a simplified coast); the
/// nearest zone lies within the nearest radius.
final class NearestZone extends ZoneResolution {
  /// The resolution.
  const new(this.zoneId, {required this.distanceM, required this.nearBoundary});

  @override
  final String zoneId;

  /// Distance to that zone, metres.
  final double distanceM;

  /// Another zone lies within the boundary radius.
  final bool nearBoundary;

  @override
  bool operator ==(Object other) =>
      other is NearestZone &&
      other.zoneId == zoneId &&
      other.distanceM == distanceM &&
      other.nearBoundary == nearBoundary;

  @override
  int get hashCode => Object.hash(NearestZone, zoneId, distanceM, nearBoundary);

  @override
  String toString() => 'NearestZone($zoneId, $distanceM, $nearBoundary)';
}

/// No zone lies within the nearest radius: the nautical zone `Etc/GMT±h`
/// of the longitude (`h = round(lon / 15°)`, half away from zero, clamped to
/// ±12).
final class NauticalZone extends ZoneResolution {
  /// The resolution.
  const new(this.zoneId);

  @override
  final String zoneId;

  @override
  bool operator ==(Object other) =>
      other is NauticalZone && other.zoneId == zoneId;

  @override
  int get hashCode => Object.hash(NauticalZone, zoneId);

  @override
  String toString() => 'NauticalZone($zoneId)';
}
