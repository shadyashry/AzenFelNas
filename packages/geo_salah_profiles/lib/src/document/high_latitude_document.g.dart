// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'high_latitude_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HighLatitudeDocument _$HighLatitudeDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_HighLatitudeDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['chain']);
  final val = _HighLatitudeDocument(
    chain: $checkedConvert(
      'chain',
      (v) => (v as List<dynamic>)
          .map(const HighLatitudeMethodDocumentConverter().fromJson)
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$HighLatitudeDocumentToJson(
  _HighLatitudeDocument instance,
) => <String, dynamic>{
  'chain': instance.chain
      .map(const HighLatitudeMethodDocumentConverter().toJson)
      .toList(),
};
