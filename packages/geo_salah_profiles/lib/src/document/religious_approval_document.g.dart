// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'religious_approval_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReligiousApprovalDocument _$ReligiousApprovalDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ReligiousApprovalDocument', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const ['reviewer', 'qualification', 'date', 'scope'],
  );
  final val = _ReligiousApprovalDocument(
    reviewer: $checkedConvert('reviewer', (v) => v as String),
    qualification: $checkedConvert('qualification', (v) => v as String),
    date: $checkedConvert('date', (v) => v as String),
    scope: $checkedConvert(
      'scope',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ReligiousApprovalDocumentToJson(
  _ReligiousApprovalDocument instance,
) => <String, dynamic>{
  'reviewer': instance.reviewer,
  'qualification': instance.qualification,
  'date': instance.date,
  'scope': instance.scope,
};
