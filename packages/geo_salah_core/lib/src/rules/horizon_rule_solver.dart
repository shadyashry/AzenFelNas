import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/no_event_reason.dart';
import 'package:geo_salah_core/src/rules/rule_solution.dart';
import 'package:geo_salah_core/src/solver/crossing_direction.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';

/// Solves a [HorizonRule] (ADR-003, ADR-004): the instant the Sun's centre
/// crosses the geometric altitude
/// `−(refractionArcmin + semidiameterArcmin)/60 − dip`.
///
/// A rising event (Sunrise) is searched in the ascending half `[A₋, T₀]`, a
/// setting one (Maghrib) in the descending half `[T₀, A₊]`. If the half has
/// several crossings in the event's direction (possible only near a grazing
/// crossing), the one bounding the daylight around `T₀` is taken: the last
/// rising crossing before `T₀`, the first setting one after it (§15 D37).
/// Without one, the Sun stays on one side of the target and the event is
/// typed `polarDay` (above at `T₀`) or `polarNight` (below) — never a
/// fallback or an extrapolation (REQ-DOM-002). Pure and deterministic.
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
    final half = switch (direction) {
      CrossingDirection.rising => segments.ascending,
      CrossingDirection.setting => segments.descending,
    };
    final inDirection = [
      for (final crossing in half.crossings(target))
        if (crossing.direction == direction) crossing,
    ];
    if (inDirection.isNotEmpty) {
      return RuleRoot(switch (direction) {
        CrossingDirection.rising => inDirection.last.utcMs,
        CrossingDirection.setting => inDirection.first.utcMs,
      });
    }
    final culminationDeg = half.source.altitudeDeg(segments.upperUtcMs);
    return RuleNoRoot(
      culminationDeg < target
          ? NoEventReason.polarNight
          : NoEventReason.polarDay,
    );
  }
}
