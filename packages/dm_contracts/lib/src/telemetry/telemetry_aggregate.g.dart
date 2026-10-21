// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_aggregate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TelemetryAggregate _$TelemetryAggregateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TelemetryAggregate', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'schemaVersion',
          'day',
          'appVersion',
          'platform',
          'osMajor',
          'counters',
          'countryCode',
        ],
      );
      final val = _TelemetryAggregate(
        schemaVersion: $checkedConvert(
          'schemaVersion',
          (v) => (v as num).toInt(),
        ),
        day: $checkedConvert('day', (v) => v as String),
        appVersion: $checkedConvert('appVersion', (v) => v as String),
        platform: $checkedConvert(
          'platform',
          (v) => $enumDecode(_$TelemetryPlatformEnumMap, v),
        ),
        osMajor: $checkedConvert('osMajor', (v) => (v as num).toInt()),
        counters: $checkedConvert(
          'counters',
          (v) => TelemetryCounters.fromJson(v as Map<String, dynamic>),
        ),
        countryCode: $checkedConvert('countryCode', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$TelemetryAggregateToJson(_TelemetryAggregate instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'day': instance.day,
      'appVersion': instance.appVersion,
      'platform': _$TelemetryPlatformEnumMap[instance.platform]!,
      'osMajor': instance.osMajor,
      'counters': instance.counters.toJson(),
      'countryCode': ?instance.countryCode,
    };

const _$TelemetryPlatformEnumMap = {
  TelemetryPlatform.android: 'android',
  TelemetryPlatform.ios: 'ios',
};
