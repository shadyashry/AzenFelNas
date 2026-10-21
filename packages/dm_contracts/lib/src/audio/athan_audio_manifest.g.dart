// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athan_audio_manifest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AthanAudioManifest _$AthanAudioManifestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AthanAudioManifest', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['sounds']);
      final val = _AthanAudioManifest(
        sounds: $checkedConvert(
          'sounds',
          (v) => (v as List<dynamic>)
              .map((e) => AthanSound.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AthanAudioManifestToJson(_AthanAudioManifest instance) =>
    <String, dynamic>{
      'sounds': instance.sounds.map((e) => e.toJson()).toList(),
    };
