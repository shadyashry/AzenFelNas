import 'dart:typed_data';

import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:test/test.dart';

import '../support/pinned_polygons.dart';
import '../support/polygon_payload.dart';

Uint8List _twoZones() =>
    (PolygonPayload('TZPG')
          ..box('Zone/West', 10, 10, 11, 11)
          ..add('Zone/East', [
            [
              (11000000, 10000000),
              (13000000, 10000000),
              (13000000, 12000000),
              (11000000, 12000000),
            ],
            [
              (12000000, 11000000),
              (12500000, 11000000),
              (12500000, 11500000),
              (12000000, 11500000),
            ],
          ]))
        .build();

PolygonIndex _read(Uint8List payload, PolygonDataset dataset) =>
    switch (const ReadPolygonIndex()(payload, dataset: dataset)) {
      Ok(:final value) => value,
      Err(:final failure) => fail('$failure'),
    };

String? _failure(
  Uint8List payload, [
  PolygonDataset dataset = PolygonDataset.tz,
]) => switch (const ReadPolygonIndex()(payload, dataset: dataset)) {
  Ok() => null,
  Err(:final failure) => failure.detail,
};

Uint8List _patched(Uint8List payload, int at, List<int> bytes) =>
    Uint8List.fromList(payload)..setRange(at, at + bytes.length, bytes);

void main() {
  group('ReadPolygonIndex', () {
    test(
      'reads names and polygons, and the even-odd rule leaves holes out',
      () {
        final index = _read(_twoZones(), PolygonDataset.tz);
        expect(index.names, ['Zone/West', 'Zone/East']);
        expect(index.polygonCount, 2);
        expect(
          index.locate(GeoPointE6(10500000, 10500000), searchRadiusM: 1000),
          isA<InsidePolygon>().having((m) => m.name, 'name', 'Zone/West'),
        );
        expect(
          index.locate(GeoPointE6(11250000, 12001000), searchRadiusM: 1000),
          isA<NearPolygon>().having((m) => m.name, 'name', 'Zone/East'),
          reason: 'inside the hole, 109 m from its edge',
        );
      },
    );

    test('REQ-PKG-001 a payload of the other dataset is a typed failure', () {
      expect(
        _failure(_twoZones(), PolygonDataset.country),
        'magic is not CTPG',
      );
    });

    test(
      'REQ-PKG-001 every malformed payload is PKG_SIG_INVALID, never a throw',
      () {
        final good = _twoZones();
        final cases = <String, Uint8List>{
          'empty': Uint8List(0),
          'truncated': Uint8List.sublistView(good, 0, good.length - 3),
          'trailing bytes': Uint8List.fromList([...good, 0]),
          'version 2': _patched(good, 4, [2, 0]),
          'no names': _patched(PolygonPayload('TZPG').build(), 6, [0, 0, 0, 0]),
        };
        for (final MapEntry(key: name, value: payload) in cases.entries) {
          final result = const ReadPolygonIndex()(
            payload,
            dataset: PolygonDataset.tz,
          );
          expect(
            result,
            isA<Err<PolygonIndex, PolygonIndexFailure>>(),
            reason: name,
          );
          if (result case Err(:final failure)) {
            expect(failure.code, FailureCode.pkgSigInvalid, reason: name);
          }
        }
      },
    );

    test('REQ-PKG-001 corrupting any single byte never throws', () {
      final good = _twoZones();
      // Header and names, a sample of the grid, and every polygon byte.
      final positions = {
        for (var at = 0; at < 40; at++) at,
        for (var at = 40; at < good.length - 300; at += 4099) at,
        for (var at = good.length - 300; at < good.length; at++) at,
      };
      for (final at in positions) {
        final bad = _patched(good, at, [good[at] ^ 0xa5]);
        expect(
          () => const ReadPolygonIndex()(bad, dataset: PolygonDataset.tz),
          returnsNormally,
        );
      }
    });

    test('an open ring and a point outside its box are refused', () {
      final good = _twoZones();
      // The last s4 of the payload is the hole's closing lat delta.
      final open = _patched(good, good.length - 4, [1, 0, 0, 0]);
      expect(_failure(open), 'polygon 1 ring 1 is not closed');
      final outside = _patched(good, good.length - 8, [0, 0, 0, 0x10]);
      expect(_failure(outside), 'polygon 1 ring 1 point 4 outside its box');
    });

    test('the pinned packages read, with the expected name tables', () {
      final tz = PinnedPolygons.load(PolygonDataset.tz).index;
      final country = PinnedPolygons.load(PolygonDataset.country).index;
      expect(
        tz.names,
        containsAll(['Africa/Cairo', 'Asia/Riyadh', 'Europe/London']),
      );
      expect(country.names, containsAll(['EG', 'SA', 'GB', 'FR', 'NO']));
      expect(country.names.every(RegExp(r'^[A-Z]{2}$').hasMatch), isTrue);
    });
  });
}
