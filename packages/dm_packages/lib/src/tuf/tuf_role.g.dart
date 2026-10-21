// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuf_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TufRole _$TufRoleFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TufRole', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['keyIds', 'threshold']);
      final val = _TufRole(
        keyIds: $checkedConvert(
          'keyIds',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        threshold: $checkedConvert('threshold', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$TufRoleToJson(_TufRole instance) => <String, dynamic>{
  'keyIds': instance.keyIds,
  'threshold': instance.threshold,
};
