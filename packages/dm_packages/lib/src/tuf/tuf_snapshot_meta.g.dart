// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuf_snapshot_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TufSnapshotMeta _$TufSnapshotMetaFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TufSnapshotMeta', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['targets.json']);
      final val = _TufSnapshotMeta(
        targetsJson: $checkedConvert(
          'targets.json',
          (v) => TufMetaRef.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'targetsJson': 'targets.json'});

Map<String, dynamic> _$TufSnapshotMetaToJson(_TufSnapshotMeta instance) =>
    <String, dynamic>{'targets.json': instance.targetsJson.toJson()};
