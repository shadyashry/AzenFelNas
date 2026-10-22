import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:meta/meta.dart';

/// One answer of a gazetteer search (`SearchGazetteer`, §7.2).
@immutable
final class GazetteerHit {
  /// The place [id] found by [matchedName].
  const new({
    required this.id,
    required this.name,
    required this.matchedName,
    required this.exact,
    required this.country,
    required this.admin1,
    required this.point,
    required this.population,
    required this.zoneId,
  });

  /// GeoNames id.
  final int id;

  /// Name in the source's local spelling.
  final String name;

  /// The name whose search key matched the query (e.g. «القاهرة»).
  final String matchedName;

  /// Whether a search key of the place equals the query key, not only
  /// starts with it.
  final bool exact;

  /// ISO 3166-1 alpha-2 code.
  final String country;

  /// GeoNames admin1 code; empty when unknown.
  final String admin1;

  /// Location in micro-degrees.
  final GeoPointE6 point;

  /// Population; 0 when unknown.
  final int population;

  /// IANA zone id.
  final String zoneId;

  @override
  bool operator ==(Object other) =>
      other is GazetteerHit &&
      other.id == id &&
      other.name == name &&
      other.matchedName == matchedName &&
      other.exact == exact &&
      other.country == country &&
      other.admin1 == admin1 &&
      other.point == point &&
      other.population == population &&
      other.zoneId == zoneId;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    matchedName,
    exact,
    country,
    admin1,
    point,
    population,
    zoneId,
  );

  @override
  String toString() => 'GazetteerHit($id, $name, matched: $matchedName)';
}
