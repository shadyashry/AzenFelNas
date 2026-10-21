import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/api/engine_version.dart';
import 'package:geo_salah_core/src/astro/delta_t.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:geo_salah_core/src/model/confidence_label.dart';
import 'package:geo_salah_core/src/model/day_result.dart';
import 'package:geo_salah_core/src/model/engine_failure.dart';
import 'package:geo_salah_core/src/model/event_origin.dart';
import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/hijri_state.dart';
import 'package:geo_salah_core/src/model/horizon_elevation_policy.dart';
import 'package:geo_salah_core/src/model/observer.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';
import 'package:geo_salah_core/src/model/prayer_time.dart';
import 'package:geo_salah_core/src/model/provenance.dart';
import 'package:geo_salah_core/src/model/tz_database.dart';
import 'package:geo_salah_core/src/rules/horizon_rule_solver.dart';
import 'package:geo_salah_core/src/rules/rule_solution.dart';
import 'package:geo_salah_core/src/rules/transit_rule_solver.dart';
import 'package:geo_salah_core/src/solver/crossing_direction.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';
import 'package:geo_salah_core/src/trace/calculation_id.dart';
import 'package:geo_salah_core/src/trace/calculation_inputs.dart';

/// Calculates one prayer day (§6.3 `calculateDay`, §6.4).
///
/// The day is bounded by solar culmination segments (ADR-004,
/// REQ-TIME-002). Each event of `profile.rules` is solved by its rule —
/// Dhuhr by [TransitRule], Sunrise and Maghrib by [HorizonRule] — at the
/// observer's coordinates rounded to 6 decimals (§15 D38). An event without
/// a root is `NoEvent` with a typed reason, never a fallback where a root
/// exists (REQ-DOM-002). Raw instants are truncated to 1 ms (REQ-DOM-004).
///
/// Slice S05 scope: no adjustments, rounding, flags or ordering guard yet
/// (S06), so `displayedUtcMs == rawUtcMs`; a primary time is `Calculated`
/// and a missing one `Unknown(reason)` — the two §6.2 confidence rows an
/// `engine.default` profile reaches (§15 D39).
///
/// **Domain** (§15 D36): days in years 1–[lastYear]; a later day throws
/// [ArgumentError], a precondition the caller checks (the ephemeris is valid
/// to 6000). A calendar day the zone skipped has no upper transit and yields
/// a [DayResult] without times.
///
/// **Failures** (REQ-ERR-001): `unsupportedPolicy` for a `[DEFERRED V2]`
/// elevation policy (ADR-003), `invalidProfile` for a rule the event cannot
/// use. No I/O, clock or randomness (REQ-DOM-020): equal arguments give
/// equal results.
final class CalculateDay {
  /// The use case.
  const new();

  /// Last supported year.
  static const int lastYear = 5999;

  static const TransitRuleSolver _transit = TransitRuleSolver();
  static const HorizonRuleSolver _horizon = HorizonRuleSolver();

  /// The prayer day [day] for [observer] under [profile].
  Result<DayResult, EngineFailure> call({
    required Observer observer,
    required PrayerProfile profile,
    required CivilDate day,
    required TzDatabase tzdb,
    required HijriState hijri,
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
    );
    final times = segments == null
        ? const Result<List<PrayerTime>, EngineFailure>.ok([])
        : _times(profile, segments, dipDeg, observer.zoneId, tzdb);
    return times.map((times) => _dayResult(inputs, times, tzdb));
  }

  /// The profile's events on the day of [segments], in [PrayerEvent] order.
  Result<List<PrayerTime>, EngineFailure> _times(
    PrayerProfile profile,
    CulminationSegments segments,
    double dipDeg,
    String zoneId,
    TzDatabase tzdb,
  ) {
    final times = <PrayerTime>[];
    for (final event in PrayerEvent.values) {
      final rule = profile.rules[event];
      if (rule == null) continue;
      switch (_solve(event, rule, segments, dipDeg)) {
        case Err(:final failure):
          return Result.err(failure);
        case Ok(value: final solution):
          times.add(_timeOf(event, solution, segments.day, zoneId, tzdb));
      }
    }
    return Result.ok(List.unmodifiable(times));
  }

  Result<RuleSolution, EngineFailure> _solve(
    PrayerEvent event,
    EventRule rule,
    CulminationSegments segments,
    double dipDeg,
  ) => switch ((rule, _directionOf(event))) {
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
    (TransitRule(), CrossingDirection()) || (HorizonRule(), null) => Result.err(
      EngineFailure.invalidProfile(
        'rule ${rule.runtimeType} cannot define ${event.name}',
      ),
    ),
  };

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

  static PrayerTime _timeOf(
    PrayerEvent event,
    RuleSolution solution,
    CivilDate day,
    String zoneId,
    TzDatabase tzdb,
  ) => switch (solution) {
    RuleRoot(:final utcMs) => PrayerTime.timed(
      event: event,
      rawUtcMs: utcMs,
      displayedUtcMs: utcMs,
      dayOffset: _localEpochDay(utcMs, zoneId, tzdb) - day.epochDay,
      origin: const EventOrigin.primary(),
      confidence: const ConfidenceLabel.calculated(),
    ),
    RuleNoRoot(:final reason) => PrayerTime.noEvent(
      event: event,
      reason: reason,
      confidence: ConfidenceLabel.unknown(reasonCode: reason.code),
    ),
  };

  static int _localEpochDay(int utcMs, String zoneId, TzDatabase tzdb) {
    final localMs = utcMs + tzdb.offsetSecondsAt(zoneId, utcMs) * 1000;
    return (localMs / Duration.millisecondsPerDay).floor();
  }

  static DayResult _dayResult(
    CalculationInputs inputs,
    List<PrayerTime> times,
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
      times: times,
      provenance: Provenance(
        engineVersion: EngineVersion.current,
        deltaTModel: EspenakMeeusDeltaT.modelId,
        profileId: inputs.profileId,
        profileVersion: inputs.profileVersion,
        tzdbVersion: tzdb.version,
        inputsHash: inputsHash,
        hijriConfidence: inputs.hijri.confidence,
        adjustmentTrace: const [],
      ),
    );
  }
}
