// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_log_attrs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventLogAttrs _$EventLogAttrsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_EventLogAttrs', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'code',
          'generation',
          'entryId',
          'packageType',
          'version',
          'state',
          'reason',
          'durationMs',
          'count',
          'zoneId',
          'countryCode',
        ],
      );
      final val = _EventLogAttrs(
        code: $checkedConvert(
          'code',
          (v) => _$JsonConverterFromJson<String, FailureCode>(
            v,
            const FailureCodeConverter().fromJson,
          ),
        ),
        generation: $checkedConvert('generation', (v) => (v as num?)?.toInt()),
        entryId: $checkedConvert('entryId', (v) => v as String?),
        packageType: $checkedConvert('packageType', (v) => v as String?),
        version: $checkedConvert('version', (v) => v as String?),
        state: $checkedConvert('state', (v) => v as String?),
        reason: $checkedConvert('reason', (v) => v as String?),
        durationMs: $checkedConvert('durationMs', (v) => (v as num?)?.toInt()),
        count: $checkedConvert('count', (v) => (v as num?)?.toInt()),
        zoneId: $checkedConvert('zoneId', (v) => v as String?),
        countryCode: $checkedConvert('countryCode', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$EventLogAttrsToJson(_EventLogAttrs instance) =>
    <String, dynamic>{
      'code': ?_$JsonConverterToJson<String, FailureCode>(
        instance.code,
        const FailureCodeConverter().toJson,
      ),
      'generation': ?instance.generation,
      'entryId': ?instance.entryId,
      'packageType': ?instance.packageType,
      'version': ?instance.version,
      'state': ?instance.state,
      'reason': ?instance.reason,
      'durationMs': ?instance.durationMs,
      'count': ?instance.count,
      'zoneId': ?instance.zoneId,
      'countryCode': ?instance.countryCode,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
