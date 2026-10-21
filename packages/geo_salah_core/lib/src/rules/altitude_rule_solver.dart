import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/no_event_reason.dart';
import 'package:geo_salah_core/src/rules/half_segment_crossing.dart';
import 'package:geo_salah_core/src/rules/rule_solution.dart';
import 'package:geo_salah_core/src/solver/crossing_direction.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';

/// Solves a [SolarAltitudeRule] (ADR-003, ADR-004, §6.4 ¶5–¶6): the instant
/// the Sun's centre crosses the geometric altitude `−degrees`, with no
/// refraction and no dip.
///
/// A rising event (Imsak, Fajr) is searched in `[A₋, T₀]`, a setting one
/// (Isha) in `[T₀, A₊]`; the crossing is chosen by [HalfSegmentCrossing].
/// Without one the Sun stays on one side of `−degrees` all half-day: below
/// it at `T₀` means it never rises that far (`polarNight`); otherwise it
/// never sinks that far and the twilight altitude is never reached
/// (`twilightAbsent`, §15 D41). A missing root is never extrapolated or
/// replaced here; the high-latitude chain (S08) handles it (REQ-DOM-002).
/// Pure and deterministic.
final class AltitudeRuleSolver {
  /// The solver.
  const new();

  /// The root of [rule] in [direction] on the prayer day of [segments].
  RuleSolution solve(
    SolarAltitudeRule rule, {
    required CulminationSegments segments,
    required CrossingDirection direction,
  }) {
    final target = -rule.degrees;
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
          : NoEventReason.twilightAbsent,
    );
  }
}
