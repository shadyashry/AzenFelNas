import 'dart:convert';
import 'dart:io';

import 'package:daily_muslim/features/radio/data/asset_featured_stations.dart';
import 'package:daily_muslim/features/radio/data/file_radio_catalog_store.dart';
import 'package:daily_muslim/features/radio/data/mp3quran_catalog_parser.dart';
import 'package:daily_muslim/features/radio/domain/radio_catalog.dart';
import 'package:daily_muslim/features/radio/domain/radio_failure.dart';
import 'package:daily_muslim/features/radio/domain/radio_ports.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';

Object? _json(String path) => jsonDecode(File(path).readAsStringSync());

const _ar = 'test/fixtures/mp3quran_radios_ar_2026-10-31.json';
const _en = 'test/fixtures/mp3quran_radios_eng_2026-10-31.json';
const _featuredPath = 'assets/radio/featured_stations.json';

List<FeaturedStation> _featured() =>
    AssetFeaturedStations.decode(_json(_featuredPath));

RadioCatalog _parse({
  Object? ar,
  Object? en,
  List<FeaturedStation> featured = const [],
}) => switch (Mp3QuranCatalogParser.parse(
  ar: ar,
  en: en,
  featured: featured,
  nowUtcMs: 1000,
)) {
  Ok(:final value) => value,
  Err(:final failure) => throw StateError('$failure'),
};

Map<String, Object?> _radios(List<Map<String, Object?>> radios) => {
  'radios': radios,
};

