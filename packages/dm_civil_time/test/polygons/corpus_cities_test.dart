// Every Appendix H city of the benchmark corpus resolves, over the pinned
// packages, to the zone and country the corpus records (§15 D30, D70).
import 'dart:convert';
import 'dart:io';

import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:test/test.dart';

import '../support/pinned_polygons.dart';

List<Map<String, Object?>> _cities() => switch (jsonDecode(
  File('../../lab/benchmarks/cities.v1.json').readAsStringSync(),
)) {
  {'cities': final List<Object?> cities} => [
    for (final city in cities)
      if (city case final Map<String, Object?> object) object,
  ],
  _ => throw const FormatException('cities.v1.json'),
};

double _deg(Map<String, Object?> city, String key) => switch (city[key]) {
  final num value => value.toDouble(),
  _ => throw FormatException(key),
};

void main() {
  final zones = ResolveZone(PinnedPolygons.load(PolygonDataset.tz).index);
  final countries = ResolveCountry(
    PinnedPolygons.load(PolygonDataset.country).index,
  );
  final cities = _cities();

  test('REQ-TIME-001 every corpus city resolves to its zoneId and country', () {
    expect(cities, hasLength(greaterThanOrEqualTo(41)));
    for (final city in cities) {
      final point = GeoPointE6.fromDegrees(
        _deg(city, 'latitudeDeg'),
        _deg(city, 'longitudeDeg'),
      );
      expect(zones(point).zoneId, city['zoneId'], reason: '${city['cityId']}');
      expect(
        switch (countries(point)) {
          InCountry(:final iso2) || OffshoreCountry(:final iso2) => iso2,
          NoCountry() => null,
        },
        city['country'],
        reason: '${city['cityId']}',
      );
    }
  });
}
