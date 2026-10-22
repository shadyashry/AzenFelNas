import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:meta/meta.dart';

/// The place of a location context: where, how precise, which zone and
/// country (§7.3, §7.5).
@immutable
final class ContextPlace {
  /// A place at [point] in [zoneId].
  const new({
    required this.point,
    required this.horizontalAccuracyM,
    required this.zoneId,
    required this.country,
    required this.label,
  });

  /// Location in micro-degrees.
  final GeoPointE6 point;

  /// Horizontal accuracy in metres; `null` for a gazetteer or typed place.
  final double? horizontalAccuracyM;

  /// IANA zone id resolved for [point] (or the gazetteer's zone).
  final String zoneId;

  /// ISO 3166-1 alpha-2 code; `null` when no country resolves, which selects
  /// `engine.default` with `noLocalProfile` (§7.5).
  final String? country;

  /// User-facing name; empty for the current location.
  final String label;

  @override
  bool operator ==(Object other) =>
      other is ContextPlace &&
      other.point == point &&
      other.horizontalAccuracyM == horizontalAccuracyM &&
      other.zoneId == zoneId &&
      other.country == country &&
      other.label == label;

  @override
  int get hashCode =>
      Object.hash(point, horizontalAccuracyM, zoneId, country, label);

  /// Coordinates rounded to 0.01° (REQ-PRIV-001): this text may reach logs.
  @override
  String toString() =>
      'ContextPlace(${_coarse(point.latE6)}, ${_coarse(point.lonE6)}, '
      '$zoneId, ${country ?? '-'})';

  static String _coarse(int e6) => (e6 / 1e6).toStringAsFixed(2);
}
