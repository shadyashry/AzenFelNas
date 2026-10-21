// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventLogEntry _$EventLogEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_EventLogEntry', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['utcMs', 'level', 'code', 'attrs']);
      final val = _EventLogEntry(
        utcMs: $checkedConvert('utcMs', (v) => (v as num).toInt()),
        level: $checkedConvert(
          'level',
          (v) => $enumDecode(_$EventLogLevelEnumMap, v),
        ),
        code: $checkedConvert(
          'code',
          (v) => const EventCodeConverter().fromJson(v as String),
        ),
        attrs: $checkedConvert(
          'attrs',
          (v) => EventLogAttrs.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$EventLogEntryToJson(_EventLogEntry instance) =>
    <String, dynamic>{
      'utcMs': instance.utcMs,
      'level': _$EventLogLevelEnumMap[instance.level]!,
      'code': const EventCodeConverter().toJson(instance.code),
      'attrs': instance.attrs.toJson(),
    };

const _$EventLogLevelEnumMap = {
  EventLogLevel.debug: 'DEBUG',
  EventLogLevel.info: 'INFO',
  EventLogLevel.warn: 'WARN',
  EventLogLevel.error: 'ERROR',
};
