// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bench_failure_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BenchFailureDocument _$BenchFailureDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_BenchFailureDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['schemaVersion', 'failure']);
  final val = _BenchFailureDocument(
    schemaVersion: $checkedConvert('schemaVersion', (v) => (v as num).toInt()),
    failure: $checkedConvert(
      'failure',
      (v) => BenchFailureDetailDocument.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$BenchFailureDocumentToJson(
  _BenchFailureDocument instance,
) => <String, dynamic>{
  'schemaVersion': instance.schemaVersion,
  'failure': instance.failure.toJson(),
};
