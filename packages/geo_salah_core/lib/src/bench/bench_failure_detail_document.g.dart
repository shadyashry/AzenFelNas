// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bench_failure_detail_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BenchFailureDetailDocument _$BenchFailureDetailDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_BenchFailureDetailDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['code', 'detail']);
  final val = _BenchFailureDetailDocument(
    code: $checkedConvert(
      'code',
      (v) => const FailureCodeConverter().fromJson(v as String),
    ),
    detail: $checkedConvert('detail', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$BenchFailureDetailDocumentToJson(
  _BenchFailureDetailDocument instance,
) => <String, dynamic>{
  'code': const FailureCodeConverter().toJson(instance.code),
  'detail': ?instance.detail,
};
