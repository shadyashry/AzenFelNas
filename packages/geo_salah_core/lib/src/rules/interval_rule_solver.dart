import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/rules/rule_solution.dart';

/// Solves the interval rules (§6.2 `intervalAfter` / `intervalBefore`,
/// Appendix A): the event lies a fixed duration after or before the **raw**
/// instant of its base event — never its rounded one (REQ-DOM-003).
///
/// A base without a root gives the event no root, for the base's reason: an
/// interval cannot exist without its anchor (§15 D42). A base that took a
/// high-latitude fallback gives the event the same fallback moved by the
/// duration, with the same method and sensitivity (§15 D54). Pure and
/// deterministic.
final class IntervalRuleSolver {
  /// The solver.
  const new();

  /// The event [offset] from [base], the solution of [baseEvent] (positive
  /// after, negative before), floored to 1 ms.
  RuleSolution solve(
    RuleSolution base,
    Duration offset, {
    required PrayerEvent baseEvent,
  }) => switch (base) {
    RuleRoot(:final utcMs) => RuleRoot(utcMs + _floorMs(offset)),
    RuleFallback(:final utcMs, :final method, :final perturbationMinutes) =>
      RuleFallback(
        utcMs + _floorMs(offset),
        method,
        base: baseEvent,
        perturbationMinutes: perturbationMinutes,
      ),
    RuleNoRoot() => base,
  };

  /// The base and signed offset of an interval [rule] (positive after,
  /// negative before); `null` for a rule with its own instant.
  static ({PrayerEvent base, Duration offset})? intervalOf(EventRule rule) =>
      switch (rule) {
        IntervalAfterRule(:final base, :final duration) => (
          base: base,
          offset: duration,
        ),
        IntervalBeforeRule(:final base, :final duration) => (
          base: base,
          offset: -duration,
        ),
        SolarAltitudeRule() ||
        TransitRule() ||
        ShadowFactorRule() ||
        HorizonRule() => null,
      };

  static int _floorMs(Duration offset) =>
      (offset.inMicroseconds / 1000).floor();
}
