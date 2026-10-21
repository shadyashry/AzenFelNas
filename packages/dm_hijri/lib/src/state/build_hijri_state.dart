import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_hijri/src/calendar/tabular_hijri_calendar.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// Builds the [HijriState] of prayer day `D` from the ADR-016 tabular
/// calendar (§6.2, §9.5).
///
/// A Hijri day begins at Maghrib, so `dateAtDawn = hijri(D)` governs Imsak
/// and Fajr and `dateAtNight = hijri(D + 1)` governs Isha (§6.4 ¶6). The
/// user's ±1-day correction (`settings.hijriOverrideDays`, Appendix K) is
/// applied first, as §9.5 requires: both dates are read that many days
/// later.
///
/// The state is labelled `expected` (ADR-016: the tabular fallback is never
/// `confirmed`), or `userOverride` when the override is not 0; it carries
/// no package version. Confirmed month starts from the `hijri` package are
/// read by the package client (§15 D57). Pure and deterministic.
final class BuildHijriState {
  /// The use case.
  const new();

  static const TabularHijriCalendar _calendar = TabularHijriCalendar();

  /// The Hijri state of prayer day [day], shifted by [overrideDays] ∈
  /// {−1, 0, 1}.
  ///
  /// Throws [RangeError] for another override or for a day before
  /// 1 Muharram 1 AH.
  HijriState call({required CivilDate day, int overrideDays = 0}) {
    RangeError.checkValueInInterval(overrideDays, -1, 1, 'overrideDays');
    final dawn = CivilDate.fromEpochDay(day.epochDay + overrideDays);
    return HijriState(
      dateAtDawn: _calendar.fromCivil(dawn),
      dateAtNight: _calendar.fromCivil(
        CivilDate.fromEpochDay(dawn.epochDay + 1),
      ),
      confidence: overrideDays == 0
          ? HijriConfidence.expected
          : HijriConfidence.userOverride,
    );
  }
}
