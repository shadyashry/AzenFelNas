import 'dart:convert';
import 'dart:io';

import 'package:daily_muslim/features/contexts/application/import_gazetteer.dart';
import 'package:daily_muslim/features/contexts/application/search_gazetteer.dart';
import 'package:daily_muslim/features/contexts/data/json_gazetteer_payload_decoder.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_gazetteer_store.dart';
import 'support/places.dart';

const _fixtures = '../../schemas/fixtures/gazetteer_package';

List<int> _encode(Object? document) => utf8.encode(jsonEncode(document));

Map<String, Object?> _cairo() => {
  'id': 360630,
  'name': 'Cairo',
  'asciiName': 'Cairo',
  'altNames': {
    'ar': ['القاهرة'],
    'en': ['Kairo'],
  },
  'country': 'EG',
  'admin1': '11',
  'lat': 30.06263,
  'lon': 31.24967,
  'population': 9606916,
  'zoneId': 'Africa/Cairo',
};

void main() {
  const decoder = JsonGazetteerPayloadDecoder();

  group('JsonGazetteerPayloadDecoder follows gazetteer_package.v1', () {
    for (final file in Directory(
      '$_fixtures/valid',
    ).listSync().whereType<File>()) {
      test('decodes valid/${file.uri.pathSegments.last}', () async {
        final result = await decoder.decode(file.readAsBytesSync());
        expect(result, isA<Ok<Object?, GazetteerFailure>>());
      });
    }
    for (final file in Directory(
      '$_fixtures/invalid',
    ).listSync().whereType<File>()) {
      test(
        'REQ-PKG-001 refuses invalid/${file.uri.pathSegments.last}',
        () async {
          final result = await decoder.decode(file.readAsBytesSync());
          expect(
            result,
            isA<Err<Object?, GazetteerFailure>>().having(
              (e) => e.failure.code,
              'code',
              FailureCode.pkgSigInvalid,
            ),
          );
        },
      );
    }

    final invalid = <String, Object?>{
      'not UTF-8 JSON': null,
      'an item that is not an object': [1],
      'a duplicate id': [_cairo(), _cairo()],
      'a country that is not alpha-2': [
        {..._cairo(), 'country': 'EGY'},
      ],
      'a zone id with a space': [
        {..._cairo(), 'zoneId': 'Africa/Ca iro'},
      ],
      'an empty alternate name': [
        {
          ..._cairo(),
          'altNames': {
            'ar': [''],
            'en': <String>[],
          },
        },
      ],
      'an unknown key': [
        {..._cairo(), 'elevation': 23},
      ],
    };
    for (final MapEntry(:key, :value) in invalid.entries) {
      test('REQ-PKG-001 refuses $key', () async {
        final bytes = value == null ? [0xFF, 0xFE] : _encode(value);
        expect(
          await decoder.decode(bytes),
          isA<Err<Object?, GazetteerFailure>>(),
        );
      });
    }

    test('maps names, location and zone to the domain place', () async {
      final result = await decoder.decode(_encode([_cairo()]));
      final place = switch (result) {
        Ok(:final value) => value.single,
        Err(:final failure) => fail('$failure'),
      };
      expect(place.arabicNames, ['القاهرة']);
      expect(place.englishNames, ['Kairo']);
      expect((place.point.latE6, place.point.lonE6), (30062630, 31249670));
      expect(place.zoneId, 'Africa/Cairo');
    });
  });

  group('ImportGazetteer', () {
    late FakeGazetteerStore store;
    late ImportGazetteer importGazetteer;
    late SearchGazetteer search;

    setUp(() async {
      store = FakeGazetteerStore();
      importGazetteer = ImportGazetteer(decoder, store);
      search = SearchGazetteer(store);
      await store.replaceAll(samplePlaces);
    });

    Future<int> hitsFor(String query) async => switch (await search(query)) {
      Ok(:final value) => value.length,
      Err(:final failure) => fail('$failure'),
    };

    test('replaces the stored places with the payload', () async {
      expect(
        await importGazetteer(_encode([_cairo()])),
        const Ok<int, GazetteerFailure>(1),
      );
      expect(await hitsFor('Kairo'), 1);
      expect(await hitsFor('Zurich'), 0);
    });

    test('REQ-PKG-001 an invalid payload keeps the previous places', () async {
      final result = await importGazetteer(_encode({'not': 'an array'}));
      expect(result, isA<Err<int, GazetteerFailure>>());
      expect(await hitsFor('Zurich'), 1);
    });

    test(
      'REQ-ERR-001 a storage failure comes back as a typed failure',
      () async {
        store.failWith = const GazetteerFailure.storage('disk full');
        final result = await importGazetteer(_encode([_cairo()]));
        expect(
          result,
          const Err<int, GazetteerFailure>(
            GazetteerFailure.storage('disk full'),
          ),
        );
        expect(
          result,
          isA<Err<int, GazetteerFailure>>().having(
            (e) => e.failure.code,
            'code',
            FailureCode.pkgStorage,
          ),
        );
      },
    );
  });

  group('SearchGazetteer', () {
    final search = SearchGazetteer(FakeGazetteerStore());

    test('a query with no letter or digit finds nothing', () async {
      expect(
        await search(' - '),
        isA<Ok<List<Object?>, GazetteerFailure>>().having(
          (ok) => ok.value,
          'value',
          isEmpty,
        ),
      );
    });

    test('the limit is between 1 and 200', () {
      expect(() => search('cairo', limit: 0), throwsRangeError);
      expect(() => search('cairo', limit: 201), throwsRangeError);
    });
  });
}
