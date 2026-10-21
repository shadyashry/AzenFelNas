// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authority_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthorityDocument _$AuthorityDocumentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AuthorityDocument', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['name', 'type']);
      final val = _AuthorityDocument(
        name: $checkedConvert('name', (v) => v as String),
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$AuthorityTypeCodeEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AuthorityDocumentToJson(_AuthorityDocument instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$AuthorityTypeCodeEnumMap[instance.type]!,
    };

const _$AuthorityTypeCodeEnumMap = {
  AuthorityTypeCode.government: 'GOVERNMENT',
  AuthorityTypeCode.recognizedBody: 'RECOGNIZED_BODY',
  AuthorityTypeCode.communityConvention: 'COMMUNITY_CONVENTION',
  AuthorityTypeCode.engineDefault: 'ENGINE_DEFAULT',
};
