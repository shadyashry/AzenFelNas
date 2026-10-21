// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuf_signature.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TufSignature _$TufSignatureFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TufSignature', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['keyId', 'sig']);
      final val = _TufSignature(
        keyId: $checkedConvert('keyId', (v) => v as String),
        sig: $checkedConvert('sig', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$TufSignatureToJson(_TufSignature instance) =>
    <String, dynamic>{'keyId': instance.keyId, 'sig': instance.sig};
