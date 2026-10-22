import 'dart:math';
import 'dart:typed_data';

import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:test/test.dart';

import '../support/pinned_tzdata.dart';

TzdbFailure _failure(Uint8List bytes, {String version = '2026e'}) =>
    switch (const ReadTzfDatabase()(bytes, version: version)) {
      Ok() => throw StateError('expected a failure'),
      Err(:final failure) => failure,
    };

/// One location chunk holding [name], one zone and no transitions.
Uint8List _chunk(String name, {int offsetSeconds = 0, int abbreviation = 0}) {
  final abbreviationsAt = 32 + name.length;
  final zonesAt = (abbreviationsAt + 4 + 3) & ~3;
  final transitionsAt = (zonesAt + 8 + 7) & ~7;
  final location = ByteData(transitionsAt);
  final words = [
    32,
    name.length,
    abbreviationsAt,
    4,
    zonesAt,
    1,
    transitionsAt,
    0,
  ];
  for (var i = 0; i < words.length; i++) {
    location.setUint32(i * 4, words[i]);
  }
  final bytes = location.buffer.asUint8List()
    ..setAll(32, name.codeUnits)
    ..setAll(abbreviationsAt, 'UTC\u0000'.codeUnits);
  location
    ..setInt32(zonesAt, offsetSeconds)
    ..setUint8(zonesAt + 5, abbreviation);
  final header = ByteData(8)..setUint32(0, transitionsAt);
  return Uint8List.fromList([...header.buffer.asUint8List(), ...bytes]);
}

void main() {
  final pinned = PinnedTzdata.load();

  group('ReadTzfDatabase (REQ-TIME-020)', () {
    test('reads every zone of the pinned payload (REQ-TIME-020)', () {
      final db = pinned.database;
      expect(db.version, '2026e');
      expect(db.zoneIds, hasLength(598));
      expect(db.zoneIds, containsAll(['Africa/Cairo', 'Asia/Riyadh', 'UTC']));
    });

    test('reads a minimal hand-built location (REQ-TIME-020)', () {
      final result = const ReadTzfDatabase()(
        _chunk('Etc/Test', offsetSeconds: 3600),
        version: '2026e',
      );
      final db = switch (result) {
        Ok(:final value) => value,
        Err() => fail('not read'),
      };
      expect(db.offsetSecondsAt('Etc/Test', 0), 3600);
    });

    test('refuses a version that is not an IANA release name', () {
      expect(
        _failure(pinned.payload, version: '0000').code,
        FailureCode.pkgSigInvalid,
      );
    });

    test('refuses an empty payload, a truncated chunk and a bad length', () {
      final valid = _chunk('Etc/Test');
      expect(_failure(Uint8List(0)).detail, 'no zones');
      expect(
        _failure(Uint8List.sublistView(valid, 0, 20)),
        isA<TzdbPayloadInvalid>(),
      );
      final odd = Uint8List.fromList(valid)..[3] = 41;
      expect(_failure(odd), isA<TzdbPayloadInvalid>());
    });

    test('refuses a duplicate zone, a bad abbreviation and a huge offset', () {
      final one = _chunk('Etc/Test');
      expect(
        _failure(Uint8List.fromList([...one, ...one])).detail,
        contains('twice'),
      );
      expect(
        _failure(_chunk('Etc/Test', abbreviation: 1)).detail,
        contains('zone 0'),
      );
      expect(
        _failure(_chunk('Etc/Test', offsetSeconds: 26 * 3600 + 1)).detail,
        contains('zone 0'),
      );
    });

    test('answers corrupted bytes with a failure, never an exception', () {
      // Arrange: 400 single-byte corruptions of the pinned payload.
      final random = Random(20261022);
      final payload = pinned.payload;
      for (var i = 0; i < 400; i++) {
        final copy = Uint8List.fromList(payload);
        final at = random.nextInt(copy.length);
        copy[at] ^= 1 + random.nextInt(255);

        // Act + Assert: Ok (a value byte) or a typed failure.
        expect(
          () => const ReadTzfDatabase()(copy, version: '2026e'),
          returnsNormally,
          reason: 'byte $at',
        );
      }
    });
  });
}
