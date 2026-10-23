import 'package:daily_muslim/features/athan/domain/pre_reminder.dart';
import 'package:daily_muslim/features/athan/presentation/athan_health_card.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/athan/presentation/athan_test_panel.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/presentation/choice_tile.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Athan settings (§18.4 `ready(settings, health)`): Health, the Test, the
/// sound and the pre-reminder (REQ-ALM-042).
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
    final chosen = ids.contains(soundId) ? soundId : null;
    return Scaffold(
      appBar: AppBar(title: Text(l.athanTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(8),
        children: [
          const AthanHealthCard(),
          AthanTestPanel(soundId: chosen),
          if (ids.isEmpty)
            ListTile(title: Text(l.athanSound), subtitle: Text(l.athanNoSounds))
          else
            ChoiceTile<String>(
              title: l.athanSound,
              value: chosen,
              choices: ids,
              label: (id) => id,
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
    );
  }
}
