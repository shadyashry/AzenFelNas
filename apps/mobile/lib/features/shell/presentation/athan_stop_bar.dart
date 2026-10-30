import 'dart:async';

import 'package:daily_muslim/features/athan/presentation/athan_voice_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app's own Stop while an Athan plays (§15 D118, REQ-ALM-043): above
/// the tabs on every tab, so an Athan whose notification was swiped away or
/// is out of sight can always be stopped. Nothing shows otherwise.
final class AthanStopBar extends ConsumerWidget {
  /// The bar.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(athanPlayingProvider).value != true) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    final r = RawdahScheme.of(context);
    // Light gold by day; a raised night surface with a gold outline in the
    // dark appearance, where the Stop button itself is gold (§15 D119).
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? r.ink : RawdahPalette.forest;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: dark ? r.raised : RawdahPalette.goldLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: dark ? BorderSide(color: r.accent) : BorderSide.none,
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 8, 8),
          child: Row(
            children: [
              Icon(Icons.volume_up, color: dark ? r.accent : text),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.athanPlayingNow,
                  style: TextStyle(color: text, fontWeight: FontWeight.w600),
                ),
              ),
              FilledButton.icon(
                onPressed: () => unawaited(
                  ref.read(athanPlaybackProvider).stopAthan(),
                ),
                icon: const Icon(Icons.stop),
                label: Text(l.athanStopNow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
