// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gazetteer_alt_names.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GazetteerAltNames _$GazetteerAltNamesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_GazetteerAltNames', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['ar', 'en']);
      final val = _GazetteerAltNames(
        ar: $checkedConvert(
          'ar',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        en: $checkedConvert(
          'en',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$GazetteerAltNamesToJson(_GazetteerAltNames instance) =>
    <String, dynamic>{'ar': instance.ar, 'en': instance.en};
