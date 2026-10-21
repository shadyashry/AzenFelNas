// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchedulePlan _$SchedulePlanFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SchedulePlan', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'schemaVersion',
          'generation',
          'contextId',
          'zoneId',
          'tzdbVersion',
          'generatedAtUtcMs',
          'horizonEndUtcMs',
          'entries',
          'policy',
        ],
      );
      final val = _SchedulePlan(
        schemaVersion: $checkedConvert(
          'schemaVersion',
          (v) => (v as num).toInt(),
        ),
        generation: $checkedConvert('generation', (v) => (v as num).toInt()),
        contextId: $checkedConvert('contextId', (v) => v as String),
        zoneId: $checkedConvert('zoneId', (v) => v as String),
        tzdbVersion: $checkedConvert('tzdbVersion', (v) => v as String),
        generatedAtUtcMs: $checkedConvert(
          'generatedAtUtcMs',
          (v) => (v as num).toInt(),
        ),
        horizonEndUtcMs: $checkedConvert(
          'horizonEndUtcMs',
          (v) => (v as num).toInt(),
        ),
        entries: $checkedConvert(
          'entries',
          (v) => (v as List<dynamic>)
              .map((e) => SchedulePlanEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        policy: $checkedConvert(
          'policy',
          (v) => SchedulePlanPolicy.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SchedulePlanToJson(_SchedulePlan instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'generation': instance.generation,
      'contextId': instance.contextId,
      'zoneId': instance.zoneId,
      'tzdbVersion': instance.tzdbVersion,
      'generatedAtUtcMs': instance.generatedAtUtcMs,
      'horizonEndUtcMs': instance.horizonEndUtcMs,
      'entries': instance.entries.map((e) => e.toJson()).toList(),
      'policy': instance.policy.toJson(),
    };
