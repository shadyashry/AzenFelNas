// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_plan_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchedulePlanEntry _$SchedulePlanEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SchedulePlanEntry', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'id',
          'day',
          'kind',
          'fireAtUtcMs',
          'displayLocal',
          'title',
          'body',
          'soundId',
          'priority',
          'event',
        ],
      );
      final val = _SchedulePlanEntry(
        id: $checkedConvert('id', (v) => v as String),
        day: $checkedConvert('day', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$ScheduleEntryKindEnumMap, v),
        ),
        fireAtUtcMs: $checkedConvert('fireAtUtcMs', (v) => (v as num).toInt()),
        displayLocal: $checkedConvert('displayLocal', (v) => v as String),
        title: $checkedConvert(
          'title',
          (v) => LocalizedText.fromJson(v as Map<String, dynamic>),
        ),
        body: $checkedConvert(
          'body',
          (v) => LocalizedText.fromJson(v as Map<String, dynamic>),
        ),
        soundId: $checkedConvert('soundId', (v) => v as String),
        priority: $checkedConvert('priority', (v) => (v as num).toInt()),
        event: $checkedConvert(
          'event',
          (v) => $enumDecodeNullable(_$PrayerEventCodeEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SchedulePlanEntryToJson(_SchedulePlanEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day': instance.day,
      'kind': _$ScheduleEntryKindEnumMap[instance.kind]!,
      'fireAtUtcMs': instance.fireAtUtcMs,
      'displayLocal': instance.displayLocal,
      'title': instance.title.toJson(),
      'body': instance.body.toJson(),
      'soundId': instance.soundId,
      'priority': instance.priority,
      'event': ?_$PrayerEventCodeEnumMap[instance.event],
    };

const _$ScheduleEntryKindEnumMap = {
  ScheduleEntryKind.athan: 'ATHAN',
  ScheduleEntryKind.preReminder: 'PRE_REMINDER',
  ScheduleEntryKind.imsak: 'IMSAK',
  ScheduleEntryKind.horizonWarning: 'HORIZON_WARNING',
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
