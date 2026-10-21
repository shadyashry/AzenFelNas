// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuf_target_custom.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TufTargetCustom _$TufTargetCustomFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TufTargetCustom', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'schemaVersion',
          'payloadFormat',
          'compat',
          'effectiveFrom',
          'priority',
          'changeNote',
          'rollbackOf',
          'attribution',
        ],
      );
      final val = _TufTargetCustom(
        schemaVersion: $checkedConvert(
          'schemaVersion',
          (v) => (v as num).toInt(),
        ),
        payloadFormat: $checkedConvert(
          'payloadFormat',
          (v) => $enumDecode(_$PayloadFormatCodeEnumMap, v),
        ),
        compat: $checkedConvert(
          'compat',
          (v) => TufCompat.fromJson(v as Map<String, dynamic>),
        ),
        effectiveFrom: $checkedConvert('effectiveFrom', (v) => v as String),
        priority: $checkedConvert(
          'priority',
          (v) => $enumDecode(_$TargetPriorityCodeEnumMap, v),
        ),
        changeNote: $checkedConvert(
          'changeNote',
          (v) => TufChangeNote.fromJson(v as Map<String, dynamic>),
        ),
        rollbackOf: $checkedConvert('rollbackOf', (v) => v as String?),
        attribution: $checkedConvert('attribution', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$TufTargetCustomToJson(_TufTargetCustom instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'payloadFormat': _$PayloadFormatCodeEnumMap[instance.payloadFormat]!,
      'compat': instance.compat.toJson(),
      'effectiveFrom': instance.effectiveFrom,
      'priority': _$TargetPriorityCodeEnumMap[instance.priority]!,
      'changeNote': instance.changeNote.toJson(),
      'rollbackOf': ?instance.rollbackOf,
      'attribution': ?instance.attribution,
    };

const _$PayloadFormatCodeEnumMap = {
  PayloadFormatCode.json: 'json',
  PayloadFormatCode.bin: 'bin',
  PayloadFormatCode.sqlite: 'sqlite',
};

const _$TargetPriorityCodeEnumMap = {
  TargetPriorityCode.normal: 'normal',
  TargetPriorityCode.urgent: 'urgent',
};
