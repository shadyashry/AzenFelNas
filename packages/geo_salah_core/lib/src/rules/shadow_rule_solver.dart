import 'dart:math' as math;

import 'package:geo_salah_core/src/astro/angles.dart';
import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/no_event_reason.dart';
import 'package:geo_salah_core/src/rules/half_segment_crossing.dart';
import 'package:geo_salah_core/src/rules/rule_solution.dart';
import 'package:geo_salah_core/src/solver/crossing_direction.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';

/// Solves a [ShadowFactorRule] (Asr, §6.4 ¶6): the first setting crossing in
/// `[T₀, A₊]` of `h = arccot(k + tan|φ − δ(T₀)|)`.
///
/// `φ` is the observer's geodetic latitude and `δ(T₀)` the Sun's geocentric
/// declination at the upper transit. If `90° − |φ − δ(T₀)| ≤ 0` the Sun does
/// not stand above the horizon at noon, no shadow ratio exists and the
/// event is `asrUndefined`. Without a crossing the Sun either stays above
/// `h` all afternoon (`polarDay`) or, by parallax at a near-zero noon
/// altitude, is already below it at `T₀` (`asrUndefined`) (§15 D41). Pure
/// and deterministic.
final class ShadowRuleSolver {
  /// The solver.
  const new();

  /// The Asr target altitude for [k] at noon zenith distance [zenithDeg]
  /// (`|φ − δ|`), degrees; `null` when `90° − zenithDeg ≤ 0`.
  static double? targetDeg({required int k, required double zenithDeg}) {
    if (90 - zenithDeg <= 0) return null;
    return radToDeg(math.atan(1 / (k + math.tan(degToRad(zenithDeg)))));
  }

  /// The root of [rule] on the prayer day of [segments] for an observer at
  /// geodetic [latitudeDeg].
  RuleSolution solve(
    ShadowFactorRule rule, {
    required CulminationSegments segments,
    required double latitudeDeg,
  }) {
    final target = targetDeg(
      k: rule.k,
      zenithDeg: (latitudeDeg - segments.upperDeclinationDeg).abs(),
    );
    if (target == null) return const RuleNoRoot(NoEventReason.asrUndefined);
    const direction = CrossingDirection.setting;
    final root = HalfSegmentCrossing.find(
      segments,
      direction: direction,
      targetDeg: target,
    );
    if (root != null) return RuleRoot(root);
    final culminationDeg = HalfSegmentCrossing.upperAltitudeDeg(
      segments,
      direction: direction,
    );
    return RuleNoRoot(
      culminationDeg < target
          ? NoEventReason.asrUndefined
          : NoEventReason.polarDay,
    );
  }
}
