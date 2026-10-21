import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// The tabular ("Kuwaiti") Islamic calendar of ADR-016: the fallback used
/// until a month start is confirmed by the `hijri` package.
///
/// - **Cycle:** 30 years, years {2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29} of
///   each cycle are leap years (355 days), the others have 354 days.
/// - **Months:** odd months have 30 days, even months 29, and month 12 has 30
///   in a leap year.
/// - **Epoch:** astronomical, 1 Muharram 1 AH = 15 July 622 CE (Julian),
///   Julian Day Number [epochJdn].
///
/// A Hijri date names the civil day on which its daytime falls (the night
/// before it already belongs to it, §6.2 `HijriState`). Civil dates are
/// proleptic Gregorian ([CivilDate]). Pure, total on its domain and
/// deterministic; integer arithmetic only.
final class TabularHijriCalendar {
  /// The calendar.
  const new();

  /// Julian Day Number of 1 Muharram 1 AH (ADR-016).
  static const int epochJdn = 1948439;

  /// Julian Day Number of 1970-01-01 ([CivilDate.epochDay] 0).
  static const int _unixEpochJdn = 2440588;

  static const int _cycleYears = 30;
  static const Set<int> _leapYearsOfCycle = {
    2,
    5,
    7,
    10,
    13,
    16,
    18,
    21,
    24,
    26,
    29,
  };
  static const int _commonYearDays = 354;

  /// Days in one 30-year cycle: 30 × 354 + 11.
  static const int _cycleDays = _cycleYears * _commonYearDays + 11; // = 10631

  /// Whether Hijri [year] (≥ 1) has 355 days.
  bool isLeapYear(int year) {
    _checkYear(year);
    return _leapYearsOfCycle.contains(_yearOfCycle(year));
  }

  /// Days in [month] (1–12) of Hijri [year] (≥ 1): 29 or 30.
  int monthLength(int year, int month) {
    _checkYear(year);
    RangeError.checkValueInInterval(month, 1, 12, 'month');
    if (month.isOdd) return 30;
    return month == 12 && isLeapYear(year) ? 30 : 29;
  }

  /// The Hijri date whose daytime falls on [date].
  ///
  /// Throws [RangeError] for a date before 1 Muharram 1 AH (Gregorian
  /// 622-07-18).
  HijriDate fromCivil(CivilDate date) {
    final daysSinceEpoch = date.epochDay + _unixEpochJdn - epochJdn;
    if (daysSinceEpoch < 0) {
      throw RangeError.value(
        daysSinceEpoch,
        'date',
        '$date is before 1 Muharram 1 AH',
      );
    }
    var year = daysSinceEpoch ~/ _cycleDays * _cycleYears + 1;
    var remaining = daysSinceEpoch % _cycleDays;
    while (remaining >= _yearLength(year)) {
      remaining -= _yearLength(year);
      year++;
    }
    var month = 1;
    while (remaining >= monthLength(year, month)) {
      remaining -= monthLength(year, month);
      month++;
    }
    return HijriDate(year: year, month: month, day: remaining + 1);
  }

  /// The civil date on which the daytime of [date] falls.
  ///
  /// Throws [RangeError] when [date] is not a date of this calendar (year
  /// < 1, month outside 1–12, day outside the month) and [ArgumentError] when
  /// it falls after year 9999 CE ([CivilDate]'s domain).
  CivilDate toCivil(HijriDate date) {
    final HijriDate(:year, :month, :day) = date;
    RangeError.checkValueInInterval(day, 1, monthLength(year, month), 'day');
    final jdn =
        epochJdn + _daysBeforeYear(year) + _daysBeforeMonth(month) + day - 1;
    return CivilDate.fromEpochDay(jdn - _unixEpochJdn);
  }

  int _yearLength(int year) => _commonYearDays + (isLeapYear(year) ? 1 : 0);

  /// Days from 1 Muharram 1 AH to 1 Muharram of [year].
  int _daysBeforeYear(int year) {
    final completed = year - 1;
    final completedCycles = completed ~/ _cycleYears;
    final yearsIntoCycle = completed % _cycleYears;
    final leapDays =
        completedCycles * _leapYearsOfCycle.length +
        _leapYearsOfCycle.where((y) => y <= yearsIntoCycle).length;
    return completed * _commonYearDays + leapDays;
  }

  /// Days from 1 Muharram to day 1 of [month]: months alternate 30 and 29.
  static int _daysBeforeMonth(int month) => (59 * (month - 1) + 1) ~/ 2;

  static int _yearOfCycle(int year) => (year - 1) % _cycleYears + 1;

  static void _checkYear(int year) {
    if (year < 1) throw RangeError.value(year, 'year', 'must be ≥ 1');
  }
}
