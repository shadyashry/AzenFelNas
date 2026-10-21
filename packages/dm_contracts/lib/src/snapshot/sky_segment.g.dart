// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sky_segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SkySegment _$SkySegmentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SkySegment', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['fromUtcMs', 'phase']);
      final val = _SkySegment(
        fromUtcMs: $checkedConvert('fromUtcMs', (v) => (v as num).toInt()),
        phase: $checkedConvert(
          'phase',
          (v) => $enumDecode(_$SkyPhaseCodeEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SkySegmentToJson(_SkySegment instance) =>
    <String, dynamic>{
      'fromUtcMs': instance.fromUtcMs,
      'phase': _$SkyPhaseCodeEnumMap[instance.phase]!,
    };

const _$SkyPhaseCodeEnumMap = {
  SkyPhaseCode.night: 'night',
  SkyPhaseCode.astronomicalDawn: 'astronomicalDawn',
  SkyPhaseCode.nauticalDawn: 'nauticalDawn',
  SkyPhaseCode.civilDawn: 'civilDawn',
  SkyPhaseCode.goldenMorning: 'goldenMorning',
  SkyPhaseCode.day: 'day',
  SkyPhaseCode.goldenEvening: 'goldenEvening',
  SkyPhaseCode.civilDusk: 'civilDusk',
  SkyPhaseCode.nauticalDusk: 'nauticalDusk',
  SkyPhaseCode.astronomicalDusk: 'astronomicalDusk',
};
