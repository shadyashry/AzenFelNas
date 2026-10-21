import 'package:meta/meta.dart';

/// An interval `[lowerMs, upperMs]` on whose ends a function does not have the
/// same strict sign, so it holds a root of a continuous function (§6.4 ¶5).
///
/// Only [tryOf] creates one, and it returns `null` when there is no sign
/// change: the solver then reports no root rather than extrapolating.
/// Immutable.
@immutable
final class Bracket {
  const new _(this.lowerMs, this.upperMs, this.lowerValue, this.upperValue);

  /// Evaluates [f] at [lowerMs] and [upperMs] and returns the bracket, or
  /// `null` when both values are strictly positive, both strictly negative,
  /// or either is NaN.
  ///
  /// Throws [ArgumentError] unless `lowerMs < upperMs`.
  static Bracket? tryOf(
    double Function(double) f, {
    required double lowerMs,
    required double upperMs,
  }) {
    if (!(lowerMs < upperMs)) {
      throw ArgumentError('Empty interval [$lowerMs, $upperMs]');
    }
    final lowerValue = f(lowerMs);
    final upperValue = f(upperMs);
    final bracketsRoot =
        (lowerValue <= 0 && upperValue >= 0) ||
        (lowerValue >= 0 && upperValue <= 0);
    return bracketsRoot
        ? Bracket._(lowerMs, upperMs, lowerValue, upperValue)
        : null;
  }

  /// Lower end (epoch ms).
  final double lowerMs;

  /// Upper end (epoch ms).
  final double upperMs;

  /// The function value at [lowerMs].
  final double lowerValue;

  /// The function value at [upperMs].
  final double upperValue;
}
