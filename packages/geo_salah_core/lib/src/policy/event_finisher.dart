import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/model/adjustment_kind.dart';
import 'package:geo_salah_core/src/model/adjustment_step.dart';
import 'package:geo_salah_core/src/model/event_origin.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';
import 'package:geo_salah_core/src/model/prayer_time.dart';
import 'package:geo_salah_core/src/model/result_flag.dart';
import 'package:geo_salah_core/src/model/rounding_mode.dart';
import 'package:geo_salah_core/src/model/tz_database.dart';
import 'package:geo_salah_core/src/policy/confidence_mapper.dart';
import 'package:geo_salah_core/src/policy/rounding.dart';
import 'package:geo_salah_core/src/rules/rule_solution.dart';

/// A finished event: its time and the adjustment steps that produced its
/// displayed instant, in order.
typedef FinishedEvent = ({PrayerTime time, List<AdjustmentStep> steps});

/// Turns one event's solution into its [PrayerTime] (§6.4 ¶8–¶9): the
/// per-event offset (`perEventOffset` step, only when non-zero), then
/// rounding as the last step (one `rounding` step per timed event, also when
/// it moves nothing, REQ-DOM-003), then the day's flags, the event's own
/// flags, `nearRoundingBoundary`, `highLatitudeFallback` for a fallback, and
/// the confidence label (REQ-DOM-050).
///
/// A [RuleRoot] is `primary`; a [RuleFallback] is `fallback(method)`,
/// labelled `estimated` with its ±1 km sensitivity (§15 D55); a
/// [RuleNoRoot] is `noEvent(reason)`. `rawUtcMs` stays the instant before
/// the adjustments; `dayOffset` is the local date of the displayed instant
/// minus the prayer day. Step reasons are stable codes (§15 D43). Pure and
/// deterministic.
final class EventFinisher {
  /// The finisher.
  const new();

  static const PerEventRounding _rounding = PerEventRounding();
  static const ConfidenceMapper _confidence = ConfidenceMapper();
  static const int _minuteMs = 60000;
  static const int _msPerDay = 86400000;

  /// The time of [event] from [solution] on [day] under [profile], local
  /// time from [tzdb] in [zoneId], with the day-level [dayFlags] and the
  /// event's own [eventFlags].
  FinishedEvent finish(
    PrayerEvent event,
    RuleSolution solution, {
    required PrayerProfile profile,
    required CivilDate day,
    required String zoneId,
    required TzDatabase tzdb,
    required Set<ResultFlag> dayFlags,
    Set<ResultFlag> eventFlags = const {},
  }) {
    final flags = {...dayFlags, ...eventFlags};
    switch (solution) {
      case RuleNoRoot(:final reason):
        final origin = EventOrigin.noEvent(reason);
        return (
          time: PrayerTime.noEvent(
            event: event,
            reason: reason,
            confidence: _confidence.labelOf(
              origin,
              profile,
              perturbationMinutes: 0,
            ),
            flags: flags,
          ),
          steps: const [],
        );
      case RuleRoot(:final utcMs):
        return _timed(
          event,
          utcMs,
          const EventOrigin.primary(),
          perturbationMinutes: 0,
          flags: flags,
          profile: profile,
          day: day,
          zoneId: zoneId,
          tzdb: tzdb,
        );
      case RuleFallback(
        :final utcMs,
        :final method,
        :final perturbationMinutes,
      ):
        return _timed(
          event,
          utcMs,
          EventOrigin.fallback(method),
          perturbationMinutes: perturbationMinutes,
          flags: {...flags, ResultFlag.highLatitudeFallback},
          profile: profile,
          day: day,
          zoneId: zoneId,
          tzdb: tzdb,
        );
    }
  }

  static FinishedEvent _timed(
    PrayerEvent event,
    int raw,
    EventOrigin origin, {
    required int perturbationMinutes,
    required Set<ResultFlag> flags,
    required PrayerProfile profile,
    required CivilDate day,
    required String zoneId,
    required TzDatabase tzdb,
  }) {
    final minutes = profile.perEventMinutes[event] ?? 0;
    final adjusted = raw + minutes * _minuteMs;
    final mode = profile.roundingOverrides[event] ?? profile.roundingDefault;
    final rounded = _rounding.round(
      adjusted,
      mode,
      offsetSeconds: tzdb.offsetSecondsAt(zoneId, adjusted),
    );
    final displayed = rounded.displayedUtcMs;
    return (
      time: PrayerTime.timed(
        event: event,
        rawUtcMs: raw,
        displayedUtcMs: displayed,
        dayOffset: _localEpochDay(displayed, zoneId, tzdb) - day.epochDay,
        origin: origin,
        confidence: _confidence.labelOf(
          origin,
          profile,
          perturbationMinutes: perturbationMinutes,
        ),
        flags: {
          ...flags,
          if (rounded.nearBoundary) ResultFlag.nearRoundingBoundary,
        },
      ),
      steps: List.unmodifiable([
        if (minutes != 0)
          AdjustmentStep(
            event: event,
            kind: AdjustmentKind.perEventOffset,
            deltaMs: adjusted - raw,
            reason: 'adjustments.perEventMinutes',
          ),
        AdjustmentStep(
          event: event,
          kind: AdjustmentKind.rounding,
          deltaMs: displayed - adjusted,
          reason: _roundingReason(mode),
        ),
      ]),
    );
  }

  static String _roundingReason(RoundingMode mode) => switch (mode) {
    RoundingMode.ceil => 'rounding.ceil',
    RoundingMode.floor => 'rounding.floor',
    RoundingMode.nearest => 'rounding.nearest',
  };

  static int _localEpochDay(int utcMs, String zoneId, TzDatabase tzdb) {
    final localMs = utcMs + tzdb.offsetSecondsAt(zoneId, utcMs) * 1000;
    return (localMs / _msPerDay).floor();
  }
}
