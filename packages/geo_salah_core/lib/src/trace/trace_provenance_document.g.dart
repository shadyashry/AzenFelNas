// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trace_provenance_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TraceProvenanceDocument _$TraceProvenanceDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_TraceProvenanceDocument', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'engineVersion',
      'deltaTModel',
      'profileId',
      'profileVersion',
      'tzdbVersion',
      'inputsHash',
      'hijriConfidence',
    ],
  );
  final val = _TraceProvenanceDocument(
    engineVersion: $checkedConvert('engineVersion', (v) => v as String),
    deltaTModel: $checkedConvert('deltaTModel', (v) => v as String),
    profileId: $checkedConvert('profileId', (v) => v as String),
    profileVersion: $checkedConvert('profileVersion', (v) => v as String),
    tzdbVersion: $checkedConvert('tzdbVersion', (v) => v as String),
    inputsHash: $checkedConvert('inputsHash', (v) => v as String),
    hijriConfidence: $checkedConvert(
      'hijriConfidence',
      (v) => $enumDecode(_$HijriConfidenceCodeEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$TraceProvenanceDocumentToJson(
  _TraceProvenanceDocument instance,
) => <String, dynamic>{
  'engineVersion': instance.engineVersion,
  'deltaTModel': instance.deltaTModel,
  'profileId': instance.profileId,
  'profileVersion': instance.profileVersion,
  'tzdbVersion': instance.tzdbVersion,
  'inputsHash': instance.inputsHash,
  'hijriConfidence': _$HijriConfidenceCodeEnumMap[instance.hijriConfidence]!,
};

const _$HijriConfidenceCodeEnumMap = {
  HijriConfidenceCode.confirmed: 'CONFIRMED',
  HijriConfidenceCode.expected: 'EXPECTED',
  HijriConfidenceCode.userOverride: 'USER_OVERRIDE',
};
