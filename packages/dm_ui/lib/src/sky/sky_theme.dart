import 'dart:ui';

import 'package:dm_ui/src/color/wcag_contrast.dart';
import 'package:dm_ui/src/tokens/sky_tokens.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// The Home surface colours for one sky phase (§7.9, ADR-018).
///
/// The gradient, accent and on-surface come from Appendix G unchanged. Text
/// sits on a [scrim]: the other on-surface candidate at [scrimAlpha], the
/// smallest multiple of 0.05 for which [onSurface] reaches 4.5:1 and
/// [accent] 3:1 against the gradient's top, midpoint and bottom, each
/// composited under the scrim (§15 D75). Phases whose tokens already pass
/// get alpha 0. Sky colours do not change with brightness; content
/// surfaces use `StaticPalette`. Pure and deterministic (REQ-UX-010).
@immutable
final class SkyTheme {
  const new _({
    required this.phase,
    required this.gradientTop,
    required this.gradientBottom,
    required this.accent,
    required this.onSurface,
    required this.scrim,
    required this.scrimAlpha,
  });

  /// The theme of [phase].
  factory forPhase(SkyPhase phase) {
    final t = SkyTokens.of(phase);
    final scrim = SkyTokens.onSurfaceCandidates.firstWhere(
      (c) => c != t.onSurface,
    );
    var steps = 0;
    while (steps < 20 &&
        !_passes(t.top, t.bottom, t.onSurface, t.accent, scrim, steps / 20)) {
      steps++;
    }
    return SkyTheme._(
      phase: phase,
      gradientTop: t.top,
      gradientBottom: t.bottom,
      accent: t.accent,
      onSurface: t.onSurface,
      scrim: scrim,
      scrimAlpha: steps / 20,
    );
  }

  /// The theme of [state]'s phase (ADR-018).
  factory fromSolarState(SolarState state) => SkyTheme.forPhase(state.phase);

  /// The phase.
  final SkyPhase phase;

  /// Gradient top stop.
  final Color gradientTop;

  /// Gradient bottom stop.
  final Color gradientBottom;

  /// Accent for icons and non-text marks.
  final Color accent;

  /// Text and icons on the sky.
  final Color onSurface;

  /// Opaque scrim colour laid under text.
  final Color scrim;

  /// Scrim opacity, `[0, 1]` in steps of 0.05.
  final double scrimAlpha;

  /// The gradient stops a text block may sit on: top, midpoint, bottom.
  List<Color> get stops => [
    gradientTop,
    WcagContrast.midpoint(gradientTop, gradientBottom),
    gradientBottom,
  ];

  /// [stop] as seen through the scrim.
  Color underText(Color stop) =>
      WcagContrast.composite(scrim, scrimAlpha, stop);

  /// The lowest [onSurface] contrast over [stops] through the scrim.
  double get minTextContrast => stops
      .map((s) => WcagContrast.ratio(onSurface, underText(s)))
      .reduce((a, b) => a < b ? a : b);

  static bool _passes(
    Color top,
    Color bottom,
    Color text,
    Color accent,
    Color scrim,
    double alpha,
  ) {
    for (final stop in [top, WcagContrast.midpoint(top, bottom), bottom]) {
      final under = WcagContrast.composite(scrim, alpha, stop);
      if (WcagContrast.ratio(text, under) < WcagContrast.textMinimum ||
          WcagContrast.ratio(accent, under) < WcagContrast.nonTextMinimum) {
        return false;
      }
    }
    return true;
  }
}
