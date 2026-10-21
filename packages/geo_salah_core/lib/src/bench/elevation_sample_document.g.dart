// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'elevation_sample_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ElevationSampleDocument _$ElevationSampleDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ElevationSampleDocument', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'valueM',
      'datum',
      'source',
      'observedUtcMs',
      'verticalAccuracyM',
      'datasetVersion',
    ],
  );
  final val = _ElevationSampleDocument(
    valueM: $checkedConvert('valueM', (v) => (v as num).toDouble()),
    datum: $checkedConvert(
      'datum',
      (v) => $enumDecode(_$ElevationDatumCodeEnumMap, v),
    ),
    source: $checkedConvert(
      'source',
      (v) => $enumDecode(_$ElevationSourceCodeEnumMap, v),
    ),
    observedUtcMs: $checkedConvert('observedUtcMs', (v) => (v as num).toInt()),
    verticalAccuracyM: $checkedConvert(
      'verticalAccuracyM',
      (v) => (v as num?)?.toDouble(),
    ),
    datasetVersion: $checkedConvert('datasetVersion', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ElevationSampleDocumentToJson(
  _ElevationSampleDocument instance,
) => <String, dynamic>{
  'valueM': instance.valueM,
  'datum': _$ElevationDatumCodeEnumMap[instance.datum]!,
  'source': _$ElevationSourceCodeEnumMap[instance.source]!,
  'observedUtcMs': instance.observedUtcMs,
  'verticalAccuracyM': ?instance.verticalAccuracyM,
  'datasetVersion': ?instance.datasetVersion,
};

const _$ElevationDatumCodeEnumMap = {
  ElevationDatumCode.wgs84Ellipsoid: 'WGS84_ELLIPSOID',
  ElevationDatumCode.egm2008: 'EGM2008',
  ElevationDatumCode.unknown: 'UNKNOWN',
};

const _$ElevationSourceCodeEnumMap = {
  ElevationSourceCode.gnss: 'GNSS',
  ElevationSourceCode.manual: 'MANUAL',
};
