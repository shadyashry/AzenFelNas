import 'dart:math' as math;
import 'dart:ui';

/// WCAG 2.2 colour arithmetic in sRGB (relative luminance, contrast ratio,
/// source-over compositing). Pure and deterministic.
abstract final class WcagContrast {
  /// AA minimum for normal text (SC 1.4.3).
  static const double textMinimum = 4.5;

  /// AA minimum for non-text marks (SC 1.4.11).
  static const double nonTextMinimum = 3;

  static double _linear(double c) =>
      c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

  /// Relative luminance of opaque [c], `[0, 1]`.
  static double luminance(Color c) =>
      0.2126 * _linear(c.r) + 0.7152 * _linear(c.g) + 0.0722 * _linear(c.b);

  /// Contrast ratio of two opaque colours, `[1, 21]`, symmetric.
  static double ratio(Color a, Color b) {
    final la = luminance(a);
    final lb = luminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// [over] at [alpha] composited onto opaque [under].
  static Color composite(Color over, double alpha, Color under) =>
      Color.lerp(under, over.withValues(alpha: 1), alpha) ?? under;

  /// The per-channel sRGB midpoint of [a] and [b] (Appendix G).
  static Color midpoint(Color a, Color b) => Color.lerp(a, b, 0.5) ?? a;
}
