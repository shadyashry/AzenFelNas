import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';
import 'package:test/test.dart';

import '../tool/yaml_json.dart';
import 'support/profile_files.dart';

const ParseProfileSetPayload _parse = ParseProfileSetPayload();

List<int> _payload(Object? json) => utf8.encode(jsonEncode(json));

List<Object?> _seedDocuments() => [
  for (final file in seedProfileFiles()) readYamlAsJson(file),
];

String _failureCode(Result<ProfileSet, ProfileFailure> result) =>
    switch (result) {
      Ok() => 'ok',
      Err(:final failure) => failure.code.wire,
    };

void main() {
  group('ParseProfileSetPayload (REQ-PKG-003, §15 D60)', () {
    test('REQ-PKG-003 reads the seed profiles.json array into a validated '
        'set in payload order', () {
      final result = _parse(_payload(_seedDocuments()));
      final ids = switch (result) {
        Ok(:final value) => [for (final p in value.profiles) p.profileId],
        Err(:final failure) => fail(failure.detail),
      };
      expect(ids, [
        for (final profile in seedProfiles()) profile.profileId,
      ]);
    });

    test('REQ-PKG-003 refuses bytes that are not UTF-8 JSON as '
        'PROFILE_INVALID', () {
      expect(_failureCode(_parse(utf8.encode('[{'))), 'PROFILE_INVALID');
      expect(_failureCode(_parse(const [0xff, 0xfe])), 'PROFILE_INVALID');
    });

    test('REQ-PKG-003 refuses an object or an empty array at the top '
        'level', () {
      expect(_failureCode(_parse(_payload({'a': 1}))), 'PROFILE_INVALID');
      expect(_failureCode(_parse(_payload(<Object?>[]))), 'PROFILE_INVALID');
    });

    test('REQ-PKG-003 returns the failure of the first bad document', () {
      final documents = [..._seedDocuments(), <String, Object?>{}];
      expect(_failureCode(_parse(_payload(documents))), 'PROFILE_INVALID');
    });

    test('REQ-PKG-003 refuses a repeated profileId@version through '
        'ValidateProfileSet', () {
      final documents = _seedDocuments();
      expect(
        _failureCode(_parse(_payload([...documents, documents.first]))),
        isNot('ok'),
      );
    });
  });
}
