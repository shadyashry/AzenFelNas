import 'package:daily_muslim/features/contexts/domain/context_place.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// Zone, country and resolver flags for a point (§7.5), from the pinned
/// `tz_polygons` and `country_polygons` (S11).
final class ResolvePlace {
  /// Resolves through [_zones] and [_countries].
  const new(this._zones, this._countries);

  final ResolveZone _zones;
  final ResolveCountry _countries;

  /// The place at [point] and its flags. No country ⇒ `country == null` and
  /// `noLocalProfile` (`engine.default`).
  (ContextPlace, Set<ResultFlag>) call(
    GeoPointE6 point, {
    required double? horizontalAccuracyM,
    required String label,
  }) {
    final zone = _zones(point);
    final country = _countries(point);
    final place = ContextPlace(
      point: point,
      horizontalAccuracyM: horizontalAccuracyM,
      zoneId: zone.zoneId,
      country: _iso2(country),
      label: label,
    );
    return (place, _flags(zone, country));
  }

  /// The flags of [point] alone, for a context whose zone and country were
  /// chosen elsewhere (gazetteer, pinned): they are never re-resolved.
  Set<ResultFlag> flagsAt(GeoPointE6 point) =>
      _flags(_zones(point), _countries(point));

  static String? _iso2(CountryResolution country) => switch (country) {
    InCountry(:final iso2) || OffshoreCountry(:final iso2) => iso2,
    NoCountry() => null,
  };

  static Set<ResultFlag> _flags(
    ZoneResolution zone,
    CountryResolution country,
  ) => {
    ...zone.flags,
    ...country.flags,
    if (country is NoCountry) ResultFlag.noLocalProfile,
  };
}
