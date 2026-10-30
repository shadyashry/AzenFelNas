// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuranSource _$QuranSourceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_QuranSource', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['role', 'url', 'sha256', 'version', 'license'],
      );
      final val = _QuranSource(
        role: $checkedConvert(
          'role',
          (v) => $enumDecode(_$QuranSourceRoleEnumMap, v),
        ),
        url: $checkedConvert('url', (v) => v as String),
        sha256: $checkedConvert('sha256', (v) => v as String),
        version: $checkedConvert('version', (v) => v as String),
        license: $checkedConvert('license', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$QuranSourceToJson(_QuranSource instance) =>
    <String, dynamic>{
      'role': _$QuranSourceRoleEnumMap[instance.role]!,
      'url': instance.url,
      'sha256': instance.sha256,
      'version': instance.version,
      'license': instance.license,
    };

const _$QuranSourceRoleEnumMap = {
  QuranSourceRole.pages: 'pages',
  QuranSourceRole.text: 'text',
  QuranSourceRole.juz: 'juz',
};
