import 'dart:math' as math;

import 'package:meta/meta.dart';

/// A piecewise cubic Hermite interpolant through equally spaced samples, with
/// central-difference slopes (§6.4 ¶2).
///
/// Interior slopes are `(v[i+1] − v[i−1]) / 2h`. The two end slopes use the
/// second-order one-sided differences `(∓3v ± 4v′ ∓ v″) / 2h`, so the outer
/// intervals keep the same order of accuracy. It never extrapolates: [valueAt]
/// and [slopeAt] throw [RangeError] outside `[startMs, endMs]`.
///
/// Immutable, pure and deterministic.
@immutable
final class CubicHermiteSeries {
  /// The interpolant through [values] sampled at `startMs + i·stepMs`.
  ///
  /// Throws [ArgumentError] for fewer than three samples or a non-positive
  /// step.
  factory fromSamples({
    required double startMs,
    required double stepMs,
    required List<double> values,
  }) {
    if (values.length < 3) {
      throw ArgumentError.value(values, 'values', 'needs at least 3 samples');
    }
    if (!(stepMs > 0)) {
      throw ArgumentError.value(stepMs, 'stepMs', 'must be positive');
    }
    final n = values.length;
    final slopes = List<double>.generate(n, (i) {
      if (i == 0) {
        return (-3 * values[0] + 4 * values[1] - values[2]) / (2 * stepMs);
      }
      if (i == n - 1) {
        return (3 * values[n - 1] - 4 * values[n - 2] + values[n - 3]) /
            (2 * stepMs);
      }
      return (values[i + 1] - values[i - 1]) / (2 * stepMs);
    });
    return CubicHermiteSeries._(
      startMs,
      stepMs,
      List.unmodifiable(values),
      List.unmodifiable(slopes),
    );
  }

  const new _(this.startMs, this.stepMs, this._values, this._slopes);

  /// Instant of the first sample (epoch ms).
  final double startMs;

  /// Spacing of the samples (ms).
  final double stepMs;

  final List<double> _values;
  final List<double> _slopes;

  /// Instant of the last sample (epoch ms).
  double get endMs => startMs + stepMs * (_values.length - 1);

  /// The interpolated value at [tMs].
  double valueAt(double tMs) {
    final (i, s) = _locate(tMs);
    final s2 = s * s;
    final s3 = s2 * s;
    return (2 * s3 - 3 * s2 + 1) * _values[i] +
        (s3 - 2 * s2 + s) * stepMs * _slopes[i] +
        (-2 * s3 + 3 * s2) * _values[i + 1] +
        (s3 - s2) * stepMs * _slopes[i + 1];
  }

  /// The derivative of the interpolant at [tMs], per millisecond.
  double slopeAt(double tMs) {
    final (i, s) = _locate(tMs);
    final s2 = s * s;
    return ((6 * s2 - 6 * s) * _values[i] +
                (-6 * s2 + 6 * s) * _values[i + 1]) /
            stepMs +
        (3 * s2 - 4 * s + 1) * _slopes[i] +
        (3 * s2 - 2 * s) * _slopes[i + 1];
  }

  /// The interval index and the position `s ∈ [0, 1]` inside it.
  (int, double) _locate(double tMs) {
    if (!(tMs >= startMs && tMs <= endMs)) {
      throw RangeError.value(tMs, 'tMs', 'outside [$startMs, $endMs]');
    }
    final x = (tMs - startMs) / stepMs;
    final i = math.min(x.floor(), _values.length - 2);
    return (i, x - i);
  }
}
