import 'dart:io';

import 'package:daily_muslim/features/contexts/application/import_gazetteer.dart';
import 'package:daily_muslim/features/contexts/application/search_gazetteer.dart';
import 'package:daily_muslim/features/contexts/data/drift_gazetteer_store.dart';
import 'package:daily_muslim/features/contexts/data/json_gazetteer_payload_decoder.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The pinned payload (§15 D72), built by `dm-pipelines gazetteer build`.
const _payload = 'assets/packages/gazetteer/3.0.2/gazetteer.json';
const _places = 34006;
const _cairo = 360630;

/// The S12 done-test (§13): the pinned gazetteer imported into drift through
/// the production adapters; «القاهرة» and "Cairo" both resolve, and search
/// stays under 50 ms.
void main() {
  late DmDatabase db;
  late SearchGazetteer search;

  setUpAll(() async {
    db = DmDatabase(NativeDatabase.memory());
    final store = DriftGazetteerStore(db);
    final imported = await ImportGazetteer(
      const JsonGazetteerPayloadDecoder(),
      store,
    )(File(_payload).readAsBytesSync());
    switch (imported) {
      case Ok(:final value):
        expect(value, _places);
      case Err(:final failure):
        fail('$failure');
    }
    search = SearchGazetteer(store);
  });
  tearDownAll(() => db.close());

  Future<List<GazetteerHit>> find(String query) async =>
      switch (await search(query)) {
        Ok(:final value) => value,
        Err(:final failure) => fail('$failure'),
      };

  for (final query in ['القاهرة', 'Cairo', 'القاهره', 'cairo', 'Le Caire']) {
    test('S12 «$query» resolves to Cairo, Egypt first', () async {
      final top = (await find(query)).first;
      expect(top.id, _cairo);
      expect(top.exact, isTrue);
      expect((top.country, top.zoneId), ('EG', 'Africa/Cairo'));
    });
  }

  test('S12 a prefix ranks the largest place first', () async {
    // "cai" itself is an alternate name of Cádiz: exact matches rank first.
    expect((await find('cai')).first.exact, isTrue);
    expect((await find('le cai')).first.id, _cairo);
    expect((await find('القاه')).first.id, _cairo);
  });

  test('REQ-TIME-020 every gazetteer zone is in the pinned TZDB', () async {
    const tzf = '../../packages/dm_civil_time/data/tzdata/2026e/tzdata.tzf';
    final tzdb = switch (const ReadTzfDatabase()(
      File(tzf).readAsBytesSync(),
      version: '2026e',
    )) {
      Ok(:final value) => value,
      Err(:final failure) => fail('$failure'),
    };
    final known = tzdb.zoneIds.toSet();
    final zones = await db
        .customSelect('SELECT DISTINCT zone_id FROM gazetteer')
        .map((row) => row.read<String>('zone_id'))
        .get();
    expect(zones, isNotEmpty);
    expect(zones.where((zone) => !known.contains(zone)), isEmpty);
  });

  test(
    'S12 search < 50 ms (median of 5, every query, in-memory, this host)',
    () async {
      const queries = [
        'القاهرة',
        'Cairo',
        'c',
        'a',
        'ال',
        'م',
        'san',
        'new york',
        'مكة',
        'Makkah',
        'riyadh',
        'الرياض',
        'jakarta',
        'istanbul',
        'zürich',
        'x',
      ];
      final medians = <String, int>{};
      for (final query in queries) {
        final runs = <int>[];
        for (var i = 0; i < 5; i++) {
          final watch = Stopwatch()..start();
          await find(query);
          runs.add(watch.elapsedMicroseconds);
        }
        medians[query] = (runs..sort())[2];
      }
      // Printed for the hand-over; the phone figure is owed (REQ-PERF-001).
      // ignore: avoid_print
      print('search medians µs: $medians');
      expect(medians.values.where((us) => us >= 50000), isEmpty);
    },
  );
}
