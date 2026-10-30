// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_package_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuranPackageFile _$QuranPackageFileFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_QuranPackageFile', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['path', 'bytes', 'sha256']);
      final val = _QuranPackageFile(
        path: $checkedConvert('path', (v) => v as String),
        bytes: $checkedConvert('bytes', (v) => (v as num).toInt()),
        sha256: $checkedConvert('sha256', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$QuranPackageFileToJson(_QuranPackageFile instance) =>
    <String, dynamic>{
      'path': instance.path,
      'bytes': instance.bytes,
      'sha256': instance.sha256,
    };
