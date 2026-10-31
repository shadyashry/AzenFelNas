// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athan_sound_name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AthanSoundName _$AthanSoundNameFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AthanSoundName', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['en', 'ar']);
      final val = _AthanSoundName(
        en: $checkedConvert('en', (v) => v as String),
        ar: $checkedConvert('ar', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AthanSoundNameToJson(_AthanSoundName instance) =>
    <String, dynamic>{'en': instance.en, 'ar': instance.ar};
