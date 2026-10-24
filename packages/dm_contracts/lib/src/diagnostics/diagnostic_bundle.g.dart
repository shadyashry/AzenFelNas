// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_bundle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DiagnosticBundle _$DiagnosticBundleFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_DiagnosticBundle', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const ['schemaVersion', 'createdUtcMs', 'files'],
  );
  final val = _DiagnosticBundle(
    schemaVersion: $checkedConvert('schemaVersion', (v) => (v as num).toInt()),
    createdUtcMs: $checkedConvert('createdUtcMs', (v) => (v as num).toInt()),
    files: $checkedConvert(
      'files',
      (v) => DiagnosticFiles.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DiagnosticBundleToJson(_DiagnosticBundle instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'createdUtcMs': instance.createdUtcMs,
      'files': instance.files.toJson(),
    };
