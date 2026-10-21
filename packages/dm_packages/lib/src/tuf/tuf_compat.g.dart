// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuf_compat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TufCompat _$TufCompatFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TufCompat', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['minApp', 'minEngineSchema']);
      final val = _TufCompat(
        minApp: $checkedConvert('minApp', (v) => v as String),
        minEngineSchema: $checkedConvert(
          'minEngineSchema',
          (v) => (v as num).toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TufCompatToJson(_TufCompat instance) =>
    <String, dynamic>{
      'minApp': instance.minApp,
      'minEngineSchema': instance.minEngineSchema,
    };
