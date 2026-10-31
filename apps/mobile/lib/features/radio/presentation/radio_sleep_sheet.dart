import 'dart:async';

import 'package:daily_muslim/features/radio/domain/radio_playback.dart';
import 'package:daily_muslim/features/radio/presentation/radio_providers.dart';
import 'package:daily_muslim/features/radio/presentation/radio_tokens.dart';
import 'package:daily_muslim/features/radio/presentation/radio_type.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The sleep timer's choices: Off, 15, 30 and 60 minutes, the running one
/// ticked (§15 D122, REQ-RADIO-009). The native player keeps the deadline,
/// so it holds through navigation, rotation and a locked screen.
Future<void> showRadioSleepSheet(BuildContext context, WidgetRef ref) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: RadioTokens.of(context).surface,
      builder: (context) => const _SleepSheet(),
    );

final class _SleepSheet extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = RadioTokens.of(context);
    final type = RadioType.of(context);
    final current =
        ref.watch(radioPlaybackProvider).value?.sleep?.option ??
        RadioSleepOption.off;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l.radioSleepTimer,
                style: type.sectionTitle.copyWith(color: t.text),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                l.radioSleepSheetBody,
                style: type.secondary.copyWith(color: t.textMuted),
              ),
            ),
            for (final option in RadioSleepOption.values)
              ListTile(
                minTileHeight: 48,
                selected: option == current,
                selectedColor: t.text,
                textColor: t.text,
                title: Text(radioSleepValue(l, option), style: type.body),
                trailing: option == current
                    ? Icon(Icons.check, color: t.goldIcon)
                    : null,
                onTap: () {
                  unawaited(
                    ref.read(radioControllerProvider.notifier).sleep(option),
                  );
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
