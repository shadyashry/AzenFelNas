import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/no_event_reason.dart';
import 'package:geo_salah_core/src/rules/half_segment_crossing.dart';
import 'package:geo_salah_core/src/rules/rule_solution.dart';
import 'package:geo_salah_core/src/solver/crossing_direction.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';

/// Solves a [HorizonRule] (ADR-003, ADR-004): the instant the Sun's centre
/// crosses the geometric altitude
/// `−(refractionArcmin + semidiameterArcmin)/60 − dip`.
///
/// The crossing is chosen by [HalfSegmentCrossing] (§15 D37). Without one,
/// the Sun stays on one side of the target and the event is typed
/// `polarDay` (above at `T₀`) or `polarNight` (below) — never a fallback or
/// an extrapolation (REQ-DOM-002). Pure and deterministic.
final class HorizonRuleSolver {
  /// The solver.
  const new();

  /// The geometric target altitude of [rule] with [dipDeg] of dip, degrees.
  static double targetDeg(HorizonRule rule, {required double dipDeg}) =>
      -(rule.refractionArcmin + rule.semidiameterArcmin) / 60 - dipDeg;

  /// The root of [rule] in [direction] on the prayer day of [segments].
  RuleSolution solve(
    HorizonRule rule, {
    required CulminationSegments segments,
    required CrossingDirection direction,
    required double dipDeg,
  }) {
    final target = targetDeg(rule, dipDeg: dipDeg);
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
          ? NoEventReason.polarNight
          : NoEventReason.polarDay,
    );
  }
}
