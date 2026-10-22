import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:meta/meta.dart';

/// One place of the `gazetteer` package (GeoNames `cities15000`, §9.5,
/// ADR-015) as the `contexts` feature sees it.
@immutable
final class GazetteerPlace {
  /// A place with GeoNames [id] and its names, location and zone.
  const new({
    required this.id,
    required this.name,
    required this.asciiName,
    required this.arabicNames,
    required this.englishNames,
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

  /// [name] without diacritics.
  final String asciiName;

  /// Arabic alternate names (§15 D72).
  final List<String> arabicNames;

  /// English (Latin-script) alternate names (§15 D72).
  final List<String> englishNames;

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

  /// Every name a search can find this place by.
  Iterable<String> get allNames sync* {
    yield name;
    yield asciiName;
    yield* arabicNames;
    yield* englishNames;
  }
}
