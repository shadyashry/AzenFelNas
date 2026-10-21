// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trace_inputs_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TraceInputsDocument _$TraceInputsDocumentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TraceInputsDocument', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'lat',
          'lon',
          'zoneId',
          'day',
          'profileId',
          'profileVersion',
          'hijri',
        ],
      );
      final val = _TraceInputsDocument(
        lat: $checkedConvert('lat', (v) => (v as num).toDouble()),
        lon: $checkedConvert('lon', (v) => (v as num).toDouble()),
        zoneId: $checkedConvert('zoneId', (v) => v as String),
        day: $checkedConvert('day', (v) => v as String),
        profileId: $checkedConvert('profileId', (v) => v as String),
        profileVersion: $checkedConvert('profileVersion', (v) => v as String),
        hijri: $checkedConvert(
          'hijri',
          (v) => TraceHijriInputsDocument.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TraceInputsDocumentToJson(
  _TraceInputsDocument instance,
) => <String, dynamic>{
  'lat': instance.lat,
  'lon': instance.lon,
  'zoneId': instance.zoneId,
  'day': instance.day,
  'profileId': instance.profileId,
  'profileVersion': instance.profileVersion,
  'hijri': instance.hijri.toJson(),
};
