import 'package:daily_muslim/features/athan/domain/athan_health.dart';
import 'package:daily_muslim/features/athan/domain/athan_health_reason.dart';
import 'package:daily_muslim/features/athan/presentation/athan_copy.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
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
      IconData icon,
      String title,
      List<AthanHealthReason> reasons,
    ) = switch (health) {
      AsyncData(value: final AthanHealthReady h) => (
        Icons.check_circle_outline,
        l.athanHealthReady,
        h.reasons,
      ),
      AsyncData(value: final AthanHealthLimited h) => (
        Icons.error_outline,
        l.athanHealthLimited,
        h.reasons,
      ),
      AsyncData(value: final AthanHealthNotReady h) => (
        Icons.notifications_off_outlined,
        l.athanHealthNotReady,
        h.reasons,
      ),
      AsyncData(value: final AthanHealthUnknown h) => (
        Icons.help_outline,
        l.athanHealthUnknown,
        h.reasons,
      ),
      AsyncError() => (Icons.help_outline, l.athanHealthUnknown, const []),
      AsyncLoading() => (
        Icons.hourglass_empty,
        l.athanHealthEvaluating,
        const [],
      ),
    };
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(l.athanHealthTitle),
            subtitle: Text(title),
            trailing: IconButton(
              tooltip: l.athanHealthEvaluating,
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(athanHealthProvider),
            ),
          ),
          for (final reason in reasons)
            ListTile(dense: true, title: Text(l.athanReason(reason))),
        ],
      ),
    );
  }
}
