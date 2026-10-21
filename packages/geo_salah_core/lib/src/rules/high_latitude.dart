import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/high_latitude_method.dart';
import 'package:geo_salah_core/src/model/no_event_reason.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/rules/interval_rule_solver.dart';
import 'package:geo_salah_core/src/rules/perturbed_sites.dart';
import 'package:geo_salah_core/src/rules/rule_solution.dart';
import 'package:geo_salah_core/src/rules/solved_days.dart';

/// The high-latitude step (§6.4 ¶7, REQ-DOM-002, §15 D54): between the rule
/// step and the adjustments, each event §6.4 ¶7 gives a night — Imsak,
/// Fajr and Isha — whose rule has **no root** walks the profile's ordered
/// chain; the first method that yields an instant gives a [RuleFallback],
/// and an exhausted chain gives `NoEvent(chainExhausted)`. An event with a
/// root never falls back, and an empty chain leaves the rule's reason.
///
/// Nights are in UTC: for Fajr(D) and Imsak(D) from sunset(D−1) to
/// sunrise(D), for Isha(D) from sunset(D) to sunrise(D+1), bounded by the
/// raw instants of the profile's own Sunrise and Maghrib rules. The methods
/// are profile data (§0.2 rule 1); their definitions are §6.2's:
/// - `anglePortion`: α/60 of the night, α the event's `solarAltitude`
///   degrees (skipped for any other rule);
/// - `middleOfNight`: half the night; `seventhOfNight`: a seventh of it;
///   each measured back from sunrise for Imsak/Fajr and on from sunset for
///   Isha, and skipped when the night has no sunset or sunrise;
/// - `nearestLatitude(latDeg)`: the event's rule at latitude `±latDeg` (the
///   observer's hemisphere), same longitude, zone and day;
/// - `nearestValidDay(maxDays)`: the event's rule on the nearest day within
///   `maxDays` that has a root (D−1, D+1, D−2, …), kept at the same
///   distance from the upper transit `T₀` on day D.
///
/// An interval rule whose base took a fallback follows it (§15 D42, D54).
/// Each fallback's ±1 km sensitivity (§6.7) is the largest change of the
/// event's instant when the whole step is repeated 1 km north, south, east
/// and west, rounded up to whole minutes (§15 D55). Instants are truncated
/// to 1 ms. Pure and deterministic.
final class HighLatitudeChain {
  /// The step.
  const new();

  /// The events §6.4 ¶7 gives a night: the only ones the chain resolves.
  static const Set<PrayerEvent> events = {
    PrayerEvent.imsak,
    PrayerEvent.fajr,
    PrayerEvent.isha,
  };

  static const IntervalRuleSolver _interval = IntervalRuleSolver();
  static const PerturbedSites _perturbed = PerturbedSites();
  static const int _minuteMs = 60000;

  /// The trace reason of [fallback] (§15 D54): `highLatitude.<method>`, and
  /// `highLatitude.<method>.via.<base>` for an interval on a fallback base.
  static String reasonOf(RuleFallback fallback) {
    final method = switch (fallback.method) {
      AnglePortion() => 'anglePortion',
      MiddleOfNight() => 'middleOfNight',
      SeventhOfNight() => 'seventhOfNight',
      NearestLatitude() => 'nearestLatitude',
      NearestValidDay() => 'nearestValidDay',
    };
    return switch (fallback.base) {
      null => 'highLatitude.$method',
      final PrayerEvent base => 'highLatitude.$method.via.${base.name}',
    };
  }

