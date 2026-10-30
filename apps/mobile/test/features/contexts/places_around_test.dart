import 'package:daily_muslim/features/contexts/application/name_nearest_place.dart';
import 'package:daily_muslim/features/contexts/application/name_stored_place.dart';
import 'package:daily_muslim/features/contexts/application/suggest_places.dart';
import 'package:daily_muslim/features/contexts/data/drift_gazetteer_store.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:daily_muslim/features/contexts/presentation/manual_place_view.dart';
import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/state_harness.dart';
import 'support/places.dart';

void main() {
  late DmDatabase db;
  late DriftGazetteerStore store;
  setUp(() async {
    db = DmDatabase(NativeDatabase.memory());
    store = DriftGazetteerStore(db);
    expect(await store.replaceAll(samplePlaces), isA<Ok<int, Object>>());
  });
  tearDown(() => db.close());

  group('Places around a point or a zone (§15 D100)', () {
    test(
      'a fix in Cairo is named Cairo, in Arabic for Arabic readers',
      () async {
        final hit = await NameNearestPlace(
          store,
        )(GeoPointE6.fromDegrees(30.0444, 31.2357));
        expect(hit?.id, 360630);
        expect(hit?.nameIn('en'), 'Cairo');
        expect(hit?.nameIn('ar'), 'القاهرة');
      },
    );

    test('a district is named after its city, the largest place within '
        '10 km', () async {
      GazetteerHit hit(int id, String name, int population, double km) =>
          GazetteerHit(
            id: id,
            name: name,
            matchedName: name,
            exact: false,
            country: 'EG',
            admin1: '11',
            point: GeoPointE6.fromDegrees(30, 31),
            population: population,
            zoneId: 'Africa/Cairo',
          );
      final district = hit(1, 'Bulaq', 50000, 1);
      final city = hit(2, 'Cairo', 9606916, 4);
      final away = hit(3, 'Qalyub', 100000, 20);
      expect(
        await NameNearestPlace(
          _Near([(district, 1), (city, 4), (away, 20)]),
        )(GeoPointE6.fromDegrees(30, 31)),
        city,
      );
      expect(
        await NameNearestPlace(_Near([(away, 20)]))(
          GeoPointE6.fromDegrees(30, 31),
        ),
        away,
      );
    });

    group('a chosen place reads in the reader language (§15 D104)', () {
      final cairo = GeoPointE6(30062630, 31249670);

      test('a place picked as «القاهرة» reads Cairo in English', () async {
        final hit = await NameStoredPlace(store)(cairo, 'القاهرة');
        expect(hit?.nameIn('en'), 'Cairo');
      });

      test('a place picked as Cairo reads «القاهرة» in Arabic', () async {
        final hit = await NameStoredPlace(store)(cairo, 'Cairo');
        expect(hit?.nameIn('ar'), 'القاهرة');
      });

      test(
        'an alternate Arabic name at the place itself is recognised',
        () async {
          final hit = await NameStoredPlace(store)(cairo, 'قاهره');
          expect(hit?.id, 360630);
        },
      );

      test('a name the user typed is not replaced', () async {
        expect(await NameStoredPlace(store)(cairo, 'Home'), isNull);
        expect(await NameStoredPlace(store)(cairo, '  '), isNull);
      });
    });

    test('a fix far from every place has no name', () async {
      expect(
        await NameNearestPlace(store)(GeoPointE6.fromDegrees(0, -30)),
        isNull,
      );
    });

    test('the phone time zone suggests its places, largest first', () async {
      final suggested = await SuggestPlaces(
        const FakeDeviceZone('Asia/Riyadh'),
        store,
      )();
      expect([for (final h in suggested) h.name], ['Mecca']);
      expect(suggested.single.nameIn('ar'), 'مكة المكرمة');
    });

    test('an unknown zone or none suggests nothing', () async {
      expect(
        await SuggestPlaces(const FakeDeviceZone('Pacific/Nowhere'), store)(),
        isEmpty,
      );
      expect(await SuggestPlaces(const FakeDeviceZone(null), store)(), isEmpty);
    });

    test('a suggestion is pinned under the reader’s name for it', () async {
      final mecca = (await SuggestPlaces(
        const FakeDeviceZone('Asia/Riyadh'),
        store,
      )()).single;
      expect(mecca.namedIn('ar').displayName, 'مكة المكرمة');
      expect(mecca.namedIn('en').displayName, 'Mecca');
    });

    test('a place with no Arabic name keeps its own in Arabic', () {
      final hit = GazetteerHit(
        id: 1,
        name: 'Cairo Montenotte',
        matchedName: 'Cairo Montenotte',
        exact: false,
        country: 'IT',
        admin1: '08',
        point: GeoPointE6(44398000, 8276000),
        population: 13000,
        zoneId: 'Europe/Rome',
      );
      expect(hit.nameIn('ar'), 'Cairo Montenotte');
    });

    test('a country shows as its flag; anything else as nothing', () {
      expect(flagOf('EG'), '🇪🇬');
      expect(flagOf('ae'), '🇦🇪');
      expect(flagOf('E1'), '');
    });
  });
}

final class _Near implements FindPlacesAround {
  const new(this.places);

  final List<(GazetteerHit, double)> places;

  @override
  Future<Result<List<GazetteerHit>, GazetteerFailure>> largestIn(
    String zoneId, {
    required int limit,
  }) async => const Ok([]);

  @override
  Future<Result<List<(GazetteerHit, double)>, GazetteerFailure>> near(
    GeoPointE6 point, {
    required double withinKm,
  }) async => Ok(places);
}
