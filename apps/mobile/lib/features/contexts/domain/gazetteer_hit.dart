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
    this.arabicName = '',
  });

  /// GeoNames id.
  final int id;

  /// Name in the source's local spelling.
  final String name;

  /// The name whose search key matched the query (e.g. «القاهرة»).
  final String matchedName;

  /// The name shown and pinned (§15 D96): the matched name when it is
  /// Arabic, so an Arabic search keeps its Arabic name; otherwise the primary
  /// [name], since a Latin query may match an alternate spelling
  /// ("Alexandreia" for Alexandria).
  String get displayName => _arabic.hasMatch(matchedName) ? matchedName : name;

  static final _arabic = RegExp('[؀-ۿ]');

  /// The place's first Arabic name in the gazetteer; empty when it has none.
  final String arabicName;

  /// The name a reader of [languageCode] knows the place by, for a place
  /// shown without a query (a suggestion, the place nearest a fix; §15
  /// D100): [arabicName] for Arabic when there is one, else [name].
  String nameIn(String languageCode) =>
      languageCode == 'ar' && arabicName.isNotEmpty ? arabicName : name;

  /// This place as if it were found by [nameIn] for [languageCode], so it is
  /// shown and pinned under that name ([displayName]).
  GazetteerHit namedIn(String languageCode) => GazetteerHit(
    id: id,
    name: name,
    matchedName: nameIn(languageCode),
    exact: exact,
    country: country,
    admin1: admin1,
    point: point,
    population: population,
    zoneId: zoneId,
    arabicName: arabicName,
  );

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
      other.zoneId == zoneId &&
      other.arabicName == arabicName;

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
    arabicName,
  );

  @override
  String toString() => 'GazetteerHit($id, $name, matched: $matchedName)';
}
