// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_files.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DiagnosticFiles _$DiagnosticFilesFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_DiagnosticFiles',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const [
            'events.jsonl',
            'health.json',
            'plan_redacted.json',
            'packages.json',
            'device.json',
            'context.json',
          ],
        );
        final val = _DiagnosticFiles(
          events: $checkedConvert(
            'events.jsonl',
            (v) => (v as List<dynamic>)
                .map((e) => EventLogEntry.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          health: $checkedConvert(
            'health.json',
            (v) => DiagnosticHealth.fromJson(v as Map<String, dynamic>),
          ),
          plan: $checkedConvert(
            'plan_redacted.json',
            (v) => DiagnosticPlan.fromJson(v as Map<String, dynamic>),
          ),
          packages: $checkedConvert(
            'packages.json',
            (v) => (v as List<dynamic>)
                .map(
                  (e) => DiagnosticPackage.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          ),
          device: $checkedConvert(
            'device.json',
            (v) => DiagnosticDevice.fromJson(v as Map<String, dynamic>),
          ),
          context: $checkedConvert(
            'context.json',
            (v) => v == null
                ? null
                : DiagnosticContext.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'events': 'events.jsonl',
        'health': 'health.json',
        'plan': 'plan_redacted.json',
        'packages': 'packages.json',
        'device': 'device.json',
        'context': 'context.json',
      },
    );

Map<String, dynamic> _$DiagnosticFilesToJson(_DiagnosticFiles instance) =>
    <String, dynamic>{
      'events.jsonl': instance.events.map((e) => e.toJson()).toList(),
      'health.json': instance.health.toJson(),
      'plan_redacted.json': instance.plan.toJson(),
      'packages.json': instance.packages.map((e) => e.toJson()).toList(),
      'device.json': instance.device.toJson(),
      'context.json': instance.context?.toJson(),
    };
