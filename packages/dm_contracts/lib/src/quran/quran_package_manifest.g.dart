// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_package_manifest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuranPackageManifest _$QuranPackageManifestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_QuranPackageManifest', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'schemaVersion',
      'packageId',
      'version',
      'layoutId',
      'edition',
      'pageImage',
      'files',
    ],
  );
  final val = _QuranPackageManifest(
    schemaVersion: $checkedConvert('schemaVersion', (v) => (v as num).toInt()),
    packageId: $checkedConvert('packageId', (v) => v as String),
    version: $checkedConvert('version', (v) => v as String),
    layoutId: $checkedConvert('layoutId', (v) => v as String),
    edition: $checkedConvert(
      'edition',
      (v) => QuranEdition.fromJson(v as Map<String, dynamic>),
    ),
    pageImage: $checkedConvert(
      'pageImage',
      (v) => QuranPageImage.fromJson(v as Map<String, dynamic>),
    ),
    files: $checkedConvert(
      'files',
      (v) => (v as List<dynamic>)
          .map((e) => QuranPackageFile.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$QuranPackageManifestToJson(
  _QuranPackageManifest instance,
) => <String, dynamic>{
  'schemaVersion': instance.schemaVersion,
  'packageId': instance.packageId,
  'version': instance.version,
  'layoutId': instance.layoutId,
  'edition': instance.edition.toJson(),
  'pageImage': instance.pageImage.toJson(),
  'files': instance.files.map((e) => e.toJson()).toList(),
};
