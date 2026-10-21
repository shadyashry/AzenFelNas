// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bench_observer_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BenchObserverDocument _$BenchObserverDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_BenchObserverDocument', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'latitudeDeg',
      'longitudeDeg',
      'zoneId',
      'source',
      'horizontalAccuracyM',
      'elevation',
    ],
  );
  final val = _BenchObserverDocument(
    latitudeDeg: $checkedConvert('latitudeDeg', (v) => (v as num).toDouble()),
    longitudeDeg: $checkedConvert('longitudeDeg', (v) => (v as num).toDouble()),
    zoneId: $checkedConvert('zoneId', (v) => v as String),
    source: $checkedConvert(
      'source',
      (v) => $enumDecode(_$ObserverSourceCodeEnumMap, v),
    ),
    horizontalAccuracyM: $checkedConvert(
      'horizontalAccuracyM',
      (v) => (v as num?)?.toDouble(),
    ),
    elevation: $checkedConvert(
      'elevation',
      (v) => v == null
          ? null
          : ElevationSampleDocument.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$BenchObserverDocumentToJson(
  _BenchObserverDocument instance,
) => <String, dynamic>{
  'latitudeDeg': instance.latitudeDeg,
  'longitudeDeg': instance.longitudeDeg,
  'zoneId': instance.zoneId,
  'source': _$ObserverSourceCodeEnumMap[instance.source]!,
  'horizontalAccuracyM': ?instance.horizontalAccuracyM,
  'elevation': ?instance.elevation?.toJson(),
};

const _$ObserverSourceCodeEnumMap = {
  ObserverSourceCode.device: 'DEVICE',
  ObserverSourceCode.pinned: 'PINNED',
  ObserverSourceCode.manual: 'MANUAL',
  ObserverSourceCode.mosque: 'MOSQUE',
  ObserverSourceCode.benchmark: 'BENCHMARK',
};
