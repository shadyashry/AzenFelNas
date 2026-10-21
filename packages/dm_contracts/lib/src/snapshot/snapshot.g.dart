// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Snapshot _$SnapshotFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Snapshot', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'schemaVersion',
          'contextId',
          'zoneId',
          'tzdbVersion',
          'generatedAtUtcMs',
          'locale',
          'items',
          'skyTimeline',
          'health',
        ],
      );
      final val = _Snapshot(
        schemaVersion: $checkedConvert(
          'schemaVersion',
          (v) => (v as num).toInt(),
        ),
        contextId: $checkedConvert('contextId', (v) => v as String),
        zoneId: $checkedConvert('zoneId', (v) => v as String),
        tzdbVersion: $checkedConvert('tzdbVersion', (v) => v as String),
        generatedAtUtcMs: $checkedConvert(
          'generatedAtUtcMs',
          (v) => (v as num).toInt(),
        ),
        locale: $checkedConvert(
          'locale',
          (v) => $enumDecode(_$PlanLocaleEnumMap, v),
        ),
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => SnapshotItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        skyTimeline: $checkedConvert(
          'skyTimeline',
          (v) => (v as List<dynamic>)
              .map((e) => SkySegment.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        health: $checkedConvert(
          'health',
          (v) => SnapshotHealth.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SnapshotToJson(_Snapshot instance) => <String, dynamic>{
  'schemaVersion': instance.schemaVersion,
  'contextId': instance.contextId,
  'zoneId': instance.zoneId,
  'tzdbVersion': instance.tzdbVersion,
  'generatedAtUtcMs': instance.generatedAtUtcMs,
  'locale': _$PlanLocaleEnumMap[instance.locale]!,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'skyTimeline': instance.skyTimeline.map((e) => e.toJson()).toList(),
  'health': instance.health.toJson(),
};

const _$PlanLocaleEnumMap = {PlanLocale.ar: 'ar', PlanLocale.en: 'en'};
