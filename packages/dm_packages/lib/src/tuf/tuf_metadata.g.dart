// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuf_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TufMetadata _$TufMetadataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TufMetadata', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['signed', 'signatures']);
      final val = _TufMetadata(
        signed: $checkedConvert(
          'signed',
          (v) => TufSigned.fromJson(v as Map<String, dynamic>),
        ),
        signatures: $checkedConvert(
          'signatures',
          (v) => (v as List<dynamic>)
              .map((e) => TufSignature.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TufMetadataToJson(_TufMetadata instance) =>
    <String, dynamic>{
      'signed': instance.signed.toJson(),
      'signatures': instance.signatures.map((e) => e.toJson()).toList(),
    };
