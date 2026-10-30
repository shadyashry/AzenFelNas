// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_page_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuranPageImage _$QuranPageImageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_QuranPageImage', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['format', 'width', 'height', 'pathPattern'],
      );
      final val = _QuranPageImage(
        format: $checkedConvert('format', (v) => v as String),
        width: $checkedConvert('width', (v) => (v as num).toInt()),
        height: $checkedConvert('height', (v) => (v as num).toInt()),
        pathPattern: $checkedConvert('pathPattern', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$QuranPageImageToJson(_QuranPageImage instance) =>
    <String, dynamic>{
      'format': instance.format,
      'width': instance.width,
      'height': instance.height,
      'pathPattern': instance.pathPattern,
    };
