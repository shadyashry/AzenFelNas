// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuf_signed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TufRootSigned _$TufRootSignedFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TufRootSigned', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['version', 'expires', 'keys', 'roles', 'type'],
      );
      final val = TufRootSigned(
        version: $checkedConvert('version', (v) => (v as num).toInt()),
        expires: $checkedConvert('expires', (v) => v as String),
        keys: $checkedConvert(
          'keys',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, TufKey.fromJson(e as Map<String, dynamic>)),
          ),
        ),
        roles: $checkedConvert(
          'roles',
          (v) => TufRoles.fromJson(v as Map<String, dynamic>),
        ),
        $type: $checkedConvert('type', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$TufRootSignedToJson(TufRootSigned instance) =>
    <String, dynamic>{
      'version': instance.version,
      'expires': instance.expires,
      'keys': instance.keys.map((k, e) => MapEntry(k, e.toJson())),
      'roles': instance.roles.toJson(),
      'type': instance.$type,
    };

TufTargetsSigned _$TufTargetsSignedFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TufTargetsSigned', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['sequence', 'expires', 'targets', 'type'],
      );
      final val = TufTargetsSigned(
        sequence: $checkedConvert('sequence', (v) => (v as num).toInt()),
        expires: $checkedConvert('expires', (v) => v as String),
        targets: $checkedConvert(
          'targets',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) =>
                MapEntry(k, TufTarget.fromJson(e as Map<String, dynamic>)),
          ),
        ),
        $type: $checkedConvert('type', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$TufTargetsSignedToJson(TufTargetsSigned instance) =>
    <String, dynamic>{
      'sequence': instance.sequence,
      'expires': instance.expires,
      'targets': instance.targets.map((k, e) => MapEntry(k, e.toJson())),
      'type': instance.$type,
    };

TufSnapshotSigned _$TufSnapshotSignedFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TufSnapshotSigned', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['sequence', 'expires', 'meta', 'type'],
      );
      final val = TufSnapshotSigned(
        sequence: $checkedConvert('sequence', (v) => (v as num).toInt()),
        expires: $checkedConvert('expires', (v) => v as String),
        meta: $checkedConvert(
          'meta',
          (v) => TufSnapshotMeta.fromJson(v as Map<String, dynamic>),
        ),
        $type: $checkedConvert('type', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$TufSnapshotSignedToJson(TufSnapshotSigned instance) =>
    <String, dynamic>{
      'sequence': instance.sequence,
      'expires': instance.expires,
      'meta': instance.meta.toJson(),
      'type': instance.$type,
    };

TufTimestampSigned _$TufTimestampSignedFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TufTimestampSigned', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['sequence', 'expires', 'meta', 'type'],
      );
      final val = TufTimestampSigned(
        sequence: $checkedConvert('sequence', (v) => (v as num).toInt()),
        expires: $checkedConvert('expires', (v) => v as String),
        meta: $checkedConvert(
          'meta',
          (v) => TufTimestampMeta.fromJson(v as Map<String, dynamic>),
        ),
        $type: $checkedConvert('type', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$TufTimestampSignedToJson(TufTimestampSigned instance) =>
    <String, dynamic>{
      'sequence': instance.sequence,
      'expires': instance.expires,
      'meta': instance.meta.toJson(),
      'type': instance.$type,
    };
