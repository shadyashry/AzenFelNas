import 'dart:convert';
import 'dart:io';

import 'package:dm_packages/dm_packages.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  roundTripValidFixtures<TufMetadata>(
    'tuf_metadata',
    decode: (json) => TufMetadata.fromJson(asJsonObject(json)),
    encode: (model) => model.toJson(),
  );

  test(
    'tuf_metadata model rejects the invalid fixture unknown_role_type.json',
    () {
      final json = jsonDecode(
        File(
          '../../schemas/fixtures/tuf_metadata/invalid/unknown_role_type.json',
        ).readAsStringSync(),
      );

      expect(
        () => TufMetadata.fromJson(asJsonObject(json)),
        throwsA(isA<CheckedFromJsonException>()),
      );
    },
  );
}
