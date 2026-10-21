import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/astro/sun_sample_cache.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:geo_salah_core/src/model/engine_failure.dart';
import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/model/tz_database.dart';
import 'package:geo_salah_core/src/rules/day_rule_solver.dart';
import 'package:geo_salah_core/src/rules/rule_solution.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';

/// One prayer day at one site: its culmination segments (ADR-004) and the
/// rule step's solution of every event (§6.4 ¶6).
typedef SolvedDay = ({
  CulminationSegments segments,
  Map<PrayerEvent, RuleSolution> solutions,
});

/// The rule step on any day at any site, memoised for one `calculateDay`
/// or `calculateRange` call: the prayer day itself, and what the
/// high-latitude chain reads (§6.4 ¶7) — the nights of the neighbouring
/// days, the event at the nearest latitude or on the nearest valid day, and
/// the ±1 km perturbed sites (§6.7).
///
/// Every day is located in the observer's zone [zoneId] with [tzdb]. A
/// solution is a pure function of its day, site, rules and dip, so a
/// memoised value is identical to a fresh one and the memo changes speed,
/// never a result (REQ-DOM-004); a range shares it so that one day's
/// neighbour is the next day's prayer day. Rules are keyed by identity: the
/// same map object, as a profile's rules are on every day without a Ramadan
/// replacement. [cache] shares SPA samples. The memo lives for one call
/// only (§17.2: no state outlives a call).
final class SolvedDays {
  /// An empty memo for days in [zoneId].
  new({required this.zoneId, required this.tzdb, required this.cache});

  static const DayRuleSolver _solver = DayRuleSolver();

  /// The observer's zone; it fixes which transit belongs to which day.
  final String zoneId;

  /// The time-zone port.
  final TzDatabase tzdb;

  /// SPA samples shared by every day of the call.
  final SunSampleCache cache;

  final Map<_Key, SolvedDay?> _solved = {};

  /// [day] solved at [site] with [rules] and [dipDeg] degrees of dip:
  /// `Ok(null)` when the zone skipped [day] (§15 D36), the rule step's
  /// failure when [rules] are invalid (never memoised).
  Result<SolvedDay?, EngineFailure> solve(
    CivilDate day,
    TopocentricSite site, {
    required Map<PrayerEvent, EventRule> rules,
    required double dipDeg,
  }) {
    final key = (
      rules: rules,
      dipDeg: dipDeg,
      epochDay: day.epochDay,
      latitudeDeg: site.latitudeDeg,
      longitudeDeg: site.longitudeDeg,
    );
    if (_solved.containsKey(key)) return Result.ok(_solved[key]);
    final segments = CulminationSegments.locate(
      day: day,
      site: site,
      zoneId: zoneId,
      tzdb: tzdb,
      cache: cache,
    );
    if (segments == null) {
      _solved[key] = null;
      return const Result.ok(null);
    }
    final solved = _solver.solve(
      rules,
      segments: segments,
      latitudeDeg: site.latitudeDeg,
      dipDeg: dipDeg,
    );
    switch (solved) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(value: final solutions):
        final day = (segments: segments, solutions: solutions);
        _solved[key] = day;
        return Result.ok(day);
    }
  }

  /// [day] solved at [site] with [rules] that already solved on the prayer
  /// day, or `null` when the zone skipped [day].
  SolvedDay? at(
    CivilDate day,
    TopocentricSite site, {
    required Map<PrayerEvent, EventRule> rules,
    required double dipDeg,
  }) => switch (solve(day, site, rules: rules, dipDeg: dipDeg)) {
    Ok(:final value) => value,
    // Unreachable: whether rules are valid depends neither on the day nor
    // on the site, and these solved on the prayer day first.
    Err(:final failure) => throw StateError(
      'Rules valid on the prayer day failed on $day: ${failure.detail}',
    ),
  };
}

typedef _Key = ({
  Map<PrayerEvent, EventRule> rules,
  double dipDeg,
  int epochDay,
  double latitudeDeg,
  double longitudeDeg,
});
