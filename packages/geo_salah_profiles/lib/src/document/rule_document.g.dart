// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SolarAltitudeRuleDocument _$SolarAltitudeRuleDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SolarAltitudeRuleDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['degrees', 'type']);
  final val = SolarAltitudeRuleDocument(
    degrees: $checkedConvert('degrees', (v) => (v as num).toDouble()),
    $type: $checkedConvert('type', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$SolarAltitudeRuleDocumentToJson(
  SolarAltitudeRuleDocument instance,
) => <String, dynamic>{'degrees': instance.degrees, 'type': instance.$type};

TransitRuleDocument _$TransitRuleDocumentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TransitRuleDocument', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['offsetMinutes', 'type']);
      final val = TransitRuleDocument(
        offsetMinutes: $checkedConvert(
          'offsetMinutes',
          (v) => (v as num?)?.toInt(),
        ),
        $type: $checkedConvert('type', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$TransitRuleDocumentToJson(
  TransitRuleDocument instance,
) => <String, dynamic>{
  'offsetMinutes': ?instance.offsetMinutes,
  'type': instance.$type,
};

ShadowFactorRuleDocument _$ShadowFactorRuleDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ShadowFactorRuleDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['k', 'type']);
  final val = ShadowFactorRuleDocument(
    k: $checkedConvert('k', (v) => (v as num).toInt()),
    $type: $checkedConvert('type', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$ShadowFactorRuleDocumentToJson(
  ShadowFactorRuleDocument instance,
) => <String, dynamic>{'k': instance.k, 'type': instance.$type};

HorizonRuleDocument _$HorizonRuleDocumentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HorizonRuleDocument', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['refractionArcmin', 'semidiameterArcmin', 'type'],
      );
      final val = HorizonRuleDocument(
        refractionArcmin: $checkedConvert(
          'refractionArcmin',
          (v) => (v as num?)?.toDouble(),
        ),
        semidiameterArcmin: $checkedConvert(
          'semidiameterArcmin',
          (v) => (v as num?)?.toDouble(),
        ),
        $type: $checkedConvert('type', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$HorizonRuleDocumentToJson(
  HorizonRuleDocument instance,
) => <String, dynamic>{
  'refractionArcmin': ?instance.refractionArcmin,
  'semidiameterArcmin': ?instance.semidiameterArcmin,
  'type': instance.$type,
};

IntervalAfterRuleDocument _$IntervalAfterRuleDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('IntervalAfterRuleDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['base', 'minutes', 'type']);
  final val = IntervalAfterRuleDocument(
    base: $checkedConvert(
      'base',
      (v) => $enumDecode(_$IntervalBaseCodeEnumMap, v),
    ),
    minutes: $checkedConvert('minutes', (v) => (v as num).toInt()),
    $type: $checkedConvert('type', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$IntervalAfterRuleDocumentToJson(
  IntervalAfterRuleDocument instance,
) => <String, dynamic>{
  'base': _$IntervalBaseCodeEnumMap[instance.base]!,
  'minutes': instance.minutes,
  'type': instance.$type,
};

const _$IntervalBaseCodeEnumMap = {
  IntervalBaseCode.maghrib: 'maghrib',
  IntervalBaseCode.fajr: 'fajr',
};

IntervalBeforeRuleDocument _$IntervalBeforeRuleDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('IntervalBeforeRuleDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['base', 'minutes', 'type']);
  final val = IntervalBeforeRuleDocument(
    base: $checkedConvert(
      'base',
      (v) => $enumDecode(_$IntervalBaseCodeEnumMap, v),
    ),
    minutes: $checkedConvert('minutes', (v) => (v as num).toInt()),
    $type: $checkedConvert('type', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$IntervalBeforeRuleDocumentToJson(
  IntervalBeforeRuleDocument instance,
) => <String, dynamic>{
  'base': _$IntervalBaseCodeEnumMap[instance.base]!,
  'minutes': instance.minutes,
  'type': instance.$type,
};
