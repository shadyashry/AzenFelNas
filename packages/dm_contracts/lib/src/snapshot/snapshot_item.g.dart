// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnapshotItem _$SnapshotItemFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SnapshotItem', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'day',
          'event',
          'displayedUtcMs',
          'displayLocal',
          'confidence',
          'dayOffset',
        ],
      );
      final val = _SnapshotItem(
        day: $checkedConvert('day', (v) => v as String),
        event: $checkedConvert(
          'event',
          (v) => $enumDecode(_$PrayerEventCodeEnumMap, v),
        ),
        displayedUtcMs: $checkedConvert(
          'displayedUtcMs',
          (v) => (v as num).toInt(),
        ),
        displayLocal: $checkedConvert('displayLocal', (v) => v as String),
        confidence: $checkedConvert(
          'confidence',
          (v) => SnapshotConfidence.fromJson(v as Map<String, dynamic>),
        ),
        dayOffset: $checkedConvert('dayOffset', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$SnapshotItemToJson(_SnapshotItem instance) =>
    <String, dynamic>{
      'day': instance.day,
      'event': _$PrayerEventCodeEnumMap[instance.event]!,
      'displayedUtcMs': instance.displayedUtcMs,
      'displayLocal': instance.displayLocal,
      'confidence': instance.confidence.toJson(),
      'dayOffset': instance.dayOffset,
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
