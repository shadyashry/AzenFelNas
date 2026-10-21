import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/astro/delta_t.dart';
import 'package:geo_salah_core/src/astro/exact_sun.dart';
import 'package:geo_salah_core/src/astro/solar_day_model.dart';
import 'package:geo_salah_core/src/astro/sun_sample_cache.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:geo_salah_core/src/model/tz_database.dart';
import 'package:geo_salah_core/src/solver/monotone_pieces.dart';
import 'package:meta/meta.dart';

/// The prayer day `D` as solar culmination segments (ADR-004, REQ-TIME-002).
///
/// `T₀` is the upper transit whose local date in the observer's zone is `D`.
/// `A₋ < T₀ < A₊` are the adjacent lower transits. Ascending events are
/// searched in `[A₋, T₀]` ([ascending]), descending ones in `[T₀, A₊]`
/// ([descending]). Consecutive days tile time: `A₊(D) = A₋(D + 1)` up to
/// the solver's precision. Transits exist every day at every latitude, polar
/// day and night included.
///
/// Instants are UTC epoch milliseconds, not truncated (the solver truncates
/// event instants). Immutable and deterministic.
@immutable
final class CulminationSegments {
  const new _({
    required this.day,
    required this.lowerBeforeUtcMs,
    required this.upperUtcMs,
    required this.upperDeclinationDeg,
    required this.lowerAfterUtcMs,
    required this.ascending,
    required this.descending,
  });

  /// The segments around [upper], the transit `T₀` found on [model].
  factory _build(CivilDate day, SolarDayModel model, double upper) {
    const halfDay = _msPerDay / 2;
    final lowerBefore = model.instantOfHourAngle(
      180,
      guessUtcMs: upper - halfDay,
    );
    final lowerAfter = model.instantOfHourAngle(
      180,
      guessUtcMs: upper + halfDay,
    );
    return CulminationSegments._(
      day: day,
      lowerBeforeUtcMs: lowerBefore,
      upperUtcMs: upper,
      upperDeclinationDeg: model.declinationDeg(upper),
      lowerAfterUtcMs: lowerAfter,
      ascending: MonotonePieces.of(model, startMs: lowerBefore, endMs: upper),
      descending: MonotonePieces.of(model, startMs: upper, endMs: lowerAfter),
    );
  }

  static const int _msPerDay = 86400000;

  /// The segments of [day] for [site] in [zoneId], or `null` when no upper
  /// transit has local date [day] — a calendar day the zone skipped, such as
  /// 2011-12-30 in `Pacific/Apia`.
  ///
  /// The search starts at mean solar noon of [day] at the site's longitude,
  /// finds the nearest transit and moves by whole days until its local date
  /// is [day]. Each try builds one [SolarDayModel] anchored there (five SPA
  /// evaluations, fewer when [cache] already holds some of them), and the
  /// transits are refined with exact SPA steps. [cache] never changes the
  /// result.
  static CulminationSegments? locate({
    required CivilDate day,
    required TopocentricSite site,
    required String zoneId,
    required TzDatabase tzdb,
    EspenakMeeusDeltaT deltaT = const EspenakMeeusDeltaT(),
    SunSampleCache? cache,
  }) {
    final exact = ExactSun(site, deltaT: deltaT);
    var anchor =
        day.epochDay * _msPerDay +
        _msPerDay / 2 -
        site.longitudeDeg / 360 * _msPerDay;
    int? previousShift;
    for (var attempt = 0; attempt < 3; attempt++) {
      final model = SolarDayModel.around(
        exact,
        anchorUtcMs: anchor,
        cache: cache,
      );
      final upper = model.instantOfHourAngle(0, guessUtcMs: anchor);
      final shift = _localEpochDay(upper, zoneId, tzdb) - day.epochDay;
      if (shift == 0) return CulminationSegments._build(day, model, upper);
      if (previousShift != null && shift.sign != previousShift.sign) {
        return null;
      }
      previousShift = shift;
      anchor -= shift * _msPerDay;
    }
    return null;
  }

  static int _localEpochDay(double utcMs, String zoneId, TzDatabase tzdb) {
    final instant = utcMs.floor();
    final local = instant + tzdb.offsetSecondsAt(zoneId, instant) * 1000;
    return (local / _msPerDay).floor();
  }

  /// The prayer day `D`.
  final CivilDate day;

  /// The lower transit `A₋` before [upperUtcMs].
  final double lowerBeforeUtcMs;

  /// The upper transit `T₀` (local date [day]).
  final double upperUtcMs;

  /// The Sun's geocentric declination `δ(T₀)` at [upperUtcMs], degrees
  /// (interpolated, §6.4 ¶2): the noon declination of the Asr rule (§6.4 ¶6).
  final double upperDeclinationDeg;

  /// The lower transit `A₊` after [upperUtcMs].
  final double lowerAfterUtcMs;

  /// `[A₋, T₀]` split into monotone pieces: the ascending events' search
  /// space.
  final MonotonePieces ascending;

  /// `[T₀, A₊]` split into monotone pieces: the descending events' search
  /// space.
  final MonotonePieces descending;
}