  /// [solutions], the rule step on [day] at [site] under [rules] with
  /// [dipDeg] of dip, with the events without a root resolved by [chain].
  /// [days] solves the other days and sites.
  Map<PrayerEvent, RuleSolution> apply(
    Map<PrayerEvent, RuleSolution> solutions, {
    required Map<PrayerEvent, EventRule> rules,
    required List<HighLatitudeMethod> chain,
    required CivilDate day,
    required TopocentricSite site,
    required double dipDeg,
    required SolvedDays days,
  }) {
    if (chain.isEmpty ||
        !events.any((event) => solutions[event] is RuleNoRoot)) {
      return solutions;
    }
    final context = (
      rules: rules,
      chain: chain,
      day: day,
      dipDeg: dipDeg,
      days: days,
    );
    final resolved = _resolve(solutions, site, context);
    if (!resolved.values.any((solution) => solution is RuleFallback)) {
      return resolved;
    }
    final perturbed = [
      for (final other in _perturbed.of(site))
        if (_at(context, day, other) case final SolvedDay solved)
          _resolve(solved.solutions, other, context),
    ];
    return Map.unmodifiable({
      for (final MapEntry(key: event, value: solution) in resolved.entries)
        event: switch (solution) {
          RuleFallback(:final utcMs, :final method, :final base) =>
            RuleFallback(
              utcMs,
              method,
              base: base,
              perturbationMinutes: _sensitivityMinutes(utcMs, [
                for (final other in perturbed) other[event],
              ]),
            ),
          RuleRoot() || RuleNoRoot() => solution,
        },
    });
  }

  /// The step at [site]: fallbacks for the events without a root, then the
  /// intervals on fallback bases.
  static Map<PrayerEvent, RuleSolution> _resolve(
    Map<PrayerEvent, RuleSolution> solutions,
    TopocentricSite site,
    _Context context,
  ) {
    final resolved = {...solutions};
    for (final event in PrayerEvent.values) {
      final rule = context.rules[event];
      if (rule == null || IntervalRuleSolver.intervalOf(rule) != null) {
        continue;
      }
      if (events.contains(event) && resolved[event] is RuleNoRoot) {
        resolved[event] = _fallback(event, rule, site, context);
      }
    }
    for (final event in PrayerEvent.values) {
      final rule = context.rules[event];
      final interval = rule == null
          ? null
          : IntervalRuleSolver.intervalOf(rule);
      if (rule == null || interval == null) continue;
      final (:base, :offset) = interval;
      final baseSolution = resolved[base];
      if (baseSolution is RuleFallback) {
        resolved[event] = _interval.solve(
          baseSolution,
          offset,
          baseEvent: base,
        );
      } else if (events.contains(event) && resolved[event] is RuleNoRoot) {
        resolved[event] = _fallback(event, rule, site, context);
      }
    }
    return resolved;
  }

  /// The first link of the chain that yields an instant for [event], or
  /// `NoEvent(chainExhausted)`.
  static RuleSolution _fallback(
    PrayerEvent event,
    EventRule rule,
    TopocentricSite site,
    _Context context,
  ) {
    for (final method in context.chain) {
      final utcMs = switch ((method, rule)) {
        (AnglePortion(), SolarAltitudeRule(:final degrees)) => _portionOfNight(
          event,
          degrees / 60,
          site,
          context,
        ),
        (AnglePortion(), _) => null,
        (MiddleOfNight(), _) => _portionOfNight(event, 1 / 2, site, context),
        (SeventhOfNight(), _) => _portionOfNight(event, 1 / 7, site, context),
        (NearestLatitude(:final latDeg), _) => _atLatitude(
          event,
          site.latitudeDeg < 0 ? -latDeg : latDeg,
          site,
          context,
        ),
        (NearestValidDay(:final maxDays), _) => _onNearestDay(
          event,
          maxDays,
          site,
          context,
        ),
      };
      if (utcMs != null) return RuleFallback(utcMs, method);
    }
    return const RuleNoRoot(NoEventReason.chainExhausted);
  }

