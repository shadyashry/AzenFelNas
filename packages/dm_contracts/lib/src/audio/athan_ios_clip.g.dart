// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athan_ios_clip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AthanIosClip _$AthanIosClipFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AthanIosClip', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['file', 'durationMs', 'sha256']);
      final val = _AthanIosClip(
        file: $checkedConvert('file', (v) => v as String),
        durationMs: $checkedConvert('durationMs', (v) => (v as num).toInt()),
        sha256: $checkedConvert('sha256', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AthanIosClipToJson(_AthanIosClip instance) =>
    <String, dynamic>{
      'file': instance.file,
      'durationMs': instance.durationMs,
      'sha256': instance.sha256,
    };
