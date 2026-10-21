// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compatibility_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CompatibilityDocument _$CompatibilityDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_CompatibilityDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['minEngineSchema', 'minAppVersion']);
  final val = _CompatibilityDocument(
    minEngineSchema: $checkedConvert(
      'minEngineSchema',
      (v) => (v as num).toInt(),
    ),
    minAppVersion: $checkedConvert('minAppVersion', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$CompatibilityDocumentToJson(
  _CompatibilityDocument instance,
) => <String, dynamic>{
  'minEngineSchema': instance.minEngineSchema,
  'minAppVersion': instance.minAppVersion,
};
