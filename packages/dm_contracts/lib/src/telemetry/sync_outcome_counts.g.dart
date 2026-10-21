// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_outcome_counts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncOutcomeCounts _$SyncOutcomeCountsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SyncOutcomeCounts', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['ok', 'warn', 'fail']);
      final val = _SyncOutcomeCounts(
        ok: $checkedConvert('ok', (v) => (v as num).toInt()),
        warn: $checkedConvert('warn', (v) => (v as num).toInt()),
        fail: $checkedConvert('fail', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$SyncOutcomeCountsToJson(_SyncOutcomeCounts instance) =>
    <String, dynamic>{
      'ok': instance.ok,
      'warn': instance.warn,
      'fail': instance.fail,
    };
