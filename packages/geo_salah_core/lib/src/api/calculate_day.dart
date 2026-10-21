import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/api/day_calculation.dart';
import 'package:geo_salah_core/src/model/day_result.dart';
import 'package:geo_salah_core/src/model/engine_failure.dart';
import 'package:geo_salah_core/src/model/hijri_state.dart';
import 'package:geo_salah_core/src/model/observer.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';
import 'package:geo_salah_core/src/model/tz_database.dart';

/// Calculates one prayer day (§6.3 `calculateDay`, §6.4).
///
/// The day is bounded by solar culmination segments (ADR-004,
/// REQ-TIME-002). Each event of `profile.rules` is solved by its rule — the
/// transit, horizon, solar-altitude, shadow-factor or interval rule — at the
/// observer's coordinates rounded to 6 decimals (§15 D38). An event without
/// a root is `NoEvent` with a typed reason, never a fallback where a root
/// exists (REQ-DOM-002). Raw instants are truncated to 1 ms (REQ-DOM-004).
///
/// Then the profile's per-event offsets apply and each event is rounded to
/// its displayed local minute, once and last (ADR-005, REQ-DOM-003), with
/// the `nearRoundingBoundary` flag and an adjustment trace. Labels follow
/// the fixed §6.2 mapping (REQ-DOM-050), and the displayed instants must
/// keep the prayer order (REQ-DOM-001) or the day is
/// `EngineFailure.orderingViolation` carrying its trace.
///
/// **Domain** (§15 D36): days in years 1–[lastYear]; a later day throws
/// [ArgumentError], a precondition the caller checks (the ephemeris is valid
/// to 6000). A calendar day the zone skipped has no upper transit and yields
/// a [DayResult] without times.
///
/// **Failures** (REQ-ERR-001): `unsupportedPolicy` for a `[DEFERRED V2]`
/// elevation policy (ADR-003), `invalidProfile` for a rule the event cannot
/// use or an offset beyond `maxAbsMinutes`, `orderingViolation` as above.
/// No I/O, clock or randomness (REQ-DOM-020): equal arguments give equal
/// results.
final class CalculateDay {
  /// The use case.
  const new();

  /// Last supported year.
  static const int lastYear = DayCalculation.lastYear;

  static const DayCalculation _day = DayCalculation();

  /// The prayer day [day] for [observer] under [profile].
  Result<DayResult, EngineFailure> call({
    required Observer observer,
    required PrayerProfile profile,
    required CivilDate day,
    required TzDatabase tzdb,
    required HijriState hijri,
  }) => _day.calculate(
    observer: observer,
    profile: profile,
    day: day,
    tzdb: tzdb,
    hijri: hijri,
  );
}
