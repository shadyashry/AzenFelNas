import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/rules/rule_solution.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';

/// Solves a [TransitRule]: Dhuhr = `T₀` + offset (ADR-004, §6.4 ¶4).
///
/// The upper transit exists every day at every latitude, so the rule always
/// has a root. The offset belongs to the rule, not to the adjustment trace:
/// the raw instant includes it (§15 D29). Pure and deterministic.
final class TransitRuleSolver {
  /// The solver.
  const new();

  /// The root of [rule] on the prayer day of [segments], floored to 1 ms.
  RuleRoot solve(TransitRule rule, CulminationSegments segments) => RuleRoot(
    (segments.upperUtcMs + rule.offset.inMicroseconds / 1000).floor(),
  );
}
