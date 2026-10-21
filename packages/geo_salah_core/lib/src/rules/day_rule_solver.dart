import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/model/engine_failure.dart';
import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/rules/altitude_rule_solver.dart';
import 'package:geo_salah_core/src/rules/horizon_rule_solver.dart';
import 'package:geo_salah_core/src/rules/interval_rule_solver.dart';
import 'package:geo_salah_core/src/rules/rule_solution.dart';
import 'package:geo_salah_core/src/rules/shadow_rule_solver.dart';
import 'package:geo_salah_core/src/rules/transit_rule_solver.dart';
import 'package:geo_salah_core/src/solver/crossing_direction.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';

/// Solves every rule of a profile on one prayer day (§6.4 ¶6): the rule
/// step only — no fallback, adjustment or rounding.
///
/// Rules with their own instant (altitude, transit, shadow factor, horizon)
/// are solved first; interval rules then take their base's raw instant
/// (REQ-DOM-003). Each event's rule must fit it (§15 D37, D41, D42):
/// - `transit` defines Dhuhr only; `horizon` and `solarAltitude` any other
///   event, in its half of the day (ADR-004); `shadowFactor` a descending
///   event (Asr);
/// - `solarAltitude` needs `0 < degrees < 90`, `shadowFactor` `k ≥ 1`, an
///   interval a positive duration;
/// - an interval's base is another event of the profile solved by a
///   non-interval rule, earlier in the day for `intervalAfter` and later for
///   `intervalBefore`.
///
/// Anything else is `EngineFailure.invalidProfile` (REQ-ERR-001). Pure and
/// deterministic.
final class DayRuleSolver {
  /// The solver.
  const new();

  static const TransitRuleSolver _transit = TransitRuleSolver();
  static const HorizonRuleSolver _horizon = HorizonRuleSolver();
  static const AltitudeRuleSolver _altitude = AltitudeRuleSolver();
  static const ShadowRuleSolver _shadow = ShadowRuleSolver();
  static const IntervalRuleSolver _interval = IntervalRuleSolver();

  /// The rule solution of each event of [rules] on the day of [segments],
  /// in [PrayerEvent] order, for an observer at geodetic [latitudeDeg] with
  /// [dipDeg] of horizon dip.
  Result<Map<PrayerEvent, RuleSolution>, EngineFailure> solve(
    Map<PrayerEvent, EventRule> rules, {
    required CulminationSegments segments,
    required double latitudeDeg,
    required double dipDeg,
  }) {
    final direct = <PrayerEvent, RuleSolution>{};
    for (final event in PrayerEvent.values) {
      final rule = rules[event];
      if (rule == null) continue;
      final solved = _direct(event, rule, segments, latitudeDeg, dipDeg);
      switch (solved) {
        case null:
          continue;
        case Err(:final failure):
          return Result.err(failure);
        case Ok(:final value):
          direct[event] = value;
      }
    }
    final solutions = <PrayerEvent, RuleSolution>{};
    for (final event in PrayerEvent.values) {
      final rule = rules[event];
      if (rule == null) continue;
      final solution = switch (direct[event]) {
        final RuleSolution solved => Result<RuleSolution, EngineFailure>.ok(
          solved,
        ),
        null => _intervalOf(event, rule, direct),
      };
      switch (solution) {
        case Err(:final failure):
          return Result.err(failure);
        case Ok(:final value):
          solutions[event] = value;
      }
    }
    return Result.ok(Map.unmodifiable(solutions));
  }

  /// The solution of a rule with its own instant; `null` for an interval
  /// rule, which is solved once its base is.
  static Result<RuleSolution, EngineFailure>? _direct(
    PrayerEvent event,
    EventRule rule,
    CulminationSegments segments,
    double latitudeDeg,
    double dipDeg,
  ) => switch ((rule, _directionOf(event))) {
    (IntervalAfterRule() || IntervalBeforeRule(), _) => null,
    (final TransitRule transit, null) => Result.ok(
      _transit.solve(transit, segments),
    ),
    (final HorizonRule horizon, final CrossingDirection direction) => Result.ok(
      _horizon.solve(
        horizon,
        segments: segments,
        direction: direction,
        dipDeg: dipDeg,
      ),
    ),
    (final SolarAltitudeRule altitude, final CrossingDirection direction) =>
      altitude.degrees > 0 && altitude.degrees < 90
          ? Result.ok(
              _altitude.solve(
                altitude,
                segments: segments,
                direction: direction,
              ),
            )
          : _invalid('solarAltitude degrees ${altitude.degrees} for $event'),
    (final ShadowFactorRule shadow, CrossingDirection.setting) =>
      shadow.k >= 1
          ? Result.ok(
              _shadow.solve(
                shadow,
                segments: segments,
                latitudeDeg: latitudeDeg,
              ),
            )
          : _invalid('shadowFactor k ${shadow.k} for $event'),
    (TransitRule(), CrossingDirection()) ||
    (HorizonRule() || SolarAltitudeRule() || ShadowFactorRule(), null) ||
    (ShadowFactorRule(), CrossingDirection.rising) => _invalid(
      'rule ${rule.runtimeType} cannot define ${event.name}',
    ),
  };

  /// The solution of [event]'s interval [rule] from the [direct] solutions.
  static Result<RuleSolution, EngineFailure> _intervalOf(
    PrayerEvent event,
    EventRule rule,
    Map<PrayerEvent, RuleSolution> direct,
  ) {
    final (base, offset, baseIsEarlier) = switch (rule) {
      IntervalAfterRule(:final base, :final duration) => (
        base,
        duration,
        true,
      ),
      IntervalBeforeRule(:final base, :final duration) => (
        base,
        -duration,
        false,
      ),
      // Unreachable: a rule with its own instant is always in [direct].
      SolarAltitudeRule() ||
      TransitRule() ||
      ShadowFactorRule() ||
      HorizonRule() => throw StateError('$event has a direct rule'),
    };
    final baseSolution = direct[base];
    if (baseSolution == null) {
      return _invalid('${event.name} interval base ${base.name} is not solved');
    }
    if (base == event || (base.index < event.index) != baseIsEarlier) {
      return _invalid('${event.name} interval base ${base.name} is misplaced');
    }
    if (offset == Duration.zero || offset.isNegative == baseIsEarlier) {
      return _invalid('${event.name} interval duration must be positive');
    }
    return Result.ok(_interval.solve(baseSolution, offset, baseEvent: base));
  }

  static Result<RuleSolution, EngineFailure> _invalid(String reason) =>
      Result.err(EngineFailure.invalidProfile(reason));

  /// The half segment an event lies in (ADR-004): `null` for the transit.
  static CrossingDirection? _directionOf(PrayerEvent event) => switch (event) {
    PrayerEvent.imsak ||
    PrayerEvent.fajr ||
    PrayerEvent.sunrise => CrossingDirection.rising,
    PrayerEvent.dhuhr => null,
    PrayerEvent.asr ||
    PrayerEvent.maghrib ||
    PrayerEvent.isha => CrossingDirection.setting,
  };
}
