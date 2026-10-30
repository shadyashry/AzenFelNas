import 'package:daily_muslim/features/athan/domain/athan_health.dart';
import 'package:daily_muslim/features/athan/presentation/athan_plan_providers.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/athan/presentation/widget_snapshot_providers.dart';
import 'package:daily_muslim/features/home/domain/athan_readiness.dart';
import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/home/presentation/fasting_card.dart';
import 'package:daily_muslim/features/home/presentation/home_hour_field.dart';
import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/home/presentation/home_state.dart';
import 'package:daily_muslim/features/home/presentation/prayer_strip.dart';
import 'package:daily_muslim/features/home/presentation/time_rows.dart';
import 'package:daily_muslim/features/quran/presentation/continue_quran_card.dart';
import 'package:daily_muslim/features/shell/application/describe_failure.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/features/shell/presentation/app_tab_bar.dart';
import 'package:daily_muslim/features/shell/presentation/needs_attention_card.dart';
import 'package:daily_muslim/features/shell/presentation/scroll_insets.dart';
import 'package:daily_muslim/features/travel/presentation/travel_banner.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home (§7.2 `home`, §18.4, §15 D89): every [HomeState] is rendered by one
/// exhaustive switch on the cream ground, with the navigation bar.
final class HomePage extends ConsumerWidget {
  /// The page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    // Keeps the widget snapshot following the schedule (REQ-WID-003) and
    // arms the Athan on every open (§15 D94).
    ref
      ..watch(widgetSnapshotProvider)
      ..watch(athanPlanProvider);
    return Scaffold(
      extendBody: true,
      body: ColoredBox(
        color: RawdahScheme.of(context).ground,
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
          // The same notice as everywhere else; the code is for support
          // (§15 D98).
          HomeError(:final failure) => SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [NeedsAttentionCard(const DescribeFailure()(failure))],
            ),
          ),
        },
      ),
      bottomNavigationBar: const AppTabBar(current: RawdahTab.home),
    );
  }
}

/// Today, the Horizon composition (§15 D105): the hero, then a cream sheet
/// rising over its foot with the Quran to continue (D108), the five-prayer
/// schedule, notices, the way to
/// Athan health and the coming days, and the full list with every time's
/// confidence.
final class HomeContentView extends ConsumerWidget {
  /// Shows [content], with [notice] above the times when given.
  const new({required this.content, this.notice, super.key});

  /// What to show.
  final HomeContent content;

  /// A notice such as "engine default used" (US-06).
  final String? notice;

  /// The widest the cream sections grow, so lines stay readable in
  /// landscape and on tablets.
  static const double _readingWidth = 640;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final light = ref.watch(hourLightProvider);
    final next = content.nextPrayer;
    final type = DmType.of(style.locale);
    final padding = DmScales.paddingFor(MediaQuery.sizeOf(context).width);
    // Light status bar icons over the hero (§15 D101).
    return AnnotatedRegion(
      value: DmTheme.statusBarOn(Brightness.dark),
      child: ListView(
        padding: scrollInsets(context),
        children: [
          HomeHourField(content: content, style: style, light: light),
          // The cream sheet rises over the hero's foot; the room this
          // leaves at the end is only extra scroll space. Order (§15 D109):
          // the day's row, Continue Quran, then notices, the Athan and
          // seven-day links and the full list with every confidence.
          Transform.translate(
            offset: const Offset(0, -HomeHourField.sheetOverlap),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: RawdahScheme.of(context).panel,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DmScales.radiusSheet),
                ),
              ),
              child: _Reading(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: DmScales.sectionGap),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Text(
                        l.homeTitle,
                        style: type.sectionHeading.copyWith(
                          color: RawdahScheme.of(context).ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: DmScales.lineGap * 2),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: PrayerStrip(
                        day: content.day,
                        style: style,
                        next: next?.event,
                      ),
                    ),
                    const SizedBox(height: DmScales.sectionGap),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: const ContinueQuranCard(),
                    ),
                    const SizedBox(height: DmScales.sectionGap),
                    const TravelBanner(),
                    const FastingCard(),
                    if (notice case final String text)
                      Padding(
                        padding: EdgeInsets.fromLTRB(padding, 4, padding, 8),
                        child: Text(
                          text,
                          style: type.supporting.copyWith(
                            color: RawdahScheme.of(context).inkMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    _Link(
                      icon: Icons.notifications_none,
                      // The evaluated Athan Health (§8.3, §15 D95), so a
                      // missing permission shows on Home too.
                      text: switch (ref.watch(athanHealthProvider)) {
                        AsyncData(value: AthanHealthReady()) =>
                          l.athanHealthReady,
                        AsyncData(value: AthanHealthLimited()) =>
                          l.athanHealthLimited,
                        AsyncData(value: AthanHealthNotReady()) =>
                          l.athanHealthNotReady,
                        AsyncData(value: AthanHealthUnknown()) ||
                        AsyncError() ||
                        AsyncLoading() => switch (content.health) {
                          AthanReadinessUnknown() => l.homeHealthUnknown,
                        },
                      },
                      padding: padding,
                      onTap: () =>
                          context.go(AppTabBar.locationOf(RawdahTab.athan)),
                    ),
                    _Link(
                      icon: Icons.view_week_outlined,
                      text: l.timelineTitle,
                      padding: padding,
                      onTap: () => context.push(const TimelineRoute().location),
                    ),
                    const SizedBox(height: DmScales.sectionGap),
                    // Every time with its confidence, Imsak and Sunrise
                    // too (US-05, REQ-UX-001): quieter than the row.
                    _Panel(
                      padding: padding,
                      child: TimeRows(
                        day: content.day,
                        style: style,
                        next: next?.event,
                        light: light,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Centres [child] at no more than the reading width.
final class _Reading extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: HomeContentView._readingWidth,
      ),
      child: child,
    ),
  );
}

/// A cream card with a hairline and a soft green shadow (§15 D102).
final class _Panel extends StatelessWidget {
  const new({required this.child, required this.padding});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final r = RawdahScheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: r.raised,
          borderRadius: BorderRadius.circular(DmScales.radiusCard),
          border: Border.all(color: r.hairline),
          boxShadow: DmElevation.card,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
          child: child,
        ),
      ),
    );
  }
}

/// A shortcut row: a gold icon in a sage tile, the words, a chevron.
final class _Link extends StatelessWidget {
  const new({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.padding,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final r = RawdahScheme.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 5),
      child: Material(
        color: r.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DmScales.radiusControl),
          side: BorderSide(color: r.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 12, 8),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      // On a raised row at night the tile is a gold tint.
                      color: dark ? r.accent.withValues(alpha: 0.14) : r.wash,
                      borderRadius: BorderRadius.circular(DmScales.radius[1]),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        icon,
                        color: r.accent,
                        size: DmScales.iconMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  // chevron_right mirrors with the text direction
                  // (REQ-UX-030).
                  Icon(Icons.chevron_right, color: r.accent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
