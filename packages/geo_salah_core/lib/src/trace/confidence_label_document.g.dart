// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confidence_label_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculatedLabelDocument _$CalculatedLabelDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CalculatedLabelDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['kind']);
  final val = CalculatedLabelDocument(
    $type: $checkedConvert('kind', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$CalculatedLabelDocumentToJson(
  CalculatedLabelDocument instance,
) => <String, dynamic>{'kind': instance.$type};

AuthorityAlignedLabelDocument _$AuthorityAlignedLabelDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AuthorityAlignedLabelDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['benchmarkReportId', 'kind']);
  final val = AuthorityAlignedLabelDocument(
    benchmarkReportId: $checkedConvert('benchmarkReportId', (v) => v as String),
    $type: $checkedConvert('kind', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$AuthorityAlignedLabelDocumentToJson(
  AuthorityAlignedLabelDocument instance,
) => <String, dynamic>{
  'benchmarkReportId': instance.benchmarkReportId,
  'kind': instance.$type,
};

VerifiedLabelDocument _$VerifiedLabelDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('VerifiedLabelDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['sourceRef', 'freshUntilUtcMs', 'kind']);
  final val = VerifiedLabelDocument(
    sourceRef: $checkedConvert('sourceRef', (v) => v as String),
    freshUntilUtcMs: $checkedConvert(
      'freshUntilUtcMs',
      (v) => (v as num).toInt(),
    ),
    $type: $checkedConvert('kind', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$VerifiedLabelDocumentToJson(
  VerifiedLabelDocument instance,
) => <String, dynamic>{
  'sourceRef': instance.sourceRef,
  'freshUntilUtcMs': instance.freshUntilUtcMs,
  'kind': instance.$type,
};

EstimatedLabelDocument _$EstimatedLabelDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EstimatedLabelDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['rangeMinutes', 'kind']);
  final val = EstimatedLabelDocument(
    rangeMinutes: $checkedConvert('rangeMinutes', (v) => (v as num).toInt()),
    $type: $checkedConvert('kind', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$EstimatedLabelDocumentToJson(
  EstimatedLabelDocument instance,
) => <String, dynamic>{
  'rangeMinutes': instance.rangeMinutes,
  'kind': instance.$type,
};

ObservedLabelDocument _$ObservedLabelDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ObservedLabelDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['count', 'lastSeenUtcMs', 'kind']);
  final val = ObservedLabelDocument(
    count: $checkedConvert('count', (v) => (v as num).toInt()),
    lastSeenUtcMs: $checkedConvert('lastSeenUtcMs', (v) => (v as num).toInt()),
    $type: $checkedConvert('kind', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$ObservedLabelDocumentToJson(
  ObservedLabelDocument instance,
) => <String, dynamic>{
  'count': instance.count,
  'lastSeenUtcMs': instance.lastSeenUtcMs,
  'kind': instance.$type,
};

UnknownLabelDocument _$UnknownLabelDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UnknownLabelDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['reasonCode', 'kind']);
  final val = UnknownLabelDocument(
    reasonCode: $checkedConvert('reasonCode', (v) => v as String),
    $type: $checkedConvert('kind', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$UnknownLabelDocumentToJson(
  UnknownLabelDocument instance,
) => <String, dynamic>{
  'reasonCode': instance.reasonCode,
  'kind': instance.$type,
};
