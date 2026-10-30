import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The app's navigation bar (§7.2, §15 D89) on the four destinations:
/// Home, Qibla, Athan and Settings, each a top-level location. The Qibla
/// needle takes the place's real bearing.
final class AppTabBar extends ConsumerWidget {
  /// The bar with [current] selected.
  const new({required this.current, super.key});

  /// The destination this page is.
  final RawdahTab current;

  /// The location of [tab].
  static String locationOf(RawdahTab tab) => switch (tab) {
    RawdahTab.home => const HomeRoute().location,
    RawdahTab.qibla => const QiblaRoute().location,
    RawdahTab.athan => const HealthRoute().location,
    RawdahTab.settings => const SettingsRoute().location,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    // The bar never starts the schedule itself (a deep link to Settings
    // must not compute prayer times); it follows it once Home has.
    final scheduled = ref.exists(scheduleProvider);
    return RawdahNavBar(
      current: current,
      labels: RawdahTabLabels(
        home: l.navHome,
        qibla: l.navQibla,
        athan: l.navAthan,
        settings: l.navSettings,
      ),
      qiblaBearingDeg: scheduled ? ref.watch(qiblaBearingProvider) : null,
      onSelect: (tab) {
        if (tab != current) context.go(locationOf(tab));
      },
    );
  }
}
