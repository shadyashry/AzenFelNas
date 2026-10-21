import 'package:geo_salah_core/src/rules/rule_solution.dart';

/// Solves the interval rules (§6.2 `intervalAfter` / `intervalBefore`,
/// Appendix A): the event lies a fixed duration after or before the **raw**
/// instant of its base event — never its rounded one (REQ-DOM-003).
///
/// A base without a root gives the event no root, for the base's reason: an
/// interval cannot exist without its anchor (§15 D42). Pure and
/// deterministic.
final class IntervalRuleSolver {
  /// The solver.
  const new();

  /// The event [offset] from [base] (positive after, negative before),
  /// floored to 1 ms.
  RuleSolution solve(RuleSolution base, Duration offset) => switch (base) {
    RuleRoot(:final utcMs) => RuleRoot(
      utcMs + (offset.inMicroseconds / 1000).floor(),
    ),
    RuleNoRoot() => base,
  };
}
