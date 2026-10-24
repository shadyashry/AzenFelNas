// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_health.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DiagnosticHealth _$DiagnosticHealthFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_DiagnosticHealth', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'path',
          'state',
          'reasons',
          'probes',
          'evaluatedAtUtcMs',
        ],
      );
      final val = _DiagnosticHealth(
        path: $checkedConvert(
          'path',
          (v) => $enumDecode(_$DiagnosticDeliveryPathEnumMap, v),
        ),
        state: $checkedConvert(
          'state',
          (v) => $enumDecode(_$DiagnosticHealthStateEnumMap, v),
        ),
        reasons: $checkedConvert(
          'reasons',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        probes: $checkedConvert(
          'probes',
          (v) => (v as List<dynamic>)
              .map((e) => DiagnosticProbe.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        evaluatedAtUtcMs: $checkedConvert(
          'evaluatedAtUtcMs',
          (v) => (v as num).toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DiagnosticHealthToJson(_DiagnosticHealth instance) =>
    <String, dynamic>{
      'path': _$DiagnosticDeliveryPathEnumMap[instance.path]!,
      'state': _$DiagnosticHealthStateEnumMap[instance.state]!,
      'reasons': instance.reasons,
      'probes': instance.probes.map((e) => e.toJson()).toList(),
      'evaluatedAtUtcMs': instance.evaluatedAtUtcMs,
    };

const _$DiagnosticDeliveryPathEnumMap = {
  DiagnosticDeliveryPath.androidExact: 'androidExact',
  DiagnosticDeliveryPath.androidInexact: 'androidInexact',
  DiagnosticDeliveryPath.iosAlarmKit: 'iosAlarmKit',
  DiagnosticDeliveryPath.iosNotification: 'iosNotification',
  DiagnosticDeliveryPath.unavailable: 'unavailable',
};

const _$DiagnosticHealthStateEnumMap = {
  DiagnosticHealthState.ready: 'ready',
  DiagnosticHealthState.limited: 'limited',
  DiagnosticHealthState.notReady: 'notReady',
  DiagnosticHealthState.unknown: 'unknown',
};

_DiagnosticProbe _$DiagnosticProbeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_DiagnosticProbe', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['name', 'positive']);
      final val = _DiagnosticProbe(
        name: $checkedConvert('name', (v) => v as String),
        positive: $checkedConvert('positive', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$DiagnosticProbeToJson(_DiagnosticProbe instance) =>
    <String, dynamic>{'name': instance.name, 'positive': instance.positive};
