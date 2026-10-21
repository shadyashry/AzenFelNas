// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuf_target.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TufTarget _$TufTargetFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TufTarget', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['length', 'sha256', 'custom']);
      final val = _TufTarget(
        length: $checkedConvert('length', (v) => (v as num).toInt()),
        sha256: $checkedConvert('sha256', (v) => v as String),
        custom: $checkedConvert(
          'custom',
          (v) => TufTargetCustom.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TufTargetToJson(_TufTarget instance) =>
    <String, dynamic>{
      'length': instance.length,
      'sha256': instance.sha256,
      'custom': instance.custom.toJson(),
    };
