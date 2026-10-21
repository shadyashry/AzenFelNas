// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trace_time_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TraceTimeDocument _$TraceTimeDocumentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TraceTimeDocument', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'event',
          'origin',
          'confidence',
          'flags',
          'adjustmentTrace',
          'rawUtcMs',
          'displayedUtcMs',
          'dayOffset',
        ],
      );
      final val = _TraceTimeDocument(
        event: $checkedConvert(
          'event',
          (v) => $enumDecode(_$PrayerEventCodeEnumMap, v),
        ),
        origin: $checkedConvert(
          'origin',
          (v) => EventOriginDocument.fromJson(v as Map<String, dynamic>),
        ),
        confidence: $checkedConvert(
          'confidence',
          (v) => ConfidenceLabelDocument.fromJson(v as Map<String, dynamic>),
        ),
        flags: $checkedConvert(
          'flags',
          (v) => (v as List<dynamic>)
              .map((e) => $enumDecode(_$ResultFlagCodeEnumMap, e))
              .toList(),
        ),
        adjustmentTrace: $checkedConvert(
          'adjustmentTrace',
          (v) => (v as List<dynamic>)
              .map(
                (e) =>
                    AdjustmentStepDocument.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
        rawUtcMs: $checkedConvert('rawUtcMs', (v) => (v as num?)?.toInt()),
        displayedUtcMs: $checkedConvert(
          'displayedUtcMs',
          (v) => (v as num?)?.toInt(),
        ),
        dayOffset: $checkedConvert('dayOffset', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$TraceTimeDocumentToJson(
  _TraceTimeDocument instance,
) => <String, dynamic>{
  'event': _$PrayerEventCodeEnumMap[instance.event]!,
  'origin': instance.origin.toJson(),
  'confidence': instance.confidence.toJson(),
  'flags': instance.flags.map((e) => _$ResultFlagCodeEnumMap[e]!).toList(),
  'adjustmentTrace': instance.adjustmentTrace.map((e) => e.toJson()).toList(),
  'rawUtcMs': ?instance.rawUtcMs,
  'displayedUtcMs': ?instance.displayedUtcMs,
  'dayOffset': ?instance.dayOffset,
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

const _$ResultFlagCodeEnumMap = {
  ResultFlagCode.nearRoundingBoundary: 'NEAR_ROUNDING_BOUNDARY',
  ResultFlagCode.highLatitudeFallback: 'HIGH_LATITUDE_FALLBACK',
  ResultFlagCode.lowLocationAccuracy: 'LOW_LOCATION_ACCURACY',
  ResultFlagCode.dstTransitionDay: 'DST_TRANSITION_DAY',
  ResultFlagCode.staleTzdb: 'STALE_TZDB',
  ResultFlagCode.hijriExpected: 'HIJRI_EXPECTED',
  ResultFlagCode.referenceModeAuthorityPoint: 'REFERENCE_MODE_AUTHORITY_POINT',
  ResultFlagCode.manualCoordinateResolution: 'MANUAL_COORDINATE_RESOLUTION',
  ResultFlagCode.zoneBoundaryProximity: 'ZONE_BOUNDARY_PROXIMITY',
  ResultFlagCode.noLocalProfile: 'NO_LOCAL_PROFILE',
};
