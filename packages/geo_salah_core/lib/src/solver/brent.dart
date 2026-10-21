import 'package:geo_salah_core/src/solver/bracket.dart';
import 'package:meta/meta.dart';

/// Brent's method (inverse quadratic interpolation, secant and bisection) on a
/// [Bracket] (§6.4 ¶5).
///
/// Every iterate stays inside the current bracket, which shrinks
/// monotonically, so the method never extrapolates and always terminates; the
/// returned instant is within [toleranceMs] of a root of a continuous
/// function. The engine's internal tolerance is 100 ms; the caller refines
/// the result with one exact evaluation and truncates it to 1 ms.
///
/// Pure and deterministic: the iterates depend only on the function values.
@immutable
final class BrentSolver {
  /// A solver converging to [toleranceMs].
  const new({this.toleranceMs = 100});

  static const int _maxIterations = 200;
  static const double _epsilon = 2.220446049250313e-16;

  /// Convergence tolerance on the root, in milliseconds.
  final double toleranceMs;

  /// A root of [f] inside [bracket], where `bracket` was built from the same
  /// [f]. The search runs on offsets from `bracket.lowerMs`, which keeps full
  /// double precision.
  double solve(double Function(double) f, Bracket bracket) {
    final origin = bracket.lowerMs;
    double g(double x) => f(origin + x);
    var a = 0.0;
    var b = bracket.upperMs - origin;
    var fa = bracket.lowerValue;
    var fb = bracket.upperValue;
    if (fa == 0) return origin;
    if (fb == 0) return origin + b;
    var c = b;
    var fc = fb;
    var d = b - a;
    var e = d;
    for (var i = 0; i < _maxIterations; i++) {
      if ((fb > 0 && fc > 0) || (fb < 0 && fc < 0)) {
        c = a;
        fc = fa;
        d = b - a;
        e = d;
      }
      if (fc.abs() < fb.abs()) {
        a = b;
        b = c;
        c = a;
        fa = fb;
        fb = fc;
        fc = fa;
      }
      final tol = 2 * _epsilon * b.abs() + 0.5 * toleranceMs;
      final xm = 0.5 * (c - b);
      if (xm.abs() <= tol || fb == 0) return origin + b;
      if (e.abs() >= tol && fa.abs() > fb.abs()) {
        final s = fb / fa;
        double p;
        double q;
        if (a == c) {
          p = 2 * xm * s;
          q = 1 - s;
        } else {
          final qa = fa / fc;
          final r = fb / fc;
          p = s * (2 * xm * qa * (qa - r) - (b - a) * (r - 1));
          q = (qa - 1) * (r - 1) * (s - 1);
        }
        if (p > 0) q = -q;
        p = p.abs();
        final bound1 = 3 * xm * q - (tol * q).abs();
        final bound2 = (e * q).abs();
        if (2 * p < (bound1 < bound2 ? bound1 : bound2)) {
          e = d;
          d = p / q;
        } else {
          d = xm;
          e = d;
        }
      } else {
        d = xm;
        e = d;
      }
      a = b;
      fa = fb;
      b += d.abs() > tol ? d : (xm > 0 ? tol : -tol);
      fb = g(b);
    }
    return origin + b;
  }
}
