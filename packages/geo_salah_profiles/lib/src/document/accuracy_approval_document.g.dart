// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accuracy_approval_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccuracyApprovalDocument _$AccuracyApprovalDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_AccuracyApprovalDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['reviewer', 'date']);
  final val = _AccuracyApprovalDocument(
    reviewer: $checkedConvert('reviewer', (v) => v as String),
    date: $checkedConvert('date', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$AccuracyApprovalDocumentToJson(
  _AccuracyApprovalDocument instance,
) => <String, dynamic>{'reviewer': instance.reviewer, 'date': instance.date};
