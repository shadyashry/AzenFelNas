import 'package:daily_muslim/features/athan/application/athan_preferences.dart';
import 'package:daily_muslim/features/athan/domain/pre_reminder.dart';
import 'package:daily_muslim/features/athan/presentation/athan_health_card.dart';
import 'package:daily_muslim/features/athan/presentation/athan_plan_providers.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/athan/presentation/athan_test_panel.dart';
import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/presentation/choice_tile.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/shell/presentation/app_tab_bar.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Athan settings (§18.4 `ready(settings, health)`): Health, the Test, the
/// prayers that alert, the sound and the pre-reminder (REQ-ALM-042).
final class AthanPage extends ConsumerWidget {
  /// The page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final write = ref.watch(writeSettingProvider);
    final soundId = ref.watch(athanSoundSettingProvider).value;
    final sounds = ref.watch(athanSoundsProvider).value ?? const [];
    final ids = sounds;
    final stored = ref.watch(athanEnabledSettingProvider).value ?? const {};
    final enabled = AthanPreferences.enabledOf(stored);
    // The sound that plays: the chosen one, else the first bundled one, as
    // the plan does (§15 D94).
    final chosen = ids.contains(soundId) ? soundId : ids.firstOrNull;
    // A changed sound or reminder re-arms the Athan at once.
    ref.watch(athanPlanProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.athanTitle),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const AppTabBar(current: RawdahTab.athan),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 112),
        children: [
          const AthanHealthCard(),
          AthanTestPanel(soundId: chosen),
          RawdahSection(
            children: [
              if (ids.isEmpty)
                ListTile(
                  title: Text(l.athanSound),
                  subtitle: Text(l.athanNoSounds),
                )
              else
                ChoiceTile<String>(
                  title: l.athanSound,
                  value: chosen,
                  choices: ids,
                  label: (id) => soundLabel(l, id),
                  onChanged: (id) => write.write(AppSettings.soundId, id),
                ),
              ChoiceTile<PreReminder>(
                title: l.athanPreReminder,
                value: PreReminder.ofMinutes(
                  ref.watch(preReminderSettingProvider).value ?? 0,
                ),
                choices: PreReminder.values,
                label: (p) => switch (p) {
                  PreReminder.off => l.athanPreReminderOff,
                  PreReminder.five ||
                  PreReminder.ten ||
                  PreReminder.fifteen ||
                  PreReminder.thirty => l.athanPreReminderMinutes(p.minutes),
                },
                onChanged: (p) =>
                    write.write(AppSettings.preReminderMinutes, p.minutes),
              ),
            ],
          ),
          RawdahSection(
            title: l.athanPrayersTitle,
            children: [
              for (final event in AthanPreferences.defaultEvents)
                SwitchListTile(
                  title: Text(DisplayStyle.eventName(l, event)),
                  value: enabled.contains(event),
                  onChanged: (on) => write.write(
                    AppSettings.athanEnabled,
                    AthanPreferences.toggled(stored, event, on: on),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// The name shown for sound [id]: bundled test sounds (`test_` ids, §15
  /// D94) say so; licensed recordings show their id until the manifest
  /// carries display names (§15 D95).
  static String soundLabel(AppLocalizations l, String id) =>
      id.startsWith(testSoundPrefix) ? l.athanSoundTest : id;

  /// The id prefix of bundled test sounds.
  static const testSoundPrefix = 'test_';
}
