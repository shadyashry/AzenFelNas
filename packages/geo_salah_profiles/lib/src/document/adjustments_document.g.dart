// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adjustments_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdjustmentsDocument _$AdjustmentsDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_AdjustmentsDocument', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const ['maxAbsMinutes', 'perEventMinutes', 'ramadan'],
  );
  final val = _AdjustmentsDocument(
    maxAbsMinutes: $checkedConvert('maxAbsMinutes', (v) => (v as num).toInt()),
    perEventMinutes: $checkedConvert(
      'perEventMinutes',
      (v) =>
          (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
    ),
    ramadan: $checkedConvert(
      'ramadan',
      (v) =>
          (v as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, RuleDocument.fromJson(e as Map<String, dynamic>)),
          ) ??
          const <String, RuleDocument>{},
    ),
  );
  return val;
});

Map<String, dynamic> _$AdjustmentsDocumentToJson(
  _AdjustmentsDocument instance,
) => <String, dynamic>{
  'maxAbsMinutes': instance.maxAbsMinutes,
  'perEventMinutes': instance.perEventMinutes,
  'ramadan': instance.ramadan.map((k, e) => MapEntry(k, e.toJson())),
};
