// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bench_request_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BenchRequestDocument _$BenchRequestDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_BenchRequestDocument', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'schemaVersion',
      'observer',
      'profileId',
      'day',
      'hijri',
    ],
  );
  final val = _BenchRequestDocument(
    schemaVersion: $checkedConvert('schemaVersion', (v) => (v as num).toInt()),
    observer: $checkedConvert(
      'observer',
      (v) => BenchObserverDocument.fromJson(v as Map<String, dynamic>),
    ),
    profileId: $checkedConvert('profileId', (v) => v as String),
    day: $checkedConvert('day', (v) => v as String),
    hijri: $checkedConvert(
      'hijri',
      (v) => TraceHijriInputsDocument.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$BenchRequestDocumentToJson(
  _BenchRequestDocument instance,
) => <String, dynamic>{
  'schemaVersion': instance.schemaVersion,
  'observer': instance.observer.toJson(),
  'profileId': instance.profileId,
  'day': instance.day,
  'hijri': instance.hijri.toJson(),
};
