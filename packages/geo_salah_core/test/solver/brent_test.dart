import 'dart:math' as math;

import 'package:geo_salah_core/src/solver/bracket.dart';
import 'package:geo_salah_core/src/solver/brent.dart';
import 'package:glados/glados.dart';

void main() {
  const solver = BrentSolver();

  group('Bracket', () {
    test('has no root to offer when both ends share a sign, so the solver '
        'reports no event instead of extrapolating (REQ-DOM-002)', () {
      expect(Bracket.tryOf((t) => t * t + 1, lowerMs: -5, upperMs: 5), isNull);
      expect(Bracket.tryOf((t) => -1, lowerMs: 0, upperMs: 1), isNull);
      expect(Bracket.tryOf((t) => double.nan, lowerMs: 0, upperMs: 1), isNull);
    });

    test('accepts a root on either end', () {
      expect(Bracket.tryOf((t) => t, lowerMs: 0, upperMs: 1), isNotNull);
      expect(Bracket.tryOf((t) => t - 1, lowerMs: 0, upperMs: 1), isNotNull);
    });

    test('rejects an empty interval', () {
      expect(
        () => Bracket.tryOf((t) => t, lowerMs: 1, upperMs: 1),
        throwsArgumentError,
      );
    });
  });

  group('BrentSolver', () {
    test('returns an end that is itself a root', () {
      double f(double t) => t - 10;
      final bracket = Bracket.tryOf(f, lowerMs: 10, upperMs: 50);
      expect(solver.solve(f, bracket!), 10);
    });

    Glados3(
      any.doubleInRange(-10000000, 10000000),
      any.doubleInRange(1, 40000000),
      any.doubleInRange(0.001, 0.999),
    ).test('converges to within 100 ms of the root and never evaluates '
        'outside the bracket (REQ-DOM-002)', (start, width, position) {
      final lower = 1.7e12 + start;
      final upper = lower + width;
      final root = lower + position * width;
      var outside = false;
      double f(double t) {
        if (t < lower || t > upper) outside = true;
        // Monotone, strongly curved near one end: a cubic plus a sine.
        final x = (t - root) / width;
        return x * x * x + 0.2 * x + 0.05 * math.sin(7 * x);
      }

      final found = solver.solve(
        f,
        Bracket.tryOf(f, lowerMs: lower, upperMs: upper)!,
      );
      expect(found, closeTo(root, 100));
      expect(outside, isFalse);
    });

    test('is deterministic: the same function and bracket give the same '
        'bits (REQ-DOM-004)', () {
      double f(double t) => math.cos(t / 3e6) - 0.3;
      final bracket = Bracket.tryOf(f, lowerMs: 0, upperMs: 4000000)!;
      final first = solver.solve(f, bracket);
      for (var i = 0; i < 10; i++) {
        expect(solver.solve(f, bracket), first);
      }
    });
  });
}
