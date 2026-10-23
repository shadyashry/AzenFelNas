import 'dart:math' as math;

import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/qibla/domain/qibla_state.dart';
import 'package:daily_muslim/features/qibla/presentation/qibla_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
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
      appBar: AppBar(title: Text(l.qiblaTitle)),
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
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (state case final QiblaReady ready)
          Center(
            child: Semantics(
              label: _turn(l, ready, digits.apply),
              child: SizedBox.square(
                dimension: 240,
                child: CustomPaint(
                  painter: _DialPainter(
                    turnRad: ready.turnDeg * math.pi / 180,
                    color: Theme.of(context).colorScheme.primary,
                    ring: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
          ),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(line, textAlign: TextAlign.center),
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

/// A ring with an arrow rotated by the turn to the Qibla (0 = straight up,
/// the way the phone points).
final class _DialPainter extends CustomPainter {
  const new({required this.turnRad, required this.color, required this.ring});

  final double turnRad;
  final Color color;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 4;
    final arrow = Path()
      ..moveTo(0, -radius + 8)
      ..lineTo(14, -radius + 40)
      ..lineTo(4, -radius + 40)
      ..lineTo(4, radius * 0.4)
      ..lineTo(-4, radius * 0.4)
      ..lineTo(-4, -radius + 40)
      ..lineTo(-14, -radius + 40)
      ..close();
    canvas
      ..drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = ring,
      )
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(turnRad)
      ..drawPath(arrow, Paint()..color = color)
      ..restore();
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.turnRad != turnRad || old.color != color || old.ring != ring;
}
