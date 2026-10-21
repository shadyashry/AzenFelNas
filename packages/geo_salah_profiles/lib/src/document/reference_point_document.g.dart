// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_point_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReferencePointDocument _$ReferencePointDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ReferencePointDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['area', 'lat', 'lon']);
  final val = _ReferencePointDocument(
    area: $checkedConvert('area', (v) => v as String),
    lat: $checkedConvert('lat', (v) => (v as num).toDouble()),
    lon: $checkedConvert('lon', (v) => (v as num).toDouble()),
  );
  return val;
});

Map<String, dynamic> _$ReferencePointDocumentToJson(
  _ReferencePointDocument instance,
) => <String, dynamic>{
  'area': instance.area,
  'lat': instance.lat,
  'lon': instance.lon,
};
