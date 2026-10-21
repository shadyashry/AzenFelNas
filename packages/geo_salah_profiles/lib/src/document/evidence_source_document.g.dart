// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evidence_source_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EvidenceSourceDocument _$EvidenceSourceDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_EvidenceSourceDocument', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const ['title', 'url', 'retrievedOn', 'sha256'],
  );
  final val = _EvidenceSourceDocument(
    title: $checkedConvert('title', (v) => v as String),
    url: $checkedConvert('url', (v) => v as String),
    retrievedOn: $checkedConvert('retrievedOn', (v) => v as String),
    sha256: $checkedConvert('sha256', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$EvidenceSourceDocumentToJson(
  _EvidenceSourceDocument instance,
) => <String, dynamic>{
  'title': instance.title,
  'url': instance.url,
  'retrievedOn': instance.retrievedOn,
  'sha256': instance.sha256,
};
