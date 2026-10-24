// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DiagnosticContext _$DiagnosticContextFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_DiagnosticContext', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'kind',
          'source',
          'latE2',
          'lonE2',
          'zoneId',
          'countryCode',
        ],
      );
      final val = _DiagnosticContext(
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$DiagnosticContextKindEnumMap, v),
        ),
        source: $checkedConvert('source', (v) => v as String),
        latE2: $checkedConvert('latE2', (v) => (v as num).toInt()),
        lonE2: $checkedConvert('lonE2', (v) => (v as num).toInt()),
        zoneId: $checkedConvert('zoneId', (v) => v as String),
        countryCode: $checkedConvert('countryCode', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$DiagnosticContextToJson(_DiagnosticContext instance) =>
    <String, dynamic>{
      'kind': _$DiagnosticContextKindEnumMap[instance.kind]!,
      'source': instance.source,
      'latE2': instance.latE2,
      'lonE2': instance.lonE2,
      'zoneId': instance.zoneId,
      'countryCode': instance.countryCode,
    };

const _$DiagnosticContextKindEnumMap = {
  DiagnosticContextKind.current: 'current',
  DiagnosticContextKind.pinned: 'pinned',
  DiagnosticContextKind.manual: 'manual',
};
