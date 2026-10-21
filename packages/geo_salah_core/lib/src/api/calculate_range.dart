import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/api/day_calculation.dart';
import 'package:geo_salah_core/src/astro/sun_sample_cache.dart';
import 'package:geo_salah_core/src/model/day_result.dart';
import 'package:geo_salah_core/src/model/engine_failure.dart';
import 'package:geo_salah_core/src/model/hijri_state.dart';
import 'package:geo_salah_core/src/model/observer.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';
import 'package:geo_salah_core/src/model/tz_database.dart';

/// Calculates consecutive prayer days (§6.3 `calculateRange`, §6.4 ¶2,
/// REQ-PERF-001).
///
/// Day `from + i` for `i` in `0 … days − 1`, each exactly as `CalculateDay`
/// calculates it with the Hijri state `hijriFor(day)`: a range returns the
/// same `DayResult`s, bit for bit, as the days calculated one by one
/// (REQ-DOM-004). The range only shares SPA samples between neighbouring
/// days through a per-call [SunSampleCache] (three of a day's five samples
/// are the next day's), which saves work and changes no value.
///
/// **Domain**: `1 ≤ days ≤ 400` (§6.3) and every day within years
/// 1–`CalculateDay.lastYear`; otherwise [ArgumentError], a precondition like
/// `CalculateDay`'s (§15 D47).
///
/// **Failures**: the first day that fails ends the range with that day's
/// [EngineFailure] (REQ-ERR-001). No I/O, clock or randomness
/// (REQ-DOM-020).
final class CalculateRange {
  /// The use case.
  const new();

  /// Most days one call calculates (§6.3).
  static const int maxDays = 400;

  static const DayCalculation _day = DayCalculation();

  /// The [days] prayer days from [from] for [observer] under [profile].
  Result<List<DayResult>, EngineFailure> call({
    required Observer observer,
    required PrayerProfile profile,
    required CivilDate from,
    required int days,
    required TzDatabase tzdb,
    required HijriState Function(CivilDate) hijriFor,
  }) {
    if (days < 1 || days > maxDays) {
      throw RangeError.range(days, 1, maxDays, 'days');
    }
    final last = CivilDate.fromEpochDay(from.epochDay + days - 1);
    if (last.year > DayCalculation.lastYear) {
      throw ArgumentError.value(
        last,
        'from',
        'range ends after year ${DayCalculation.lastYear}',
      );
    }
    final cache = SunSampleCache();
    final results = <DayResult>[];
    for (var i = 0; i < days; i++) {
      final day = CivilDate.fromEpochDay(from.epochDay + i);
      final result = _day.calculate(
        observer: observer,
        profile: profile,
        day: day,
        tzdb: tzdb,
        hijri: hijriFor(day),
        cache: cache,
      );
      switch (result) {
        case Err(:final failure):
          return Result.err(failure);
        case Ok(:final value):
          results.add(value);
      }
    }
    return Result.ok(List.unmodifiable(results));
  }
}
