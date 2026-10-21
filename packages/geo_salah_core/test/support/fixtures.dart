import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

/// Registers one test per `schemas/fixtures/<schema>/valid/*.json`: decode it
/// with [decode], encode the model with [encode], and expect JSON equal to the
/// fixture (ADR-023 round-trip). Fails when the schema has no valid fixture.
void roundTripValidFixtures<T>(
  String schema, {
  required T Function(Object? json) decode,
  required Object? Function(T model) encode,
}) {
  final dir = Directory('../../schemas/fixtures/$schema/valid');
  final files =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  test('$schema has valid fixtures', () {
    expect(files, isNotEmpty);
  });
  for (final file in files) {
    final name = file.uri.pathSegments.last;
    test('$schema fixture $name round-trips unchanged', () {
      // Arrange
      final original = jsonDecode(file.readAsStringSync());

      // Act
      final reencoded = jsonDecode(jsonEncode(encode(decode(original))));

      // Assert
      expect(reencoded, original);
    });
  }
}

/// [json] as a JSON object; throws [FormatException] otherwise.
Map<String, Object?> asJsonObject(Object? json) => switch (json) {
  final Map<String, Object?> map => map,
  _ => throw FormatException('Expected a JSON object: $json'),
};

/// [json] as a JSON array; throws [FormatException] otherwise.
List<Object?> asJsonList(Object? json) => switch (json) {
  final List<Object?> list => list,
  _ => throw FormatException('Expected a JSON array: $json'),
};
