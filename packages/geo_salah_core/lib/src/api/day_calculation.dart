import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/api/engine_version.dart';
import 'package:geo_salah_core/src/astro/delta_t.dart';
import 'package:geo_salah_core/src/astro/sun_sample_cache.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:geo_salah_core/src/model/adjustment_step.dart';
import 'package:geo_salah_core/src/model/day_result.dart';
import 'package:geo_salah_core/src/model/engine_failure.dart';
import 'package:geo_salah_core/src/model/hijri_state.dart';
import 'package:geo_salah_core/src/model/horizon_elevation_policy.dart';
import 'package:geo_salah_core/src/model/observer.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';
import 'package:geo_salah_core/src/model/prayer_time.dart';
import 'package:geo_salah_core/src/model/provenance.dart';
import 'package:geo_salah_core/src/model/tz_database.dart';
import 'package:geo_salah_core/src/policy/adjustments.dart';
import 'package:geo_salah_core/src/policy/day_flags.dart';
import 'package:geo_salah_core/src/policy/event_finisher.dart';
import 'package:geo_salah_core/src/policy/ordering_guard.dart';
import 'package:geo_salah_core/src/rules/day_rule_solver.dart';
import 'package:geo_salah_core/src/rules/rule_solution.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';
import 'package:geo_salah_core/src/trace/calculation_id.dart';
import 'package:geo_salah_core/src/trace/calculation_inputs.dart';
import 'package:geo_salah_core/src/trace/calculation_trace_writer.dart';

/// The §6.4 pipeline for one prayer day, shared by `CalculateDay` and
/// `CalculateRange` (internal; not exported).
///
/// Steps, in order: elevation policy (ADR-003) → culmination segments
/// (ADR-004) → rules (¶6, interval rules on raw bases) → per-event offsets
/// (¶8) → rounding, last (¶9) → flags and confidence (REQ-DOM-050) →
/// ordering guard on displayed instants (¶10, REQ-DOM-001) → Calculation ID
/// (¶11). High-latitude fallbacks and Ramadan rule replacement join in S08.
///
/// An optional [SunSampleCache] lets a range reuse SPA samples between days;
/// it never changes a result (REQ-DOM-004). Pure and deterministic.
final class DayCalculation {
  /// The pipeline.
  const new();

  /// Last supported year (§15 D36).
  static const int lastYear = 5999;

  static const PerEventOffsets _offsets = PerEventOffsets();
  static const DayRuleSolver _rules = DayRuleSolver();
  static const DayFlags _flags = DayFlags();
  static const EventFinisher _finisher = EventFinisher();
  static const OrderingGuard _guard = OrderingGuard();
  static const CalculationTraceWriter _writer = CalculationTraceWriter();

  /// The prayer day [day] for [observer] under [profile]. Throws
  /// [ArgumentError] for a day after [lastYear].
  Result<DayResult, EngineFailure> calculate({
    required Observer observer,
    required PrayerProfile profile,
    required CivilDate day,
    required TzDatabase tzdb,
    required HijriState hijri,
    SunSampleCache? cache,
  }) {
    if (day.year > lastYear) {
      throw ArgumentError.value(day, 'day', 'after year $lastYear');
    }
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
    final inputs = CalculationInputs.of(
      observer: observer,
      profile: profile,
      day: day,
      hijri: hijri,
    );
    final segments = CulminationSegments.locate(
      day: day,
      site: TopocentricSite.of(
        latitudeDeg: inputs.latitudeDeg,
        longitudeDeg: inputs.longitudeDeg,
      ),
      zoneId: observer.zoneId,
      tzdb: tzdb,
      cache: cache,
    );
    if (segments == null) {
      return Result.ok(_dayResult(inputs, const [], const [], tzdb));
    }
    final solved = _rules.solve(
      profile.rules,
      segments: segments,
      latitudeDeg: inputs.latitudeDeg,
      dipDeg: dipDeg,
    );
    return switch (solved) {
      Err(:final failure) => Result.err(failure),
      Ok(value: final solutions) => _finish(
        solutions,
        observer: observer,
        profile: profile,
        inputs: inputs,
        tzdb: tzdb,
      ),
    };
  }

  Result<DayResult, EngineFailure> _finish(
    Map<PrayerEvent, RuleSolution> solutions, {
    required Observer observer,
    required PrayerProfile profile,
    required CalculationInputs inputs,
    required TzDatabase tzdb,
  }) {
    final dayFlags = _flags.of(observer: observer, day: inputs.day, tzdb: tzdb);
    final times = <PrayerTime>[];
    final steps = <AdjustmentStep>[];
    for (final MapEntry(key: event, value: solution) in solutions.entries) {
      final (:time, steps: eventSteps) = _finisher.finish(
        event,
        solution,
        profile: profile,
        day: inputs.day,
        zoneId: observer.zoneId,
        tzdb: tzdb,
        dayFlags: dayFlags,
      );
      times.add(time);
      steps.addAll(eventSteps);
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
