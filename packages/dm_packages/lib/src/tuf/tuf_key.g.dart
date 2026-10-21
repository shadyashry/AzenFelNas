// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuf_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TufKey _$TufKeyFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TufKey', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['scheme', 'public']);
      final val = _TufKey(
        scheme: $checkedConvert(
          'scheme',
          (v) => $enumDecode(_$TufKeySchemeEnumMap, v),
        ),
        public: $checkedConvert('public', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$TufKeyToJson(_TufKey instance) => <String, dynamic>{
  'scheme': _$TufKeySchemeEnumMap[instance.scheme]!,
  'public': instance.public,
};

const _$TufKeySchemeEnumMap = {TufKeyScheme.ed25519: 'ed25519'};
