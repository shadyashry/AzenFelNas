import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/api/engine_version.dart';
import 'package:geo_salah_core/src/astro/delta_t.dart';
import 'package:geo_salah_core/src/astro/sun_sample_cache.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:geo_salah_core/src/model/adjustment_kind.dart';
import 'package:geo_salah_core/src/model/adjustment_step.dart';
import 'package:geo_salah_core/src/model/day_result.dart';
import 'package:geo_salah_core/src/model/engine_failure.dart';
import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/hijri_confidence.dart';
import 'package:geo_salah_core/src/model/hijri_state.dart';
import 'package:geo_salah_core/src/model/horizon_elevation_policy.dart';
import 'package:geo_salah_core/src/model/observer.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';
import 'package:geo_salah_core/src/model/prayer_time.dart';
import 'package:geo_salah_core/src/model/provenance.dart';
import 'package:geo_salah_core/src/model/reference_mode.dart';
import 'package:geo_salah_core/src/model/result_flag.dart';
import 'package:geo_salah_core/src/model/tz_database.dart';
import 'package:geo_salah_core/src/policy/adjustments.dart';
import 'package:geo_salah_core/src/policy/day_flags.dart';
import 'package:geo_salah_core/src/policy/event_finisher.dart';
import 'package:geo_salah_core/src/policy/ordering_guard.dart';
import 'package:geo_salah_core/src/rules/high_latitude.dart';
import 'package:geo_salah_core/src/rules/ramadan_rules.dart';
import 'package:geo_salah_core/src/rules/rule_solution.dart';
import 'package:geo_salah_core/src/rules/solved_days.dart';
import 'package:geo_salah_core/src/trace/calculation_id.dart';
import 'package:geo_salah_core/src/trace/calculation_inputs.dart';
import 'package:geo_salah_core/src/trace/calculation_trace_writer.dart';

/// The §6.4 pipeline for one prayer day, shared by `CalculateDay` and
/// `CalculateRange` (internal; not exported).
///
/// Steps, in order: elevation policy (ADR-003) → calculation point
/// (ADR-006: the observer, or its area's reference point) → culmination
/// segments (ADR-004) → rules (¶6: Ramadan rule replacement, then each
/// rule, interval rules on raw bases) → high-latitude chain for the events
/// without a root (¶7) → per-event offsets (¶8) → rounding, last (¶9) →
/// flags and confidence (REQ-DOM-050) → ordering guard on displayed instants
/// (¶10, REQ-DOM-001) → Calculation ID (¶11).
///
/// Each event's trace lists its steps in that order:
/// `ramadanRuleReplacement` (reason `adjustments.ramadan`, the change from
/// the standard rule's root when both rules have one, else 0),
/// `highLatitudeFallback` (reason `highLatitude.<method>`, 0 ms: the rule
/// has no instant to move), `perEventOffset`, `rounding` (§15 D54, D56).
/// A replaced event of a day whose Hijri state is `expected` carries
/// `hijriExpected` (§15 D44, D56).
///
/// An optional [SolvedDays] memo (with its [SunSampleCache]) lets a range
/// reuse SPA samples and solved days between days; it never changes a
/// result (REQ-DOM-004). Pure and deterministic.
final class DayCalculation {
  /// The pipeline.
  const new();

  /// Last supported year (§15 D36).
  static const int lastYear = 5999;

  static const PerEventOffsets _offsets = PerEventOffsets();
  static const RamadanRules _ramadan = RamadanRules();
  static const HighLatitudeChain _highLatitude = HighLatitudeChain();
  static const DayFlags _flags = DayFlags();
  static const EventFinisher _finisher = EventFinisher();
  static const OrderingGuard _guard = OrderingGuard();
  static const CalculationTraceWriter _writer = CalculationTraceWriter();

