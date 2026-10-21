// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuf_timestamp_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TufTimestampMeta _$TufTimestampMetaFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TufTimestampMeta', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['snapshot.json']);
      final val = _TufTimestampMeta(
        snapshotJson: $checkedConvert(
          'snapshot.json',
          (v) => TufMetaRef.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'snapshotJson': 'snapshot.json'});

Map<String, dynamic> _$TufTimestampMetaToJson(_TufTimestampMeta instance) =>
    <String, dynamic>{'snapshot.json': instance.snapshotJson.toJson()};
