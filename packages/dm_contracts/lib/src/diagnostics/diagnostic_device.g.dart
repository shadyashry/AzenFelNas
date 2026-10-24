// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DiagnosticDevice _$DiagnosticDeviceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_DiagnosticDevice', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['model', 'os', 'appVersion']);
      final val = _DiagnosticDevice(
        model: $checkedConvert('model', (v) => v as String?),
        os: $checkedConvert('os', (v) => $enumDecode(_$DiagnosticOsEnumMap, v)),
        appVersion: $checkedConvert('appVersion', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$DiagnosticDeviceToJson(_DiagnosticDevice instance) =>
    <String, dynamic>{
      'model': instance.model,
      'os': _$DiagnosticOsEnumMap[instance.os]!,
      'appVersion': instance.appVersion,
    };

const _$DiagnosticOsEnumMap = {
  DiagnosticOs.android: 'android',
  DiagnosticOs.ios: 'ios',
  DiagnosticOs.linux: 'linux',
  DiagnosticOs.macos: 'macos',
  DiagnosticOs.windows: 'windows',
  DiagnosticOs.fuchsia: 'fuchsia',
};
