import 'dart:async';
import 'dart:math' as math;

import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/qibla/domain/qibla_state.dart';
import 'package:daily_muslim/features/qibla/presentation/qibla_providers.dart';
import 'package:daily_muslim/features/qibla/presentation/shadow_times_section.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/features/shell/presentation/app_tab_bar.dart';
import 'package:daily_muslim/features/shell/presentation/scroll_insets.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Qibla screen (§6.6, §18.4): the bearing from true north is always
/// shown as a number; the arrow appears only with a trustworthy compass.
final class QiblaPage extends ConsumerWidget {
  /// Creates the page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    // A firm tap the moment the phone lines up with the Qibla (§15 D98).
    ref.listen(qiblaStateProvider, (previous, next) {
      bool aligned(AsyncValue<QiblaState?>? value) => switch (value?.value) {
        final QiblaReady ready => ready.aligned,
        _ => false,
      };
      if (aligned(next) && !aligned(previous)) {
        unawaited(HapticFeedback.heavyImpact());
      }
    });
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(l.qiblaTitle),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const AppTabBar(current: RawdahTab.qibla),
      body: switch (ref.watch(qiblaStateProvider)) {
        AsyncData(value: final QiblaState state) => QiblaView(state: state),
        AsyncData() || AsyncError() => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.qiblaNeedsPlace, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.push(const PlaceRoute().location),
                  child: Text(l.placeTitle),
                ),
              ],
            ),
          ),
        ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// One [QiblaState].
final class QiblaView extends ConsumerWidget {
  /// Shows [state].
  const new({required this.state, super.key});

  /// What to show.
  final QiblaState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final digits = DisplayStyle.of(context, ref).digits;
    final qibla = state.qibla;
    final km = (qibla.distanceM / 1000).round().toString();
    // The one instruction the user follows, large under the dial (§15 D98).
    final (String guidance, bool facing) = switch (state) {
      QiblaNoHeading() => (l.qiblaNoHeading, false),
      QiblaCalibrating() => (l.qiblaCalibrating, false),
      QiblaNumericOnly() => (l.qiblaNumericOnly, false),
      final QiblaReady ready => (_turn(l, ready, digits.apply), ready.aligned),
    };
    final lines = <String>[
      l.qiblaBearing(digits.apply(qibla.bearingDeg.toStringAsFixed(1))),
      l.qiblaDistance(digits.apply(km)),
      ...switch (state) {
        QiblaNoHeading() || QiblaNumericOnly() => const <String>[],
        QiblaCalibrating(:final accuracyDeg) => [
          if (accuracyDeg case final double a)
            l.qiblaAccuracy(digits.apply(a.round().toString())),
          l.qiblaHoldFlat,
        ],
        final QiblaReady ready => [
          l.qiblaAccuracy(digits.apply(ready.accuracyDeg.round().toString())),
          l.qiblaHoldFlat,
        ],
      },
    ];
    final ready = switch (state) {
      final QiblaReady r => r,
      _ => null,
    };
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: scrollInsets(context, horizontal: 28, top: 12),
      children: [
        Center(
          child: ConstrainedBox(
            // The dial leaves room for the bearing and the guidance below
            // it on short screens.
            constraints: BoxConstraints(
              maxWidth: math.min(320, MediaQuery.sizeOf(context).height * 0.36),
            ),
            child: Semantics(
              label: guidance,
              child: QiblaDial(
                bearingDeg: qibla.bearingDeg,
                headingDeg: switch (state) {
                  QiblaReady(:final headingDeg) ||
                  QiblaCalibrating(:final double headingDeg) => headingDeg,
                  QiblaCalibrating() ||
                  QiblaNoHeading() ||
                  QiblaNumericOnly() => null,
                },
                aligned: ready != null && ready.aligned,
                cardinals: (
                  l.compassNorth,
                  l.compassEast,
                  l.compassSouth,
                  l.compassWest,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (facing)
              const Padding(
                padding: EdgeInsetsDirectional.only(end: 8),
                child: Icon(
                  Icons.check_circle,
                  color: RawdahPalette.emerald,
                  size: 30,
                ),
              ),
            Flexible(
              child: Text(
                guidance,
                key: const Key('qiblaGuidance'),
                textAlign: TextAlign.center,
                style: DmTheme.naskh(
                  size: facing ? 26 : 22,
                  color: facing ? RawdahPalette.emerald : scheme.onSurface,
                  bold: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          digits.apply(l.qiblaDegrees(qibla.bearingDeg.round().toString())),
          textAlign: TextAlign.center,
          style: DmTheme.naskh(size: 40, color: scheme.primary, bold: true),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: GoldDivider(),
        ),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              line,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        // The Qibla without any sensor (§15 D91).
        const ShadowTimesSection(),
      ],
    );
  }

  static String _turn(
    AppLocalizations l,
    QiblaReady ready,
    String Function(String) digits,
  ) {
    if (ready.aligned) return l.qiblaFacing;
    final degrees = ready.turnDeg.round();
    return l.qiblaTurn(
      digits(degrees.abs().toString()),
      degrees > 0 ? l.qiblaRight : l.qiblaLeft,
    );
  }
}
