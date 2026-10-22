import 'package:daily_muslim/features/contexts/data/drift_gazetteer_store.dart';
import 'package:daily_muslim/features/contexts/data/gazetteer_database.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:daily_muslim/features/contexts/domain/search_key.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_gazetteer_store.dart';
import 'support/places.dart';

/// Both ports of one implementation, and how to release it.
typedef _Store = ({
  FindGazetteerPlaces find,
  StoreGazetteer save,
  Future<void> Function() close,
});

/// Answers [prefix] as `(id, matchedName, exact)` triples.
Future<List<(int, String, bool)>> _find(
  FindGazetteerPlaces store,
  String prefix, {
  int limit = 10,
}) async {
  final result = await store.findByPrefix(SearchKey.of(prefix), limit: limit);
  return switch (result) {
    Ok(:final value) => [for (final h in value) (h.id, h.matchedName, h.exact)],
    Err(:final failure) => fail('$failure'),
  };
}

void main() {
  final implementations = <String, _Store Function()>{
    'DriftGazetteerStore': () {
      final db = GazetteerDatabase(NativeDatabase.memory());
      final store = DriftGazetteerStore(db);
      return (find: store, save: store, close: db.close);
    },
    'FakeGazetteerStore': () {
      final store = FakeGazetteerStore();
      return (find: store, save: store, close: () async {});
    },
  };

  for (final MapEntry(key: name, value: open) in implementations.entries) {
    group('REQ-TEST-004 gazetteer port contract: $name', () {
      late _Store store;

      setUp(() async {
        store = open();
        expect(
          await store.save.replaceAll(samplePlaces),
          Ok<int, GazetteerFailure>(samplePlaces.length),
        );
      });
      tearDown(() => store.close());

      test('Arabic and Latin names find the same place', () async {
        expect(await _find(store.find, 'القاهرة'), [(360630, 'القاهرة', true)]);
        expect(await _find(store.find, 'قاهرة'), [(360630, 'القاهرة', true)]);
        expect((await _find(store.find, 'Cairo')).first, (
          360630,
          'Cairo',
          true,
        ));
      });

      test(
        'exact matches first, then larger places, one hit per place',
        () async {
          expect(await _find(store.find, 'cai'), [
            (360630, 'Cairo', false),
            (360631, 'Cairo Montenotte', false),
          ]);
          expect(await _find(store.find, 'cairo'), [
            (360630, 'Cairo', true),
            (360631, 'Cairo Montenotte', false),
          ]);
        },
      );

      test('folded spellings and alternate names match', () async {
        expect(await _find(store.find, 'zurich'), [(2657896, 'Zürich', true)]);
        expect(await _find(store.find, 'مكه'), [
          (104515, 'مكة المكرمة', true),
        ]);
        expect(await _find(store.find, 'makkah'), [(104515, 'Makkah', true)]);
      });

      test('limit caps the hits and an unknown prefix finds nothing', () async {
        expect(await _find(store.find, 'c', limit: 1), [
          (360630, 'Cairo', false),
        ]);
        expect(await _find(store.find, 'xyz'), isEmpty);
      });

      test('replaceAll replaces every earlier place', () async {
        expect(
          await store.save.replaceAll(samplePlaces.sublist(2)),
          const Ok<int, GazetteerFailure>(2),
        );
        expect(await _find(store.find, 'cairo'), isEmpty);
        expect(await _find(store.find, 'zurich'), hasLength(1));
      });

      test('hits carry the stored place', () async {
        final result = await store.find.findByPrefix(
          SearchKey.of('Mecca'),
          limit: 1,
        );
        final hit = switch (result) {
          Ok(:final value) => value.single,
          Err(:final failure) => fail('$failure'),
        };
        final mecca = samplePlaces.last;
        expect(
          (
            hit.name,
            hit.country,
            hit.admin1,
            hit.point,
            hit.population,
            hit.zoneId,
          ),
          (
            mecca.name,
            mecca.country,
            mecca.admin1,
            mecca.point,
            mecca.population,
            mecca.zoneId,
          ),
        );
      });
    });
  }
}
