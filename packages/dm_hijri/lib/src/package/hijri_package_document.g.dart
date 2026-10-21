// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hijri_package_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HijriPackageDocument _$HijriPackageDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_HijriPackageDocument', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['country', 'months']);
  final val = _HijriPackageDocument(
    country: $checkedConvert('country', (v) => v as String),
    months: $checkedConvert(
      'months',
      (v) => (v as List<dynamic>)
          .map((e) => HijriMonthDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$HijriPackageDocumentToJson(
  _HijriPackageDocument instance,
) => <String, dynamic>{
  'country': instance.country,
  'months': instance.months.map((e) => e.toJson()).toList(),
};
