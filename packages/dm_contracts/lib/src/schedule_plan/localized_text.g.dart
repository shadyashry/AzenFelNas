// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localized_text.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocalizedText _$LocalizedTextFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_LocalizedText', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['ar', 'en']);
      final val = _LocalizedText(
        ar: $checkedConvert('ar', (v) => v as String),
        en: $checkedConvert('en', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$LocalizedTextToJson(_LocalizedText instance) =>
    <String, dynamic>{'ar': instance.ar, 'en': instance.en};
