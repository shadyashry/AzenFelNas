import 'package:daily_muslim/features/athan/domain/athan_grant.dart';
import 'package:daily_muslim/features/athan/domain/athan_health.dart';
import 'package:daily_muslim/features/athan/domain/athan_health_reason.dart';
import 'package:daily_muslim/features/athan/presentation/athan_copy.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Athan Health section (§18.4 `evaluating | ready | limited(reasons) |
/// notReady(reasons) | unknown(reasons)`); state is shown by text and icon,
/// never by colour alone (§7.9).
final class AthanHealthCard extends ConsumerWidget {
  /// The card.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final health = ref.watch(athanHealthProvider);
    final (
      MedallionTone tone,
      String title,
      List<AthanHealthReason> reasons,
    ) = switch (health) {
      AsyncData(value: final AthanHealthReady h) => (
        MedallionTone.ready,
        l.athanHealthReady,
        h.reasons,
      ),
      AsyncData(value: final AthanHealthLimited h) => (
        MedallionTone.limited,
        l.athanHealthLimited,
        h.reasons,
      ),
      AsyncData(value: final AthanHealthNotReady h) => (
        MedallionTone.notReady,
        l.athanHealthNotReady,
        h.reasons,
      ),
      AsyncData(value: final AthanHealthUnknown h) => (
        MedallionTone.unknown,
        l.athanHealthUnknown,
        h.reasons,
      ),
      AsyncError() => (MedallionTone.unknown, l.athanHealthUnknown, const []),
      AsyncLoading() => (
        MedallionTone.unknown,
        l.athanHealthEvaluating,
        const [],
      ),
    };
    final theme = Theme.of(context);
    // The medallion, then the state in words and its reasons (§15 D89).
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        children: [
          // Wider than the medallion, so the refresh button stands clear of
          // its ring.
          SizedBox(
            width: 236,
            height: 136,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ReadinessMedallion(glyph: RawdahGlyphKind.minaret, tone: tone),
                PositionedDirectional(
                  end: 0,
                  bottom: 0,
                  child: IconButton(
                    tooltip: l.athanHealthEvaluating,
                    icon: Icon(
                      Icons.refresh,
                      color: theme.colorScheme.secondary,
                    ),
                    onPressed: () => ref.invalidate(athanHealthProvider),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(l.athanHealthTitle, style: theme.textTheme.labelMedium),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: DmTheme.naskh(
                size: 22,
                color: theme.colorScheme.primary,
                bold: true,
              ),
            ),
          ),
          if (reasons.isNotEmpty)
            RawdahSection(
              children: [
                for (final reason in reasons)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.arrow_right,
                      color: theme.colorScheme.secondary,
                    ),
                    minLeadingWidth: 12,
                    title: Text(
                      l.athanReason(reason),
                      style: theme.textTheme.bodyLarge,
                    ),
                    trailing: switch (AthanGrant.of(reason)) {
                      null => null,
                      final grant => TextButton(
                        onPressed: () => _grant(context, ref, grant),
                        child: Text(switch (grant) {
                          AthanGrant.notifications ||
                          AthanGrant.exactAlarms => l.athanGrantAllow,
                          AthanGrant.appSettings => l.athanGrantOpenSettings,
                        }),
                      ),
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }

  /// Shows the system prompt for [grant], then evaluates Health again; a
  /// granted exact-alarm permission re-arms natively (§15 D95).
  static Future<void> _grant(
    BuildContext context,
    WidgetRef ref,
    AthanGrant grant,
  ) async {
    await ref.read(requestAthanGrantProvider).call(grant);
    if (context.mounted) ref.invalidate(athanHealthProvider);
  }
}
