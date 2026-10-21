// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuf_roles.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TufRoles _$TufRolesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TufRoles', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['root', 'targets', 'snapshot', 'timestamp'],
      );
      final val = _TufRoles(
        root: $checkedConvert(
          'root',
          (v) => TufRole.fromJson(v as Map<String, dynamic>),
        ),
        targets: $checkedConvert(
          'targets',
          (v) => TufRole.fromJson(v as Map<String, dynamic>),
        ),
        snapshot: $checkedConvert(
          'snapshot',
          (v) => TufRole.fromJson(v as Map<String, dynamic>),
        ),
        timestamp: $checkedConvert(
          'timestamp',
          (v) => TufRole.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TufRolesToJson(_TufRoles instance) => <String, dynamic>{
  'root': instance.root.toJson(),
  'targets': instance.targets.toJson(),
  'snapshot': instance.snapshot.toJson(),
  'timestamp': instance.timestamp.toJson(),
};
