// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_health.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnapshotHealth _$SnapshotHealthFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SnapshotHealth', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['state', 'reasonsCount']);
      final val = _SnapshotHealth(
        state: $checkedConvert(
          'state',
          (v) => $enumDecode(_$HealthStateCodeEnumMap, v),
        ),
        reasonsCount: $checkedConvert(
          'reasonsCount',
          (v) => (v as num).toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SnapshotHealthToJson(_SnapshotHealth instance) =>
    <String, dynamic>{
      'state': _$HealthStateCodeEnumMap[instance.state]!,
      'reasonsCount': instance.reasonsCount,
    };

const _$HealthStateCodeEnumMap = {
  HealthStateCode.ready: 'READY',
  HealthStateCode.limited: 'LIMITED',
  HealthStateCode.notReady: 'NOT_READY',
  HealthStateCode.unknown: 'UNKNOWN',
};