  /// [fraction] of [event]'s night: back from sunrise for Imsak and Fajr,
  /// on from sunset for Isha; `null` without a night. The prayer day's own
  /// bound is read first, so a neighbouring day is solved only when that
  /// bound exists.
  static int? _portionOfNight(
    PrayerEvent event,
    double fraction,
    TopocentricSite site,
    _Context context,
  ) {
    final day = context.day;
    final fromSunrise = switch (event) {
      PrayerEvent.imsak || PrayerEvent.fajr => true,
      PrayerEvent.isha => false,
      // §6.4 ¶7 gives no other event a night.
      PrayerEvent.sunrise ||
      PrayerEvent.dhuhr ||
      PrayerEvent.asr ||
      PrayerEvent.maghrib => throw ArgumentError.value(event, 'event'),
    };
    final (ownBound, otherDay, otherBound) = fromSunrise
        ? (PrayerEvent.sunrise, day.plusDays(-1), PrayerEvent.maghrib)
        : (PrayerEvent.maghrib, day.plusDays(1), PrayerEvent.sunrise);
    if (_at(context, day, site)?.solutions[ownBound] case RuleRoot(
      utcMs: final own,
    )) {
      if (_at(context, otherDay, site)?.solutions[otherBound] case RuleRoot(
        utcMs: final other,
      )) {
        // own − other is the night for Fajr; other − own for Isha.
        final night = (own - other).abs();
        return fromSunrise
            ? (own - fraction * night).floor()
            : (own + fraction * night).floor();
      }
    }
    return null;
  }

  /// [event]'s rule root at latitude [latitudeDeg], [site]'s longitude.
  static int? _atLatitude(
    PrayerEvent event,
    double latitudeDeg,
    TopocentricSite site,
    _Context context,
  ) {
    final other = TopocentricSite.of(
      latitudeDeg: latitudeDeg,
      longitudeDeg: site.longitudeDeg,
    );
    return switch (_at(context, context.day, other)?.solutions[event]) {
      RuleRoot(:final utcMs) => utcMs,
      RuleFallback() || RuleNoRoot() || null => null,
    };
  }

  /// [event]'s rule root on the nearest day within [maxDays] that has one,
  /// moved to day D at the same distance from the upper transit.
  static int? _onNearestDay(
    PrayerEvent event,
    int maxDays,
    TopocentricSite site,
    _Context context,
  ) {
    final day = context.day;
    final here = _at(context, day, site);
    if (here == null) return null;
    for (var distance = 1; distance <= maxDays; distance++) {
      for (final other in [day.plusDays(-distance), day.plusDays(distance)]) {
        if (_at(context, other, site) case (
          :final segments,
          :final solutions,
        )) {
          if (solutions[event] case RuleRoot(:final utcMs)) {
            return (here.segments.upperUtcMs + (utcMs - segments.upperUtcMs))
                .floor();
          }
        }
      }
    }
    return null;
  }

  /// The largest change of [utcMs] among [perturbed] (the event's solution
  /// at each perturbed site), rounded up to whole minutes; sites where the
  /// event has no instant are left out.
  static int _sensitivityMinutes(int utcMs, List<RuleSolution?> perturbed) {
    var largest = 0;
    for (final solution in perturbed) {
      final instant = switch (solution) {
        RuleRoot(utcMs: final other) ||
        RuleFallback(utcMs: final other) => other,
        RuleNoRoot() || null => null,
      };
      if (instant == null) continue;
      final change = (instant - utcMs).abs();
      if (change > largest) largest = change;
    }
    return (largest + _minuteMs - 1) ~/ _minuteMs;
  }
}

/// What every method of one calculation reads.
typedef _Context = ({
  Map<PrayerEvent, EventRule> rules,
  List<HighLatitudeMethod> chain,
  CivilDate day,
  double dipDeg,
  SolvedDays days,
});

/// [day] solved at [site] with the rules and dip of [context].
SolvedDay? _at(_Context context, CivilDate day, TopocentricSite site) =>
    context.days.at(
      day,
      site,
      rules: context.rules,
      dipDeg: context.dipDeg,
    );
