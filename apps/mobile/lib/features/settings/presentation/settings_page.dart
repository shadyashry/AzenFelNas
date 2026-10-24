import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/settings/presentation/choice_tile.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings (§18.4, static): language, digits, appearance, motion, the
/// diagnostic report and the attributions. Each change is written at once
/// (Appendix K).
final class SettingsPage extends ConsumerWidget {
  /// The page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final write = ref.watch(writeSettingProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          ChoiceTile(
            title: l.settingsLanguage,
            value: ref.watch(localeSettingProvider).value,
            choices: LocaleSetting.values,
            label: (c) => switch (c) {
              LocaleSetting.ar => l.languageArabic,
              LocaleSetting.en => l.languageEnglish,
              LocaleSetting.system => l.languageSystem,
            },
            onChanged: (v) => write.write(AppSettings.locale, v),
          ),
          ChoiceTile(
            title: l.settingsDigits,
            value: ref.watch(digitsSettingProvider).value,
            choices: DigitsSetting.values,
            label: (c) => switch (c) {
              DigitsSetting.locale => l.digitsLocale,
              DigitsSetting.western => l.digitsWestern,
              DigitsSetting.arabicIndic => l.digitsArabicIndic,
            },
            onChanged: (v) => write.write(AppSettings.digits, v),
          ),
          ChoiceTile(
            title: l.settingsTheme,
            value: ref.watch(themeModeSettingProvider).value,
            choices: ThemeModeSetting.values,
            label: (c) => switch (c) {
              ThemeModeSetting.sky => l.themeSky,
              ThemeModeSetting.light => l.themeLight,
              ThemeModeSetting.dark => l.themeDark,
              ThemeModeSetting.system => l.themeSystem,
            },
            onChanged: (v) => write.write(AppSettings.themeMode, v),
          ),
          SwitchListTile(
            title: Text(l.settingsReducedMotion),
            value: ref.watch(reducedMotionSettingProvider).value ?? false,
            onChanged: (v) => write.write(AppSettings.reducedMotionOverride, v),
          ),
          ListTile(
            title: Text(l.settingsAthan),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(const HealthRoute().location),
          ),
          ListTile(
            title: Text(l.settingsDiagnostics),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(const DiagnosticsRoute().location),
          ),
          ListTile(
            title: Text(l.settingsAttributions),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(const AttributionsRoute().location),
          ),
        ],
      ),
    );
  }
}