  /// The prayer day [day] for [observer] under [profile]. Throws
  /// [ArgumentError] for a day after [lastYear].
  ///
  /// [days], a memo a range shares between its days, must locate days in
  /// `observer.zoneId` with [tzdb]; without one the day uses its own.
  Result<DayResult, EngineFailure> calculate({
    required Observer observer,
    required PrayerProfile profile,
    required CivilDate day,
    required TzDatabase tzdb,
    required HijriState hijri,
    SolvedDays? days,
  }) {
    if (day.year > lastYear) {
      throw ArgumentError.value(day, 'day', 'after year $lastYear');
    }
    final double dipDeg;
    switch (_dipOf(profile)) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(:final value):
        dipDeg = value;
    }
    final inputs = CalculationInputs.of(
      observer: observer,
      profile: profile,
      day: day,
      hijri: hijri,
    );
    final solved = _solveRules(
      profile,
      inputs: inputs,
      dipDeg: dipDeg,
      days:
          days ??
          SolvedDays(
            zoneId: observer.zoneId,
            tzdb: tzdb,
            cache: SunSampleCache(),
          ),
    );
    return switch (solved) {
      Err(:final failure) => Result.err(failure),
      Ok(value: null) => Result.ok(
        _dayResult(inputs, const [], const [], tzdb),
      ),
      Ok(value: final _SolvedRules rules) => _finish(
        rules,
        observer: observer,
        profile: profile,
        inputs: inputs,
        tzdb: tzdb,
      ),
    };
  }

  /// The horizon dip of [profile]'s elevation policy (ADR-003), or the
  /// failure of a profile the engine cannot evaluate: a `[DEFERRED V2]`
  /// policy, an offset beyond `maxAbsMinutes`, or an authority reference
  /// mode without exactly one point (ADR-006).
  static Result<double, EngineFailure> _dipOf(PrayerProfile profile) {
    final dipDeg = switch (profile.elevationPolicy) {
      HorizonElevationPolicy.none => 0.0,
      HorizonElevationPolicy.aboveLocalTerrain ||
      HorizonElevationPolicy.authorityTable => null,
    };
    if (dipDeg == null) {
      return const Result.err(
        EngineFailure.unsupportedPolicy('horizon.elevationPolicy'),
      );
    }
    if (_offsets.check(profile) case Err(:final failure)) {
      return Result.err(failure);
    }
    if (profile.referenceMode == ReferenceMode.authorityReferencePoint &&
        profile.referencePoints.length != 1) {
      return Result.err(
        EngineFailure.invalidProfile(
          'referencePoints: ${profile.referencePoints.length} points; the '
          "resolver leaves the one for the observer's area (ADR-006)",
        ),
      );
    }
    return Result.ok(dipDeg);
  }

  /// The rule step (¶6, after Ramadan replacement) and the high-latitude
  /// step (¶7) for [inputs]: each event's solution with its rule-level
  /// trace steps and flags, or `null` for a day the zone skipped.
  static Result<_SolvedRules?, EngineFailure> _solveRules(
    PrayerProfile profile, {
    required CalculationInputs inputs,
    required double dipDeg,
    required SolvedDays days,
  }) {
    final RamadanSelection selection;
    switch (_ramadan.select(profile, inputs.hijri)) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(:final value):
        selection = value;
    }
    final (:rules, :replaced) = selection;
    final site = TopocentricSite.of(
      latitudeDeg: inputs.latitudeDeg,
      longitudeDeg: inputs.longitudeDeg,
    );
    Result<SolvedDay?, EngineFailure> solve(Map<PrayerEvent, EventRule> r) =>
        days.solve(inputs.day, site, rules: r, dipDeg: dipDeg);
    final SolvedDay solved;
    switch (solve(rules)) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(value: null):
        return const Result.ok(null);
      case Ok(:final SolvedDay value):
        solved = value;
    }
    final Map<PrayerEvent, RuleSolution> standard;
    switch (replaced.isEmpty ? null : solve(profile.rules)) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(:final value):
        standard = value?.solutions ?? const {};
      case null:
        standard = const {};
    }
    final resolved = _highLatitude.apply(
      solved.solutions,
      rules: rules,
      chain: profile.highLatitudeChain,
      day: inputs.day,
      site: site,
      dipDeg: dipDeg,
      days: days,
    );
    return Result.ok((
      solutions: resolved,
      steps: _ruleSteps(
        resolved,
        replaced: replaced,
        standard: standard,
        inForce: solved.solutions,
      ),
      flags: {
        if (inputs.hijri.confidence == HijriConfidence.expected)
          for (final event in replaced) event: const {ResultFlag.hijriExpected},
      },
    ));
  }

  /// The rule-level trace steps of each event of [resolved]: Ramadan
  /// replacement (from the [standard] rule's root to the [inForce] one),
  /// then the high-latitude fallback.
  static Map<PrayerEvent, List<AdjustmentStep>> _ruleSteps(
    Map<PrayerEvent, RuleSolution> resolved, {
    required Set<PrayerEvent> replaced,
    required Map<PrayerEvent, RuleSolution> standard,
    required Map<PrayerEvent, RuleSolution> inForce,
  }) => {
    for (final MapEntry(key: event, value: solution) in resolved.entries)
      event: [
        if (replaced.contains(event))
          _ramadanStep(event, from: standard[event], to: inForce[event]),
        if (solution case final RuleFallback fallback)
          AdjustmentStep(
            event: event,
            kind: AdjustmentKind.highLatitudeFallback,
            deltaMs: 0,
            reason: HighLatitudeChain.reasonOf(fallback),
          ),
      ],
  };

  /// The trace step of Ramadan replacing [event]'s rule: the change from
  /// the standard rule's root [from] to the Ramadan rule's root [to], or 0
  /// when either has none.
  static AdjustmentStep _ramadanStep(
    PrayerEvent event, {
    required RuleSolution? from,
    required RuleSolution? to,
  }) => AdjustmentStep(
    event: event,
    kind: AdjustmentKind.ramadanRuleReplacement,
    deltaMs: switch ((from, to)) {
      (RuleRoot(utcMs: final before), RuleRoot(utcMs: final after)) =>
        after - before,
      _ => 0,
    },
    reason: 'adjustments.ramadan',
  );

  Result<DayResult, EngineFailure> _finish(
    _SolvedRules rules, {
    required Observer observer,
    required PrayerProfile profile,
    required CalculationInputs inputs,
    required TzDatabase tzdb,
  }) {
    final dayFlags = _flags.of(
      observer: observer,
      profile: profile,
      day: inputs.day,
      tzdb: tzdb,
    );
    final times = <PrayerTime>[];
    final steps = <AdjustmentStep>[];
    for (final MapEntry(key: event, value: solution)
        in rules.solutions.entries) {
      final (:time, steps: eventSteps) = _finisher.finish(
        event,
        solution,
        profile: profile,
        day: inputs.day,
        zoneId: observer.zoneId,
        tzdb: tzdb,
        dayFlags: dayFlags,
        eventFlags: rules.flags[event] ?? const {},
      );
      times.add(time);
      steps
        ..addAll(rules.steps[event] ?? const [])
        ..addAll(eventSteps);
    }
    final result = _dayResult(inputs, times, steps, tzdb);
    if (_guard.firstViolation(result.times) == null) return Result.ok(result);
    return Result.err(
      EngineFailure.orderingViolation(
        jsonEncode(_writer.write(result, inputs).toJson()),
      ),
    );
  }

  static DayResult _dayResult(
    CalculationInputs inputs,
    List<PrayerTime> times,
    List<AdjustmentStep> steps,
    TzDatabase tzdb,
  ) {
    final inputsHash = inputs.inputsHash;
    return DayResult(
      day: inputs.day,
      calculationId: CalculationId.of(
        inputsHash: inputsHash,
        engineVersion: EngineVersion.current,
        deltaTModel: EspenakMeeusDeltaT.modelId,
        tzdbVersion: tzdb.version,
      ),
      times: List.unmodifiable(times),
      provenance: Provenance(
        engineVersion: EngineVersion.current,
        deltaTModel: EspenakMeeusDeltaT.modelId,
        profileId: inputs.profileId,
        profileVersion: inputs.profileVersion,
        tzdbVersion: tzdb.version,
        inputsHash: inputsHash,
        hijriConfidence: inputs.hijri.confidence,
        adjustmentTrace: List.unmodifiable(steps),
      ),
    );
  }
}

/// Each event's solution after the rule and high-latitude steps, the trace
/// steps those steps took and the flags they set, by event.
typedef _SolvedRules = ({
  Map<PrayerEvent, RuleSolution> solutions,
  Map<PrayerEvent, List<AdjustmentStep>> steps,
  Map<PrayerEvent, Set<ResultFlag>> flags,
});
