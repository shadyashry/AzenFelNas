import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/home/domain/athan_readiness.dart';
import 'package:daily_muslim/features/home/domain/place_view.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/home/presentation/home_state.dart';
import 'package:daily_muslim/features/home/presentation/time_rows.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/features/shell/presentation/needs_attention_card.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home (§7.2 `home`, §18.4): every [HomeState] is rendered by one
/// exhaustive switch.
final class HomePage extends ConsumerWidget {
  /// The page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.homeTitle),
        actions: [
          IconButton(
            tooltip: l.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(const SettingsRoute().location),
          ),
        ],
      ),
      body: SafeArea(
        child: switch (ref.watch(homeStateProvider)) {
          HomeLoading() => const _Loading(),
          HomeReady(:final content) => HomeContentView(content: content),
          HomeNoProfile(:final content) => HomeContentView(
            content: content,
            notice: l.homeNoProfile,
          ),
          HomeNeedsLocation() => const _NeedsLocation(),
          HomeNeedsAttention(:final reasons) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final reason in reasons) NeedsAttentionCard(reason),
            ],
          ),
          HomeError(:final failure) => _Message(
            text: l.homeError(failure.code.wire),
          ),
        },
      ),
    );
  }
}

/// Today under the sky header, with the place, notices and actions.
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
    final reducedMotion = switch (ref.watch(reducedMotionSettingProvider)) {
      AsyncData(:final value) => value,
      _ => false,
    };
    final next = content.nextPrayer;
    return ListView(
      children: [
        SkyHeader(
          sky: content.sky,
          title: next == null
              ? l.homeNoNextPrayer
              : l.homeNextPrayer(DisplayStyle.eventName(l, next.event)),
          subtitle: next == null ? '' : _countdown(l, ref, next, style),
          reducedMotion: reducedMotion,
        ),
        _PlaceBar(place: content.place),
        if (notice case final String text)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(text),
          ),
        TimeRows(day: content.day, style: style),
        ListTile(
          leading: const Icon(Icons.notifications_none),
          title: Text(switch (content.health) {
            AthanReadinessUnknown() => l.homeHealthUnknown,
          }),
        ),
        ListTile(
          leading: const Icon(Icons.view_week_outlined),
          title: Text(l.timelineTitle),
          onTap: () => context.push(const TimelineRoute().location),
        ),
      ],
    );
  }

  static String _countdown(
    AppLocalizations l,
    WidgetRef ref,
    TimeRowView next,
    DisplayStyle style,
  ) {
    final now = switch (ref.watch(nowUtcMsProvider)) {
      AsyncData(:final value) => value,
      _ => ref.watch(clockProvider).nowUtcMs(),
    };
    final remaining = (next.displayedUtcMs ?? now) - now;
    final minutes = remaining <= 0 ? 0 : (remaining + 59999) ~/ 60000;
    return style.digits.apply(
      l.homeCountdown(
        '${minutes ~/ 60}',
        (minutes % 60).toString().padLeft(2, '0'),
      ),
    );
  }
}

final class _PlaceBar extends StatelessWidget {
  const new({required this.place});

  final PlaceView place;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final label = switch (place.kind) {
      ContextKind.current => l.homeCurrentPlace,
      ContextKind.pinned => l.homePinnedPlace(place.label),
      ContextKind.manual => l.homeManualPlace(place.label),
    };
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Chip(
              avatar: const Icon(Icons.place_outlined, size: 18),
              label: Text(label, overflow: TextOverflow.ellipsis),
            ),
          ),
          TextButton(
            onPressed: () => context.push(const PlaceRoute().location),
            child: Text(l.homeChangePlace),
          ),
        ],
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
