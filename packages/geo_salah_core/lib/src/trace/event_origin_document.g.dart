// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_origin_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrimaryOriginDocument _$PrimaryOriginDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PrimaryOriginDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['kind']);
  final val = PrimaryOriginDocument(
    $type: $checkedConvert('kind', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$PrimaryOriginDocumentToJson(
  PrimaryOriginDocument instance,
) => <String, dynamic>{'kind': instance.$type};

FallbackOriginDocument _$FallbackOriginDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('FallbackOriginDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['method', 'kind']);
  final val = FallbackOriginDocument(
    method: $checkedConvert(
      'method',
      (v) => const HighLatitudeMethodDocumentConverter().fromJson(v),
    ),
    $type: $checkedConvert('kind', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$FallbackOriginDocumentToJson(
  FallbackOriginDocument instance,
) => <String, dynamic>{
  'method': ?const HighLatitudeMethodDocumentConverter().toJson(
    instance.method,
  ),
  'kind': instance.$type,
};

NoEventOriginDocument _$NoEventOriginDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('NoEventOriginDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['reason', 'kind']);
  final val = NoEventOriginDocument(
    reason: $checkedConvert(
      'reason',
      (v) => $enumDecode(_$NoEventReasonCodeEnumMap, v),
    ),
    $type: $checkedConvert('kind', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$NoEventOriginDocumentToJson(
  NoEventOriginDocument instance,
) => <String, dynamic>{
  'reason': _$NoEventReasonCodeEnumMap[instance.reason]!,
  'kind': instance.$type,
};

const _$NoEventReasonCodeEnumMap = {
  NoEventReasonCode.polarDay: 'POLAR_DAY',
  NoEventReasonCode.polarNight: 'POLAR_NIGHT',
  NoEventReasonCode.twilightAbsent: 'TWILIGHT_ABSENT',
  NoEventReasonCode.asrUndefined: 'ASR_UNDEFINED',
  NoEventReasonCode.chainExhausted: 'CHAIN_EXHAUSTED',
};
