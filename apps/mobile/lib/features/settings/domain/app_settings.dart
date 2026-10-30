import 'package:daily_muslim/features/settings/domain/setting_codec.dart';
import 'package:daily_muslim/features/settings/domain/setting_key.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';

/// Every Appendix K key. The defaults are presentation and housekeeping
/// defaults (§15 D76), never a religious value (§0.2 rule 1): Athan, sound
/// and reminders stay unset until the user or the Athan slice decides.
abstract final class AppSettings {
  /// `locale`.
  static const SettingKey<LocaleSetting> locale = SettingKey(
    'locale',
    EnumCodec(LocaleSetting.values),
    LocaleSetting.system,
  );

  /// `digits`.
  static const SettingKey<DigitsSetting> digits = SettingKey(
    'digits',
    EnumCodec(DigitsSetting.values),
    DigitsSetting.locale,
  );

  /// `themeMode`.
  static const SettingKey<ThemeModeSetting> themeMode = SettingKey(
    'themeMode',
    EnumCodec(ThemeModeSetting.values),
    ThemeModeSetting.sky,
  );

  /// `reducedMotionOverride`: forces reduced motion when the OS does not.
  static const SettingKey<bool> reducedMotionOverride = SettingKey(
    'reducedMotionOverride',
    BoolCodec(),
    false,
  );

  /// `athanEnabled{event: bool}`; empty until the user chooses.
  static const athanEnabled = SettingKey<Map<String, bool>>(
    'athanEnabled',
    BoolMapCodec(),
    {},
  );

  /// `soundId`; null until the user chooses.
  static const soundId = SettingKey<String?>(
    'soundId',
    OptionalStringCodec(),
    null,
  );

  /// `preReminderMinutes`; 0 is off.
  static const SettingKey<int> preReminderMinutes = SettingKey(
    'preReminderMinutes',
    CountCodec(),
    0,
  );

  /// `hijriOverrideDays (−1|0|1)`: the user's own day shift.
  static const SettingKey<int> hijriOverrideDays = SettingKey(
    'hijriOverrideDays',
    ChoiceIntCodec({-1, 0, 1}),
    0,
  );

  /// `telemetryOptIn`; off until consent (§9.2).
  static const SettingKey<bool> telemetryOptIn = SettingKey(
    'telemetryOptIn',
    BoolCodec(),
    false,
  );

  /// `telemetryConsentUtcMs`.
  static const telemetryConsentUtcMs = SettingKey<int?>(
    'telemetryConsentUtcMs',
    OptionalIntCodec(),
    null,
  );

  /// `lastSyncUtcMs`.
  static const lastSyncUtcMs = SettingKey<int?>(
    'lastSyncUtcMs',
    OptionalIntCodec(),
    null,
  );

  /// `lastRetentionRunUtcMs`.
  static const lastRetentionRunUtcMs = SettingKey<int?>(
    'lastRetentionRunUtcMs',
    OptionalIntCodec(),
    null,
  );

  /// `onboardingComplete`.
  static const SettingKey<bool> onboardingComplete = SettingKey(
    'onboardingComplete',
    BoolCodec(),
    false,
  );

  /// `activeContextId`.
  static const activeContextId = SettingKey<int?>(
    'activeContextId',
    OptionalIntCodec(),
    null,
  );

  /// `showSeconds (expert)`.
  static const SettingKey<bool> showSeconds = SettingKey(
    'showSeconds',
    BoolCodec(),
    false,
  );

  /// `athanPlanGeneration`: the generation of the last `SchedulePlan` the
  /// native host stored; the next plan takes the one above it (§15 D94).
  static const SettingKey<int> athanPlanGeneration = SettingKey(
    'athanPlanGeneration',
    CountCodec(),
    0,
  );

  /// `fajrSoundId`: the Fajr Athan's sound; null follows [soundId]
  /// (§15 D111, REQ-ALM-052).
  static const fajrSoundId = SettingKey<String?>(
    'fajrSoundId',
    OptionalStringCodec(),
    null,
  );

  /// The Appendix K key names, in order.
  static const List<String> wires = [
    'locale',
    'digits',
    'themeMode',
    'reducedMotionOverride',
    'athanEnabled',
    'soundId',
    'preReminderMinutes',
    'hijriOverrideDays',
    'telemetryOptIn',
    'telemetryConsentUtcMs',
    'lastSyncUtcMs',
    'lastRetentionRunUtcMs',
    'onboardingComplete',
    'activeContextId',
    'showSeconds',
    'athanPlanGeneration',
    'fajrSoundId',
  ];
}
