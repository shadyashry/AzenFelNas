import 'package:geo_salah_core/src/model/elevation_sample.dart';
import 'package:geo_salah_core/src/model/observer_source.dart';
import 'package:meta/meta.dart';

/// The place a prayer day is calculated for (§6.2).
///
/// Invariants, checked on construction (§15 D19): latitude in `[−90, 90]`,
/// longitude in `[−180, 180]`, both finite; a non-empty IANA [zoneId];
/// a non-negative [horizontalAccuracyM] when present. [elevation] is
/// provenance only (ADR-003). Immutable value type.
@immutable
final class Observer {
  /// Creates an observer.
  ///
  /// Throws [ArgumentError] when an invariant does not hold.
  factory({
    required double latitudeDeg,
    required double longitudeDeg,
    required String zoneId,
    required ObserverSource source,
    double? horizontalAccuracyM,
    ElevationSample? elevation,
  }) {
    if (!(latitudeDeg >= -90 && latitudeDeg <= 90)) {
      throw ArgumentError.value(latitudeDeg, 'latitudeDeg', 'not in [-90, 90]');
    }
    if (!(longitudeDeg >= -180 && longitudeDeg <= 180)) {
      throw ArgumentError.value(
        longitudeDeg,
        'longitudeDeg',
        'not in [-180, 180]',
      );
    }
    if (zoneId.isEmpty) {
      throw ArgumentError.value(zoneId, 'zoneId', 'must not be empty');
    }
    if (horizontalAccuracyM != null && !(horizontalAccuracyM >= 0)) {
      throw ArgumentError.value(
        horizontalAccuracyM,
        'horizontalAccuracyM',
        'must not be negative',
      );
    }
    return Observer._(
      latitudeDeg: latitudeDeg,
      longitudeDeg: longitudeDeg,
      zoneId: zoneId,
      source: source,
      horizontalAccuracyM: horizontalAccuracyM,
      elevation: elevation,
    );
  }

  const new _({
    required this.latitudeDeg,
    required this.longitudeDeg,
    required this.zoneId,
    required this.source,
    required this.horizontalAccuracyM,
    required this.elevation,
  });

  /// Geodetic latitude, degrees north.
  final double latitudeDeg;

  /// Longitude, degrees east.
  final double longitudeDeg;

  /// IANA zone the prayer day is a civil date in.
  final String zoneId;

  /// Where the position came from.
  final ObserverSource source;

  /// Horizontal accuracy in metres, when known.
  final double? horizontalAccuracyM;

  /// Elevation, for provenance only (ADR-003).
  final ElevationSample? elevation;

  @override
  bool operator ==(Object other) =>
      other is Observer &&
      other.latitudeDeg == latitudeDeg &&
      other.longitudeDeg == longitudeDeg &&
      other.zoneId == zoneId &&
      other.source == source &&
      other.horizontalAccuracyM == horizontalAccuracyM &&
      other.elevation == elevation;

  @override
  int get hashCode => Object.hash(
    latitudeDeg,
    longitudeDeg,
    zoneId,
    source,
    horizontalAccuracyM,
    elevation,
  );
}
