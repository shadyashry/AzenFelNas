// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DiagnosticPlan _$DiagnosticPlanFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_DiagnosticPlan', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['status', 'generation', 'entryCount'],
      );
      final val = _DiagnosticPlan(
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$DiagnosticPlanStatusEnumMap, v),
        ),
        generation: $checkedConvert('generation', (v) => (v as num?)?.toInt()),
        entryCount: $checkedConvert('entryCount', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$DiagnosticPlanToJson(_DiagnosticPlan instance) =>
    <String, dynamic>{
      'status': _$DiagnosticPlanStatusEnumMap[instance.status]!,
      'generation': ?instance.generation,
      'entryCount': ?instance.entryCount,
    };

const _$DiagnosticPlanStatusEnumMap = {
  DiagnosticPlanStatus.notApplied: 'notApplied',
  DiagnosticPlanStatus.applied: 'applied',
};
