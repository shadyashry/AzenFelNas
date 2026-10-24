// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DiagnosticPackage _$DiagnosticPackageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_DiagnosticPackage', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['type', 'version', 'sequence']);
      final val = _DiagnosticPackage(
        type: $checkedConvert('type', (v) => v as String),
        version: $checkedConvert('version', (v) => v as String),
        sequence: $checkedConvert('sequence', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$DiagnosticPackageToJson(_DiagnosticPackage instance) =>
    <String, dynamic>{
      'type': instance.type,
      'version': instance.version,
      'sequence': instance.sequence,
    };
