// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_confidence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnapshotConfidence _$SnapshotConfidenceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SnapshotConfidence', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['kind', 'detail']);
      final val = _SnapshotConfidence(
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$ConfidenceKindCodeEnumMap, v),
        ),
        detail: $checkedConvert('detail', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$SnapshotConfidenceToJson(_SnapshotConfidence instance) =>
    <String, dynamic>{
      'kind': _$ConfidenceKindCodeEnumMap[instance.kind]!,
      'detail': ?instance.detail,
    };

const _$ConfidenceKindCodeEnumMap = {
  ConfidenceKindCode.calculated: 'CALCULATED',
  ConfidenceKindCode.authorityAligned: 'AUTHORITY_ALIGNED',
  ConfidenceKindCode.verified: 'VERIFIED',
  ConfidenceKindCode.estimated: 'ESTIMATED',
  ConfidenceKindCode.observed: 'OBSERVED',
  ConfidenceKindCode.unknown: 'UNKNOWN',
};
