// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_counters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TelemetryCounters _$TelemetryCountersFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TelemetryCounters', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'packageActivations',
          'healthState',
          'testResults',
          'syncOutcome',
        ],
      );
      final val = _TelemetryCounters(
        packageActivations: $checkedConvert(
          'packageActivations',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) => MapEntry(
              $enumDecode(_$PackageTypeCodeEnumMap, k),
              (e as num).toInt(),
            ),
          ),
        ),
        healthState: $checkedConvert(
          'healthState',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) => MapEntry(
              $enumDecode(_$HealthStateCodeEnumMap, k),
              (e as num).toInt(),
            ),
          ),
        ),
        testResults: $checkedConvert(
          'testResults',
          (v) => TestResultCounts.fromJson(v as Map<String, dynamic>),
        ),
        syncOutcome: $checkedConvert(
          'syncOutcome',
          (v) => SyncOutcomeCounts.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TelemetryCountersToJson(_TelemetryCounters instance) =>
    <String, dynamic>{
      'packageActivations': instance.packageActivations.map(
        (k, e) => MapEntry(_$PackageTypeCodeEnumMap[k]!, e),
      ),
      'healthState': instance.healthState.map(
        (k, e) => MapEntry(_$HealthStateCodeEnumMap[k]!, e),
      ),
      'testResults': instance.testResults.toJson(),
      'syncOutcome': instance.syncOutcome.toJson(),
    };

const _$PackageTypeCodeEnumMap = {
  PackageTypeCode.prayerProfiles: 'prayer_profiles',
  PackageTypeCode.tzdata: 'tzdata',
  PackageTypeCode.tzPolygons: 'tz_polygons',
  PackageTypeCode.countryPolygons: 'country_polygons',
  PackageTypeCode.gazetteer: 'gazetteer',
  PackageTypeCode.hijri: 'hijri',
  PackageTypeCode.athanAudioManifest: 'athan_audio_manifest',
};

const _$HealthStateCodeEnumMap = {
  HealthStateCode.ready: 'READY',
  HealthStateCode.limited: 'LIMITED',
  HealthStateCode.notReady: 'NOT_READY',
  HealthStateCode.unknown: 'UNKNOWN',
};
