import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/domain/apply_app_language.dart';
import 'package:daily_muslim/features/settings/domain/attribution.dart';
import 'package:daily_muslim/features/settings/domain/read_attributions.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/settings/domain/settings_ports.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bound in `app/di.dart`.
final watchSettingProvider = Provider<WatchSetting>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Bound in `app/di.dart`.
final writeSettingProvider = Provider<WriteSetting>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Bound in `app/di.dart`.
final readAttributionsProvider = Provider<ReadAttributions>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Hands the interface language to the platform (bound in `app/di.dart`).
final applyAppLanguageProvider = Provider<ApplyAppLanguage>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// `locale`.
final localeSettingProvider = StreamProvider<LocaleSetting>(
  (ref) => ref.watch(watchSettingProvider).watch(AppSettings.locale),
);

/// `digits`.
final digitsSettingProvider = StreamProvider<DigitsSetting>(
  (ref) => ref.watch(watchSettingProvider).watch(AppSettings.digits),
);

/// `themeMode`.
final themeModeSettingProvider = StreamProvider<ThemeModeSetting>(
  (ref) => ref.watch(watchSettingProvider).watch(AppSettings.themeMode),
);

/// `reducedMotionOverride`.
final reducedMotionSettingProvider = StreamProvider<bool>(
  (ref) =>
      ref.watch(watchSettingProvider).watch(AppSettings.reducedMotionOverride),
);

/// The attributions list.
final attributionsProvider = FutureProvider<List<Attribution>>(
  (ref) => ref.watch(readAttributionsProvider).call(),
);

/// The chosen Athan sound id (null until the user picks one).
final athanSoundSettingProvider = StreamProvider<String?>(
  (ref) => ref.watch(watchSettingProvider).watch(AppSettings.soundId),
);

/// The chosen Fajr sound id (null follows the Athan sound, REQ-ALM-052).
final fajrSoundSettingProvider = StreamProvider<String?>(
  (ref) => ref.watch(watchSettingProvider).watch(AppSettings.fajrSoundId),
);

/// The pre-reminder in minutes (REQ-ALM-042).
final preReminderSettingProvider = StreamProvider<int>(
  (ref) =>
      ref.watch(watchSettingProvider).watch(AppSettings.preReminderMinutes),
);

/// `hijriOverrideDays` (−1, 0 or +1; ADR-016).
final hijriOverrideSettingProvider = StreamProvider<int>(
  (ref) => ref.watch(watchSettingProvider).watch(AppSettings.hijriOverrideDays),
);

/// `athanEnabled{event: bool}`; empty until the user chooses (§15 D94).
final athanEnabledSettingProvider = StreamProvider<Map<String, bool>>(
  (ref) => ref.watch(watchSettingProvider).watch(AppSettings.athanEnabled),
);
