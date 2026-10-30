import 'dart:convert';
import 'dart:math';

import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_place.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:daily_muslim/features/contexts/domain/search_key.dart';
import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/drift.dart';

/// The gazetteer on drift: `gazetteer` rows plus one `gazetteer_names` row per
/// distinct search key of a place (§7.3, §15 D72).
final class DriftGazetteerStore
    implements FindGazetteerPlaces, FindPlacesAround, StoreGazetteer {
  /// The store over [_db].
  const new(this._db);

  final DmDatabase _db;

  /// Above every code point, so `key < prefix + _last` bounds a prefix range.
  static const _last = '\u{10FFFF}';

  @override
  Future<Result<int, GazetteerFailure>> replaceAll(
    List<GazetteerPlace> places,
  ) async {
    try {
      await _db.transaction(() async {
        await _db.delete(_db.gazetteerNames).go();
        await _db.delete(_db.gazetteer).go();
        await _db.batch((batch) {
          batch
            ..insertAll(_db.gazetteer, places.map(_row))
            ..insertAll(_db.gazetteerNames, places.expand(_nameRows));
        });
      });
      return Ok(places.length);
    } on Exception catch (error) {
      return Err(GazetteerFailure.storage('$error'));
    }
  }

  @override
  Future<Result<List<GazetteerHit>, GazetteerFailure>> findByPrefix(
    SearchKey prefix, {
    required int limit,
  }) async {
    try {
      final rows = await _db
          .customSelect(
            'SELECT g.id, g.name, g.country, g.admin1, g.lat, g.lon, '
            'g.population, g.zone_id, MIN(n.name) AS matched, '
            'MAX(n.search_key = ?1) AS exact, '
            r"json_extract(g.alt_names_json, '$.ar[0]') AS ar "
            'FROM gazetteer_names n JOIN gazetteer g ON g.id = n.place_id '
            'WHERE n.search_key >= ?1 AND n.search_key < ?2 '
            'GROUP BY g.id '
            'ORDER BY exact DESC, g.population DESC, g.id '
            'LIMIT ?3',
            variables: [
              Variable.withString(prefix.value),
              Variable.withString('${prefix.value}$_last'),
              Variable.withInt(limit),
            ],
            readsFrom: {_db.gazetteer, _db.gazetteerNames},
          )
          .get();
      return Ok([for (final row in rows) _hit(row)]);
    } on Exception catch (error) {
      return Err(GazetteerFailure.storage('$error'));
    }
  }

  @override
  Future<Result<GazetteerHit?, GazetteerFailure>> nearest(
    GeoPointE6 point, {
    required double withinKm,
  }) async {
    final lat = point.latE6 / 1e6;
    final lon = point.lonE6 / 1e6;
    // A box around the point narrows the rows; the great-circle distance
    // picks among them.
    final dLat = withinKm / _kmPerDegree;
    final dLon = withinKm / (_kmPerDegree * max(cos(lat * pi / 180), 0.01));
    try {
      final rows = await _places(
        'WHERE g.lat BETWEEN ?1 AND ?2 AND g.lon BETWEEN ?3 AND ?4',
        [lat - dLat, lat + dLat, lon - dLon, lon + dLon],
      );
      GazetteerHit? best;
      var bestKm = withinKm;
      for (final hit in rows) {
        final km = _distanceKm(lat, lon, hit.point);
        if (km <= bestKm) {
          best = hit;
          bestKm = km;
        }
      }
      return Ok(best);
    } on Exception catch (error) {
      return Err(GazetteerFailure.storage('$error'));
    }
  }

  @override
  Future<Result<List<GazetteerHit>, GazetteerFailure>> largestIn(
    String zoneId, {
    required int limit,
  }) async {
    try {
      return Ok(
        await _places(
          'WHERE g.zone_id = ?1 ORDER BY g.population DESC, g.id LIMIT ?2',
          [zoneId, limit],
        ),
      );
    } on Exception catch (error) {
      return Err(GazetteerFailure.storage('$error'));
    }
  }

  Future<List<GazetteerHit>> _places(String where, List<Object> args) async {
    final rows = await _db
        .customSelect(
          'SELECT g.id, g.name, g.country, g.admin1, g.lat, g.lon, '
          'g.population, g.zone_id, g.name AS matched, 0 AS exact, '
          r"json_extract(g.alt_names_json, '$.ar[0]') AS ar "
          'FROM gazetteer g $where',
          variables: [
            for (final arg in args)
              switch (arg) {
                final int i => Variable.withInt(i),
                final double d => Variable.withReal(d),
                _ => Variable.withString('$arg'),
              },
          ],
          readsFrom: {_db.gazetteer},
        )
        .get();
    return [for (final row in rows) _hit(row)];
  }

  static const _kmPerDegree = 111.195;

  /// Haversine distance on the mean Earth radius.
  static double _distanceKm(double lat, double lon, GeoPointE6 to) {
    double rad(double deg) => deg * pi / 180;
    final dLat = rad(to.latE6 / 1e6 - lat);
    final dLon = rad(to.lonE6 / 1e6 - lon);
    final a =
        pow(sin(dLat / 2), 2) +
        cos(rad(lat)) * cos(rad(to.latE6 / 1e6)) * pow(sin(dLon / 2), 2);
    return 2 * 6371.0088 * asin(min(1, sqrt(a)));
  }

  static GazetteerHit _hit(QueryRow row) => GazetteerHit(
    id: row.read<int>('id'),
    name: row.read<String>('name'),
    matchedName: row.read<String>('matched'),
    arabicName: row.readNullable<String>('ar') ?? '',
    exact: row.read<int>('exact') == 1,
    country: row.read<String>('country'),
    admin1: row.read<String>('admin1'),
    point: GeoPointE6.fromDegrees(
      row.read<double>('lat'),
      row.read<double>('lon'),
    ),
    population: row.read<int>('population'),
    zoneId: row.read<String>('zone_id'),
  );

  static GazetteerCompanion _row(GazetteerPlace place) =>
      GazetteerCompanion.insert(
        id: Value(place.id),
        name: place.name,
        asciiName: place.asciiName,
        altNamesJson: jsonEncode({
          'ar': place.arabicNames,
          'en': place.englishNames,
        }),
        country: place.country,
        admin1: place.admin1,
        lat: place.point.latE6 / 1e6,
        lon: place.point.lonE6 / 1e6,
        population: place.population,
        zoneId: place.zoneId,
        nameNorm: SearchKey.of(place.name).value,
      );

  /// One row per distinct key; the first name (in [GazetteerPlace.allNames]
  /// order) that yields a key is the one kept.
  static Iterable<GazetteerNamesCompanion> _nameRows(GazetteerPlace place) {
    final names = <SearchKey, String>{};
    for (final name in place.allNames) {
      for (final key in SearchKey.indexKeysOf(name)) {
        names.putIfAbsent(key, () => name);
      }
    }
    return [
      for (final MapEntry(:key, :value) in names.entries)
        GazetteerNamesCompanion.insert(
          searchKey: key.value,
          placeId: place.id,
          name: value,
        ),
    ];
  }
}