void main() {
  group('Mp3QuranCatalogParser', () {
    test('REQ-RADIO-001 the live answers of 2026-10-31 join into one list, '
        'the featured stations first in their order', () {
      final catalog = _parse(
        ar: _json(_ar),
        en: _json(_en),
        featured: _featured(),
      );

      // 177 entries, one of another broadcaster left out (REQ-RADIO-004).
      expect(catalog.stations, hasLength(176));
      expect(catalog.stations.take(4).map((s) => s.id.wire), [
        'mp3quran:108',
        'mp3quran:74',
        'mp3quran:69',
        'mp3quran:32',
      ]);
      expect(catalog.stations.take(4).every((s) => s.featured), isTrue);
      expect(catalog.stations.skip(4).any((s) => s.featured), isFalse);
      final husary = catalog.byId(const RadioStationId('mp3quran', 74));
      expect(husary?.nameEn, 'Mahmoud Khalil Al-Hussary');
      expect(husary?.nameAr, 'محمود خليل الحصري');
      expect(
        husary?.streamUrl.toString(),
        'https://backup.qurango.net/radio/mahmoud_khalil_alhussary',
      );
      expect(
        catalog.byId(const RadioStationId('mp3quran', 108))?.nameEn,
        'General recitations',
      );
      expect(catalog.refreshedUtcMs, 1000);
    });

    test('REQ-RADIO-004 a station of another broadcaster or over plain HTTP '
        'is left out', () {
      final catalog = _parse(
        ar: _radios([
          {'id': 1, 'name': 'أ', 'url': 'https://backup.qurango.net/radio/a'},
          {'id': 2, 'name': 'ب', 'url': 'https://stream.radiojar.com/x'},
          {'id': 3, 'name': 'ج', 'url': 'http://backup.qurango.net/radio/c'},
        ]),
      );

      expect(catalog.stations.map((s) => s.id.providerId), [1]);
    });

    test('REQ-RADIO-001 entries without an id, a name or a URL are skipped; '
        'a numeric string id is read; unknown fields are ignored', () {
      final catalog = _parse(
        en: _radios([
          {'name': 'No id', 'url': 'https://qurango.net/radio/x'},
          {'id': 5, 'url': 'https://qurango.net/radio/y'},
          {'id': 6, 'name': 'No url'},
          {'id': 0, 'name': 'Zero', 'url': 'https://qurango.net/radio/z'},
          {
            'id': '7',
            'name': '  -Main Radio-  ',
            'url': 'https://qurango.net/radio/mix',
            'recent_date': '2020-04-25 22:04:05',
            'extra': true,
          },
        ]),
      );

      expect(catalog.stations, hasLength(1));
      expect(catalog.stations.single.id.wire, 'mp3quran:7');
      expect(catalog.stations.single.nameEn, 'Main Radio');
      // One language only: the other name takes it.
      expect(catalog.stations.single.nameAr, 'Main Radio');
    });

    test('REQ-RADIO-001 an answer with no playable station is malformed, so '
        'it never replaces a kept list', () {
      for (final (ar, en) in [
        (null, null),
        (_radios([]), _radios([])),
        ({'stations': <Object?>[]}, 'not a map'),
      ]) {
        expect(
          Mp3QuranCatalogParser.parse(
            ar: ar,
            en: en,
            featured: const [],
            nowUtcMs: 0,
          ),
          isA<Err<RadioCatalog, RadioCatalogFailure>>(),
        );
      }
    });

    test('REQ-RADIO-003 a featured entry applies only while the id still has '
        'its stream path', () {
      final catalog = _parse(
        ar: _radios([
          {'id': 74, 'name': 'Other', 'url': 'https://qurango.net/radio/x'},
        ]),
        featured: const [
          FeaturedStation(
            providerId: 74,
            streamPath: '/radio/mahmoud_khalil_alhussary',
            nameEn: 'Al-Husary',
            description: RadioCuratedDescription(en: 'e', ar: 'a'),
          ),
        ],
      );

      final station = catalog.stations.single;
      expect(station.featured, isFalse);
      expect(station.nameEn, 'Other');
      expect(station.description, isA<RadioVariantDescription>());
    });

    test('the variant comes only from the stream path; names lose the '
        "catalog's decoration", () {
      expect(
        Mp3QuranCatalogParser.variantOf(
          Uri.parse('https://qurango.net/radio/a_mojawwad'),
        ),
        RadioVariant.mujawwad,
      );
      expect(
        Mp3QuranCatalogParser.variantOf(
          Uri.parse('https://qurango.net/radio/a_warsh'),
        ),
        RadioVariant.warsh,
      );
      expect(
        Mp3QuranCatalogParser.variantOf(
          Uri.parse('https://qurango.net/radio/a'),
        ),
        RadioVariant.plain,
      );
      expect(
        Mp3QuranCatalogParser.cleanName('Radio Ahmad Al-Ajmy'),
        'Ahmad Al-Ajmy',
      );
      expect(
        Mp3QuranCatalogParser.cleanName('Abdullah Al-Mousa - Radio'),
        'Abdullah Al-Mousa',
      );
      expect(
        Mp3QuranCatalogParser.cleanName('***قصص الأنبياء***'),
        'قصص الأنبياء',
      );
      expect(Mp3QuranCatalogParser.cleanName(' -- '), isNull);
    });
  });

  group('RadioStationId', () {
    test('REQ-RADIO-002 the stored form round-trips; anything else is '
        'rejected', () {
      const id = RadioStationId('mp3quran', 74);
      expect(RadioStationId.parse(id.wire), id);
      for (final wire in ['', '74', ':74', 'mp3quran:', 'mp3quran:x', 'a:0']) {
        expect(RadioStationId.parse(wire), isNull, reason: wire);
      }
    });
  });

  group('RadioCatalog', () {
    test('REQ-RADIO-005 the list is stale after 24 hours, or when dated in '
        'the future', () {
      const catalog = RadioCatalog(stations: [], refreshedUtcMs: 1000000);
      const day = 24 * 60 * 60 * 1000;
      expect(catalog.isStale(1000000 + day - 1), isFalse);
      expect(catalog.isStale(1000000 + day), isTrue);
      expect(catalog.isStale(999999), isTrue);
    });
  });

  group('FileRadioCatalogStore', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('radio_store'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('REQ-RADIO-005 the kept list reads back as written: ids, both '
        'names, streams, descriptions and the refresh time', () async {
      final catalog = _parse(
        ar: _json(_ar),
        en: _json(_en),
        featured: _featured(),
      );
      final store = FileRadioCatalogStore(dir);

      await store.write(catalog);

      expect(await store.read(), catalog);
      expect(
        File('${dir.path}/${FileRadioCatalogStore.fileName}.part').existsSync(),
        isFalse,
      );
    });

    test('REQ-RADIO-005 a missing, corrupt or other-version file reads as '
        'nothing', () async {
      final store = FileRadioCatalogStore(dir);
      expect(await store.read(), isNull);

      final file = File('${dir.path}/${FileRadioCatalogStore.fileName}')
        ..writeAsStringSync('{not json');
      expect(await store.read(), isNull);

      final encoded = FileRadioCatalogStore.encode(
        _parse(ar: _json(_ar)),
      )..['schemaVersion'] = 2;
      file.writeAsStringSync(jsonEncode(encoded));
      expect(await store.read(), isNull);
    });

    test('REQ-RADIO-004 a kept stream on another host is dropped on read', () {
      final encoded = FileRadioCatalogStore.encode(
        _parse(
          ar: _radios([
            {'id': 1, 'name': 'a', 'url': 'https://qurango.net/radio/a'},
            {'id': 2, 'name': 'b', 'url': 'https://qurango.net/radio/b'},
          ]),
        ),
      );
      ((encoded['stations']! as List<Object?>)[1]!
              as Map<String, Object?>)['url'] =
          'https://example.com/b';

      final read = FileRadioCatalogStore.decode(encoded);
      expect(read?.stations.map((s) => s.id.providerId), [1]);
    });
  });

  group('featured stations', () {
    test('REQ-RADIO-003 the bundled file names the four checked stations', () {
      final featured = _featured();
      expect(featured.map((f) => f.providerId), [108, 74, 69, 32]);
      expect(featured.first.nameAr, 'تلاوات متنوعة');
      expect(
        featured.first.description?.en,
        'A selection of Quran recitations',
      );
    });

    test('the schema fixtures decode as the app does: the valid one fully, '
        'each invalid one not as written', () {
      const dir = '../../schemas/fixtures/radio_featured';
      final valid = Directory('$dir/valid').listSync().whereType<File>();
      for (final file in valid) {
        expect(
          AssetFeaturedStations.decode(_json(file.path)),
          hasLength(4),
          reason: file.path,
        );
      }
      final invalid = Directory('$dir/invalid').listSync().whereType<File>();
      expect(invalid, isNotEmpty);
      for (final file in invalid) {
        expect(
          AssetFeaturedStations.decode(_json(file.path)).length,
          lessThan(4),
          reason: file.path,
        );
      }
    });
  });
}
