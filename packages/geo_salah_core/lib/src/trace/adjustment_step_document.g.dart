// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adjustment_step_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdjustmentStepDocument _$AdjustmentStepDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_AdjustmentStepDocument', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const ['event', 'kind', 'deltaMs', 'reason', 'evidenceId'],
  );
  final val = _AdjustmentStepDocument(
    event: $checkedConvert(
      'event',
      (v) => $enumDecode(_$PrayerEventCodeEnumMap, v),
    ),
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(_$AdjustmentKindCodeEnumMap, v),
    ),
    deltaMs: $checkedConvert('deltaMs', (v) => (v as num).toInt()),
    reason: $checkedConvert('reason', (v) => v as String),
    evidenceId: $checkedConvert('evidenceId', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AdjustmentStepDocumentToJson(
  _AdjustmentStepDocument instance,
) => <String, dynamic>{
  'event': _$PrayerEventCodeEnumMap[instance.event]!,
  'kind': _$AdjustmentKindCodeEnumMap[instance.kind]!,
  'deltaMs': instance.deltaMs,
  'reason': instance.reason,
  'evidenceId': ?instance.evidenceId,
};

const _$PrayerEventCodeEnumMap = {
  PrayerEventCode.imsak: 'IMSAK',
  PrayerEventCode.fajr: 'FAJR',
  PrayerEventCode.sunrise: 'SUNRISE',
  PrayerEventCode.dhuhr: 'DHUHR',
  PrayerEventCode.asr: 'ASR',
  PrayerEventCode.maghrib: 'MAGHRIB',
  PrayerEventCode.isha: 'ISHA',
};

const _$AdjustmentKindCodeEnumMap = {
  AdjustmentKindCode.perEventOffset: 'PER_EVENT_OFFSET',
  AdjustmentKindCode.ramadanRuleReplacement: 'RAMADAN_RULE_REPLACEMENT',
  AdjustmentKindCode.highLatitudeFallback: 'HIGH_LATITUDE_FALLBACK',
  AdjustmentKindCode.rounding: 'ROUNDING',
};
