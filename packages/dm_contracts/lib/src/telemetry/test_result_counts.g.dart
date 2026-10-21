// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_result_counts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TestResultCounts _$TestResultCountsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TestResultCounts', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['heard', 'notHeard', 'unknown']);
      final val = _TestResultCounts(
        heard: $checkedConvert('heard', (v) => (v as num).toInt()),
        notHeard: $checkedConvert('notHeard', (v) => (v as num).toInt()),
        unknown: $checkedConvert('unknown', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$TestResultCountsToJson(_TestResultCounts instance) =>
    <String, dynamic>{
      'heard': instance.heard,
      'notHeard': instance.notHeard,
      'unknown': instance.unknown,
    };
