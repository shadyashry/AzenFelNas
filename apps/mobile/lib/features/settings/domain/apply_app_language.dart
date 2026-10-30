import 'package:daily_muslim/features/settings/domain/setting_values.dart';

/// Hands the interface language to the platform, so text the native layer
/// draws with no Dart alive (Athan actions, channels, the Test, the widget)
/// is in the language the app shows (§15 D116).
abstract interface class ApplyAppLanguage {
  /// Applies [setting]; [LocaleSetting.system] follows the phone again.
  Future<void> call(LocaleSetting setting);
}
