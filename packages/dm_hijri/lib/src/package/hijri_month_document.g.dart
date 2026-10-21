// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hijri_month_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HijriMonthDocument _$HijriMonthDocumentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_HijriMonthDocument', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'hijriYear',
          'hijriMonth',
          'gregorianStart',
          'status',
          'sourceUrl',
        ],
      );
      final val = _HijriMonthDocument(
        hijriYear: $checkedConvert('hijriYear', (v) => (v as num).toInt()),
        hijriMonth: $checkedConvert('hijriMonth', (v) => (v as num).toInt()),
        gregorianStart: $checkedConvert('gregorianStart', (v) => v as String),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$HijriMonthStatusCodeEnumMap, v),
        ),
        sourceUrl: $checkedConvert('sourceUrl', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$HijriMonthDocumentToJson(_HijriMonthDocument instance) =>
    <String, dynamic>{
      'hijriYear': instance.hijriYear,
      'hijriMonth': instance.hijriMonth,
      'gregorianStart': instance.gregorianStart,
      'status': _$HijriMonthStatusCodeEnumMap[instance.status]!,
      'sourceUrl': ?instance.sourceUrl,
    };

const _$HijriMonthStatusCodeEnumMap = {
  HijriMonthStatusCode.confirmed: 'confirmed',
  HijriMonthStatusCode.expected: 'expected',
};
