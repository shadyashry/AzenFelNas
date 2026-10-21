// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuf_meta_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TufMetaRef _$TufMetaRefFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TufMetaRef', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['version', 'sha256']);
      final val = _TufMetaRef(
        version: $checkedConvert('version', (v) => (v as num).toInt()),
        sha256: $checkedConvert('sha256', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$TufMetaRefToJson(_TufMetaRef instance) =>
    <String, dynamic>{'version': instance.version, 'sha256': instance.sha256};
