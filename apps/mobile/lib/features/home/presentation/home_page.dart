import 'package:daily_muslim/features/athan/presentation/widget_snapshot_providers.dart';
import 'package:daily_muslim/features/home/domain/athan_readiness.dart';
import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/home/presentation/fasting_card.dart';
import 'package:daily_muslim/features/home/presentation/home_hour_field.dart';
import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/home/presentation/home_state.dart';
import 'package:daily_muslim/features/home/presentation/time_rows.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/features/shell/presentation/app_tab_bar.dart';
import 'package:daily_muslim/features/shell/presentation/needs_attention_card.dart';
import 'package:daily_muslim/features/travel/presentation/travel_banner.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home (§7.2 `home`, §18.4, §15 D89): every [HomeState] is rendered by one
/// exhaustive switch on the pearl girih ground, with the navigation bar.
final class HomePage extends ConsumerWidget {
  /// The page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    // Keeps the widget snapshot following the schedule (REQ-WID-003).
    ref.watch(widgetSnapshotProvider);
    return Scaffold(
      extendBody: true,
      body: GirihBackdrop(
        ground: RawdahPalette.pearl,
        ink: RawdahPalette.gold,
        child: switch (ref.watch(homeStateProvider)) {
          HomeLoading() => const _Loading(),
          HomeReady(:final content) => HomeContentView(content: content),
          HomeNoProfile(:final content) => HomeContentView(
            content: content,
            notice: l.homeNoProfile,
          ),
          HomeNeedsLocation() => const _NeedsLocation(),
          HomeNeedsAttention(:final reasons) => SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final reason in reasons) NeedsAttentionCard(reason),
              ],
            ),
          ),
          HomeError(:final failure) => _Message(
            text: l.homeError(failure.code.wire),
          ),
        },
      ),
      bottomNavigationBar: const AppTabBar(current: RawdahTab.home),
    );
  }
}

/// Today: the hour-light field with the mihrab, then notices, the prayer
/// list and the way to Athan health and the coming days.
final class HomeContentView extends ConsumerWidget {
  /// Shows [content], with [notice] above the times when given.
  const new({required this.content, this.notice, super.key});

  /// What to show.
  final HomeContent content;

  /// A notice such as "engine default used" (US-06).
  final String? notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final light = ref.watch(hourLightProvider);
    final next = content.nextPrayer;
    return ListView(
      padding: const EdgeInsets.only(bottom: 112),
      children: [
        HomeHourField(content: content, style: style, light: light),
        const TravelBanner(),
        const FastingCard(),
        if (notice case final String text)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: GoldDivider(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TimeRows(
            day: content.day,
            style: style,
            next: next?.event,
            light: light,
          ),
        ),
        const SizedBox(height: 8),
        _Link(
          icon: Icons.notifications_none,
          text: switch (content.health) {
            AthanReadinessUnknown() => l.homeHealthUnknown,
          },
          onTap: () => context.go(AppTabBar.locationOf(RawdahTab.athan)),
        ),
        _Link(
          icon: Icons.view_week_outlined,
          text: l.timelineTitle,
          onTap: () => context.push(const TimelineRoute().location),
        ),
      ],
    );
  }
}

final class _Link extends StatelessWidget {
  const new({required this.icon, required this.text, required this.onTap});

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 22),
    leading: Icon(icon, color: RawdahPalette.goldDeep, size: 20),
    title: Text(text, style: Theme.of(context).textTheme.bodyLarge),
    // chevron_right mirrors with the text direction (REQ-UX-030).
    trailing: const Icon(Icons.chevron_right, color: RawdahPalette.goldDeep),
    onTap: onTap,
  );
}

final class _NeedsLocation extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.homeNeedsLocation, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push(const PlaceRoute().location),
              child: Text(l.onboardingChoosePlace),
            ),
          ],
        ),
      ),
    );
  }
}

final class _Loading extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

final class _Message extends StatelessWidget {
  const new({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
