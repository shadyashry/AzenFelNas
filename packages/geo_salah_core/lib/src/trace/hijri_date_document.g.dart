// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hijri_date_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HijriDateDocument _$HijriDateDocumentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_HijriDateDocument', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['year', 'month', 'day']);
      final val = _HijriDateDocument(
        year: $checkedConvert('year', (v) => (v as num).toInt()),
        month: $checkedConvert('month', (v) => (v as num).toInt()),
        day: $checkedConvert('day', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$HijriDateDocumentToJson(_HijriDateDocument instance) =>
    <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'day': instance.day,
    };
