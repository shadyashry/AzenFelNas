// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athan_sound.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AthanSound _$AthanSoundFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AthanSound', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'soundId',
          'file',
          'durationMs',
          'licenceRef',
          'sha256',
          'fajrVariantOf',
        ],
      );
      final val = _AthanSound(
        soundId: $checkedConvert('soundId', (v) => v as String),
        file: $checkedConvert('file', (v) => v as String),
        durationMs: $checkedConvert('durationMs', (v) => (v as num).toInt()),
        licenceRef: $checkedConvert('licenceRef', (v) => v as String),
        sha256: $checkedConvert('sha256', (v) => v as String),
        fajrVariantOf: $checkedConvert('fajrVariantOf', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$AthanSoundToJson(_AthanSound instance) =>
    <String, dynamic>{
      'soundId': instance.soundId,
      'file': instance.file,
      'durationMs': instance.durationMs,
      'licenceRef': instance.licenceRef,
      'sha256': instance.sha256,
      'fajrVariantOf': ?instance.fajrVariantOf,
    };
