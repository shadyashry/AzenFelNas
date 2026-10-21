import 'dart:convert';
import 'dart:io';

import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';

void main() {
  roundTripValidFixtures<PrayerProfileDocument>(
    'prayer_profile',
    decode: (json) => PrayerProfileDocument.fromJson(asJsonObject(json)),
    encode: (model) => model.toJson(),
  );

  test('prayer_profile model rejects an unknown top-level key', () {
    final json = jsonDecode(
      File(
        '../../schemas/fixtures/prayer_profile/invalid/unknown_top_level_key.json',
      ).readAsStringSync(),
    );

    expect(
      () => PrayerProfileDocument.fromJson(asJsonObject(json)),
      throwsA(isA<CheckedFromJsonException>()),
    );
  });
}
