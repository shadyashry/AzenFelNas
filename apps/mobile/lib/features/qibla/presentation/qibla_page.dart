import 'dart:math' as math;

import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/qibla/domain/qibla_state.dart';
import 'package:daily_muslim/features/qibla/presentation/qibla_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/features/shell/presentation/app_tab_bar.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
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
    final lines = <String>[
      l.qiblaBearing(digits.apply(qibla.bearingDeg.toStringAsFixed(1))),
      l.qiblaDistance(digits.apply(km)),
      ...switch (state) {
        QiblaNoHeading() => [l.qiblaNoHeading],
        QiblaCalibrating(:final accuracyDeg) => [
          l.qiblaCalibrating,
          if (accuracyDeg case final double a)
            l.qiblaAccuracy(digits.apply(a.round().toString())),
        ],
        QiblaNumericOnly() => [l.qiblaNumericOnly],
        final QiblaReady ready => [
          _turn(l, ready, digits.apply),
          l.qiblaAccuracy(digits.apply(ready.accuracyDeg.round().toString())),
        ],
      },
    ];
    final ready = switch (state) {
      final QiblaReady r => r,
      _ => null,
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 120),
      children: [
        Center(
          child: ConstrainedBox(
            // The dial leaves room for the bearing and the guidance below
            // it on short screens.
            constraints: BoxConstraints(
              maxWidth: math.min(320, MediaQuery.sizeOf(context).height * 0.36),
            ),
            child: Semantics(
              label: ready == null
                  ? lines.first
                  : _turn(l, ready, digits.apply),
              child: QiblaDial(
                bearingDeg: qibla.bearingDeg,
                headingDeg: ready?.headingDeg,
                aligned: ready != null && ready.turnDeg.abs() < 3,
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
        const SizedBox(height: 8),
        Text(
          digits.apply(l.qiblaDegrees(qibla.bearingDeg.round().toString())),
          textAlign: TextAlign.center,
          style: DmTheme.naskh(
            size: 46,
            color: Theme.of(context).colorScheme.primary,
            bold: true,
          ),
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
      ],
    );
  }

  static String _turn(
    AppLocalizations l,
    QiblaReady ready,
    String Function(String) digits,
  ) {
    final degrees = ready.turnDeg.round();
    if (degrees == 0) return l.qiblaFacing;
    return l.qiblaTurn(
      digits(degrees.abs().toString()),
      degrees > 0 ? l.qiblaRight : l.qiblaLeft,
    );
  }
}
