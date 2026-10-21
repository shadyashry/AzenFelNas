import 'dart:convert';
import 'dart:io';

import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';

import 'support/fixtures.dart';

void main() {
  roundTripValidFixtures<SchedulePlan>(
    'schedule_plan',
    decode: (json) => SchedulePlan.fromJson(asJsonObject(json)),
    encode: (model) => model.toJson(),
  );
  roundTripValidFixtures<Snapshot>(
    'snapshot',
    decode: (json) => Snapshot.fromJson(asJsonObject(json)),
    encode: (model) => model.toJson(),
  );
  roundTripValidFixtures<EventLogEntry>(
    'event_log',
    decode: (json) => EventLogEntry.fromJson(asJsonObject(json)),
    encode: (model) => model.toJson(),
  );
  roundTripValidFixtures<TelemetryAggregate>(
    'telemetry_aggregate',
    decode: (json) => TelemetryAggregate.fromJson(asJsonObject(json)),
    encode: (model) => model.toJson(),
  );
  roundTripValidFixtures<AthanAudioManifest>(
    'athan_audio_manifest',
    decode: (json) => AthanAudioManifest.fromJson(asJsonObject(json)),
    encode: (model) => model.toJson(),
  );
  roundTripValidFixtures<List<GazetteerPlace>>(
    'gazetteer_package',
    decode: (json) => [
      for (final place in asJsonList(json))
        GazetteerPlace.fromJson(asJsonObject(place)),
    ],
    encode: (places) => [for (final place in places) place.toJson()],
  );

  test('schedule_plan model rejects the invalid fixture unknown_key.json', () {
    final json = jsonDecode(
      File('../../schemas/fixtures/schedule_plan/invalid/unknown_key.json')
          .readAsStringSync(),
    );

    expect(
      () => SchedulePlan.fromJson(asJsonObject(json)),
      throwsA(isA<CheckedFromJsonException>()),
    );
  });
}
