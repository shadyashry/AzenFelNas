// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approvals_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApprovalsDocument _$ApprovalsDocumentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ApprovalsDocument', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['religious', 'accuracy']);
      final val = _ApprovalsDocument(
        religious: $checkedConvert(
          'religious',
          (v) => v == null
              ? null
              : ReligiousApprovalDocument.fromJson(v as Map<String, dynamic>),
        ),
        accuracy: $checkedConvert(
          'accuracy',
          (v) => v == null
              ? null
              : AccuracyApprovalDocument.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApprovalsDocumentToJson(_ApprovalsDocument instance) =>
    <String, dynamic>{
      'religious': instance.religious?.toJson(),
      'accuracy': instance.accuracy?.toJson(),
    };
