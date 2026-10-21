import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/trace/canonical_json.dart';
import 'package:test/test.dart';

import '../support/engine_fixtures.dart';

// Expected values computed independently with Python's hashlib and base64
// (RFC 4648) from the canonical string below.
const String _canonicalInputs =
    '{"day":"2026-03-20","hijri":{"confidence":"EXPECTED",'
    '"dateAtDawn":{"day":1,"month":10,"year":1447},'
    '"dateAtNight":{"day":2,"month":10,"year":1447}},'
    '"lat":21.42,"lon":39.83,"profileId":"engine.default",'
    '"profileVersion":"0000.0.0","zoneId":"Asia/Riyadh"}';
const String _inputsHash =
    'f4c9269663ee65537b9bf0eeae33db5ae547249a668004dd706ef07311fda42c';

CalculationInputs _inputs({double lat = 21.42}) => CalculationInputs.of(
  observer: Observer(
    latitudeDeg: lat,
    longitudeDeg: 39.83,
    zoneId: 'Asia/Riyadh',
    source: ObserverSource.benchmark,
  ),
  profile: testProfile,
  day: CivilDate(2026, 3, 20),
  hijri: testHijri,
);

void main() {
  group('CanonicalJson (RFC 8785)', () {
    test('sorts members by code unit and writes no whitespace', () {
      expect(
        CanonicalJson.encode({
          'b': [1, true, null],
          'a': {'z': 'x', 'B': 'y'},
        }),
        '{"a":{"B":"y","z":"x"},"b":[1,true,null]}',
      );
    });

    test('writes numbers in the ECMAScript form', () {
      expect(CanonicalJson.encode(1.0), '1');
      expect(CanonicalJson.encode(-0.0), '0');
      expect(CanonicalJson.encode(25.2), '25.2');
      expect(CanonicalJson.encode(-7.59), '-7.59');
      expect(CanonicalJson.encode(0.000001), '0.000001');
      expect(CanonicalJson.encode(1e-7), '1e-7');
      expect(CanonicalJson.encode(1e21), '1e+21');
      expect(() => CanonicalJson.encode(double.nan), throwsArgumentError);
    });

    test('escapes only quote, backslash and C0 controls', () {
      expect(
        CanonicalJson.encode('a"b\\c\n\u0001é'),
        r'"a\"b\\c\n\u0001'
        'é"',
      );
    });
  });

  group('CalculationInputs', () {
    test('hashes the canonical inputs object with SHA-256 (§6.4 ¶11)', () {
      final inputs = _inputs();
      expect(CanonicalJson.encode(inputs.toJson()), _canonicalInputs);
      expect(inputs.inputsHash, _inputsHash);
    });

    test('rounds coordinates to 6 decimals', () {
      expect(CalculationInputs.round6(30.0400004), 30.04);
      expect(CalculationInputs.round6(-7.5900006), -7.590001);
      expect(CalculationInputs.round6(-0.0000004), 0);
      expect(_inputs(lat: 21.4200004).inputsHash, _inputsHash);
    });

    test('is the calculation_trace.v1 inputs object', () {
      final json = _inputs().toJson();
      expect(TraceInputsDocument.fromJson(json).toJson(), json);
    });
  });

  group('CalculationId', () {
    test('encodes RFC 4648 base32 test vectors without padding', () {
      for (final MapEntry(key: text, value: encoded) in {
        '': '',
        'f': 'MY',
        'fo': 'MZXQ',
        'foo': 'MZXW6',
        'foob': 'MZXW6YQ',
        'fooba': 'MZXW6YTB',
        'foobar': 'MZXW6YTBOI',
      }.entries) {
        expect(CalculationId.base32(utf8.encode(text)), encoded);
      }
    });

    test('is GS- + base32 of the first 10 bytes of '
        'sha256(inputsHash|engineVersion|deltaTModel|tzdbVersion) '
        '(§6.4 ¶11)', () {
      expect(
        CalculationId.of(
          inputsHash: _inputsHash,
          engineVersion: '0.1.0',
          deltaTModel: 'espenak-meeus-2006',
          tzdbVersion: '2026b',
        ),
        'GS-D7TNFMX2YPUTID37',
      );
    });

    test('changes with any provenance part and only with them '
        '(REQ-DOM-004)', () {
      String id({String tzdb = '2026b', String engine = '0.1.0'}) =>
          CalculationId.of(
            inputsHash: _inputsHash,
            engineVersion: engine,
            deltaTModel: 'espenak-meeus-2006',
            tzdbVersion: tzdb,
          );
      expect(id(), id());
      expect(id(tzdb: '2026c'), isNot(id()));
      expect(id(engine: '0.1.1'), isNot(id()));
    });
  });
}
