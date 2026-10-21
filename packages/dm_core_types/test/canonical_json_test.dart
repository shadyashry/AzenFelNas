import 'dart:convert';
import 'dart:io';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:test/test.dart';

// Moved from geo_salah_core in S09: the engine's Calculation ID
// (REQ-DOM-004) and the package client's TUF-lite signatures (REQ-DIST-004)
// hash the same canonical form.
void main() {
  group('CanonicalJson (RFC 8785, REQ-DOM-004, REQ-DIST-004)', () {
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

  // The vectors gsctl's Go JCS also passes: Go-signed metadata verifies in
  // Dart only if both write the same canonical bytes (REQ-DIST-004).
  group('CanonicalJson matches the shared Go vectors (REQ-DIST-004)', () {
    final file = File('../../tools/gsctl/testdata/jcs/vectors.json');
    final vectors = switch (jsonDecode(file.readAsStringSync())) {
      {'vectors': final List<Object?> list} => list,
      _ => throw const FormatException('vectors.json has no vectors'),
    };
    for (final vector in vectors) {
      final (name, input, canonical) = switch (vector) {
        {
          'name': final String name,
          'input': final String input,
          'canonical': final String canonical,
        } =>
          (name, input, canonical),
        _ => throw FormatException('malformed vector $vector'),
      };
      test(name, () {
        expect(CanonicalJson.encode(jsonDecode(input)), canonical);
      });
    }
  });
}
