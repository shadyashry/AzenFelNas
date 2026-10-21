// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_plan_policy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchedulePlanPolicy _$SchedulePlanPolicyFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SchedulePlanPolicy', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'locale',
          'respectDnd',
          'vibrate',
          'fullAthanAndroid',
          'iosClipSeconds',
          'preReminderMinutes',
          'snoozeMinutes',
        ],
      );
      final val = _SchedulePlanPolicy(
        locale: $checkedConvert(
          'locale',
          (v) => $enumDecode(_$PlanLocaleEnumMap, v),
        ),
        respectDnd: $checkedConvert('respectDnd', (v) => v as bool),
        vibrate: $checkedConvert('vibrate', (v) => v as bool),
        fullAthanAndroid: $checkedConvert('fullAthanAndroid', (v) => v as bool),
        iosClipSeconds: $checkedConvert(
          'iosClipSeconds',
          (v) => (v as num).toInt(),
        ),
        preReminderMinutes: $checkedConvert(
          'preReminderMinutes',
          (v) => (v as num).toInt(),
        ),
        snoozeMinutes: $checkedConvert(
          'snoozeMinutes',
          (v) => (v as num).toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SchedulePlanPolicyToJson(_SchedulePlanPolicy instance) =>
    <String, dynamic>{
      'locale': _$PlanLocaleEnumMap[instance.locale]!,
      'respectDnd': instance.respectDnd,
      'vibrate': instance.vibrate,
      'fullAthanAndroid': instance.fullAthanAndroid,
      'iosClipSeconds': instance.iosClipSeconds,
      'preReminderMinutes': instance.preReminderMinutes,
      'snoozeMinutes': instance.snoozeMinutes,
    };

const _$PlanLocaleEnumMap = {PlanLocale.ar: 'ar', PlanLocale.en: 'en'};
