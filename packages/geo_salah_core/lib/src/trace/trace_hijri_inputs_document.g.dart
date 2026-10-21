// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trace_hijri_inputs_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TraceHijriInputsDocument _$TraceHijriInputsDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_TraceHijriInputsDocument', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const ['dateAtDawn', 'dateAtNight', 'confidence'],
  );
  final val = _TraceHijriInputsDocument(
    dateAtDawn: $checkedConvert(
      'dateAtDawn',
      (v) => HijriDateDocument.fromJson(v as Map<String, dynamic>),
    ),
    dateAtNight: $checkedConvert(
      'dateAtNight',
      (v) => HijriDateDocument.fromJson(v as Map<String, dynamic>),
    ),
    confidence: $checkedConvert(
      'confidence',
      (v) => $enumDecode(_$HijriConfidenceCodeEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$TraceHijriInputsDocumentToJson(
  _TraceHijriInputsDocument instance,
) => <String, dynamic>{
  'dateAtDawn': instance.dateAtDawn.toJson(),
  'dateAtNight': instance.dateAtNight.toJson(),
  'confidence': _$HijriConfidenceCodeEnumMap[instance.confidence]!,
};

const _$HijriConfidenceCodeEnumMap = {
  HijriConfidenceCode.confirmed: 'CONFIRMED',
  HijriConfidenceCode.expected: 'EXPECTED',
  HijriConfidenceCode.userOverride: 'USER_OVERRIDE',
};
