import 'dart:math' as math;

import 'package:geo_salah_core/src/solver/altitude_source.dart';
import 'package:geo_salah_core/src/solver/bracket.dart';
import 'package:geo_salah_core/src/solver/brent.dart';
import 'package:geo_salah_core/src/solver/crossing.dart';
import 'package:geo_salah_core/src/solver/crossing_direction.dart';
import 'package:meta/meta.dart';

/// A half culmination segment split at the stationary points of the solar
/// altitude into pieces on which the altitude is monotone (ADR-004, §6.4 ¶5).
///
/// **Exhaustiveness.** A continuous function that is monotone on a piece
/// crosses a target there at most once, and does so exactly when the
/// target lies between the piece's end values. [crossings] therefore checks
/// every piece's ends, so it finds every crossing; with no sign change it
/// reports none and never extrapolates.
///
/// **Stationary points.** The altitude rate is sampled every hour or less and
/// each sign change is solved with Brent. That finds them all as long as no
/// sampling cell holds two. For the Sun, `d(sin h)/dt = A·sin H + B` with
/// `|A| = cos φ·cos δ·ω` and `|B| ≤ |dδ/dt| ≈ 0.41°/day`. Its zeros lie
/// within minutes of a culmination, and two of them fit in one cell only if
/// `|B/A| ≥ cos 7.5°`. That needs `cos φ ≤ 1.3·10⁻³`, i.e. `|φ| > 89.9°`, so
/// exhaustiveness holds for `|φ| ≤ 89.9°` (§15 D34).
///
/// Immutable and deterministic.
@immutable
final class MonotonePieces {
  /// Partitions `[startMs, endMs]` of [source]. The source must be defined
  /// on `[startMs − 1 s, endMs + 1 s]`.
  ///
  /// Throws [ArgumentError] unless `startMs < endMs`.
  factory of(
    AltitudeSource source, {
    required double startMs,
    required double endMs,
  }) {
    if (!(startMs < endMs)) {
      throw ArgumentError('Empty segment [$startMs, $endMs]');
    }
    final cells = math.max(2, ((endMs - startMs) / _maxCellMs).ceil());
    final width = (endMs - startMs) / cells;
    double rate(double t) => _rateDegPerMs(source, t);
    final boundaries = <double>[startMs];
    var t0 = startMs;
    var g0 = rate(t0);
    for (var i = 1; i <= cells; i++) {
      final t1 = i == cells ? endMs : startMs + i * width;
      final g1 = rate(t1);
      if (g0 * g1 < 0) {
        final bracket = Bracket.tryOf(rate, lowerMs: t0, upperMs: t1);
        if (bracket != null) boundaries.add(_stationary.solve(rate, bracket));
      } else if (g1 == 0 && i < cells) {
        boundaries.add(t1);
      }
      t0 = t1;
      g0 = g1;
    }
    boundaries.add(endMs);
    return MonotonePieces._(source, List.unmodifiable(boundaries));
  }

  const new _(this.source, this.boundaries);

  static const double _maxCellMs = 3600000;
  static const double _rateStepMs = 500;
  static const BrentSolver _stationary = BrentSolver(toleranceMs: 1);
  static const BrentSolver _root = BrentSolver();

  /// The altitude source.
  final AltitudeSource source;

  /// `startMs`, the stationary points in time order, then `endMs`; consecutive
  /// boundaries delimit one monotone piece.
  final List<double> boundaries;

  /// Every crossing of [targetDeg] (geometric altitude, degrees), in time
  /// order: at most one per piece.
  ///
  /// Each root is bracketed, solved with Brent to 100 ms on the fast
  /// altitude, refined with one Newton step on the exact altitude (kept only
  /// if it stays inside the piece), and truncated to 1 ms. A root exactly on
  /// an inner boundary is reported once.
  List<Crossing> crossings(double targetDeg) {
    double offset(double t) => source.altitudeDeg(t) - targetDeg;
    final found = <Crossing>[];
    for (var i = 0; i + 1 < boundaries.length; i++) {
      final lower = boundaries[i];
      final upper = boundaries[i + 1];
      if (!(lower < upper)) continue;
      final bracket = Bracket.tryOf(offset, lowerMs: lower, upperMs: upper);
      final isLast = i + 2 == boundaries.length;
      if (bracket == null || (bracket.upperValue == 0 && !isLast)) continue;
      final root = _refine(_root.solve(offset, bracket), targetDeg, bracket);
      found.add(
        Crossing(
          utcMs: root.floor(),
          direction: bracket.upperValue > bracket.lowerValue
              ? CrossingDirection.rising
              : CrossingDirection.setting,
        ),
      );
    }
    return List.unmodifiable(found);
  }

  /// One Newton step on the exact altitude from [root], kept inside
  /// [bracket].
  double _refine(double root, double targetDeg, Bracket bracket) {
    final slope = _rateDegPerMs(source, root);
    if (slope == 0) return root;
    final refined = root - (source.exactAltitudeDeg(root) - targetDeg) / slope;
    return refined >= bracket.lowerMs && refined <= bracket.upperMs
        ? refined
        : root;
  }

  static double _rateDegPerMs(AltitudeSource source, double t) =>
      (source.altitudeDeg(t + _rateStepMs) -
          source.altitudeDeg(t - _rateStepMs)) /
      (2 * _rateStepMs);
}
