// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rules_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RulesDocument _$RulesDocumentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_RulesDocument', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'imsak',
          'fajr',
          'sunrise',
          'dhuhr',
          'asr',
          'maghrib',
          'isha',
        ],
      );
      final val = _RulesDocument(
        imsak: $checkedConvert(
          'imsak',
          (v) => v == null
              ? null
              : RuleDocument.fromJson(v as Map<String, dynamic>),
        ),
        fajr: $checkedConvert(
          'fajr',
          (v) => RuleDocument.fromJson(v as Map<String, dynamic>),
        ),
        sunrise: $checkedConvert(
          'sunrise',
          (v) => RuleDocument.fromJson(v as Map<String, dynamic>),
        ),
        dhuhr: $checkedConvert(
          'dhuhr',
          (v) => RuleDocument.fromJson(v as Map<String, dynamic>),
        ),
        asr: $checkedConvert(
          'asr',
          (v) => RuleDocument.fromJson(v as Map<String, dynamic>),
        ),
        maghrib: $checkedConvert(
          'maghrib',
          (v) => RuleDocument.fromJson(v as Map<String, dynamic>),
        ),
        isha: $checkedConvert(
          'isha',
          (v) => RuleDocument.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RulesDocumentToJson(_RulesDocument instance) =>
    <String, dynamic>{
      'imsak': instance.imsak?.toJson(),
      'fajr': instance.fajr.toJson(),
      'sunrise': instance.sunrise.toJson(),
      'dhuhr': instance.dhuhr.toJson(),
      'asr': instance.asr.toJson(),
      'maghrib': instance.maghrib.toJson(),
      'isha': instance.isha.toJson(),
    };
