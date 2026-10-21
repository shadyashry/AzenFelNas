import 'package:meta/meta.dart';

/// A calendar date without time or zone: a prayer day `D` (DESIGN.md §6.2).
///
/// It is interpreted in the zone of the observer it is used with
/// (`Observer.zoneId`); on its own it denotes no instant. Dates are
/// proleptic Gregorian, years 1–9999. JSON form is `"YYYY-MM-DD"`.
///
/// Instances are immutable, always valid and compare by value. All methods
/// are pure and deterministic; none reads a clock or the device time zone.
@immutable
final class CivilDate implements Comparable<CivilDate> {
  /// Creates the date [year]-[month]-[day].
  ///
  /// Throws [ArgumentError] when it is not a valid date in years 1–9999; use
  /// [tryOf] or [tryParse] for untrusted input.
  factory(int year, int month, int day) =>
      tryOf(year, month, day) ??
      (throw ArgumentError('Invalid civil date: $year-$month-$day'));

  /// Creates the date [epochDay] days after 1970-01-01 (negative before it).
  ///
  /// Throws [ArgumentError] when the result falls outside years 1–9999.
  factory fromEpochDay(int epochDay) {
    // Civil-from-days (H. Hinnant), shifted so the era starts on 1 March.
    final z = epochDay + _epochShift;
    final era = (z >= 0 ? z : z - (_daysPerEra - 1)) ~/ _daysPerEra;
    final dayOfEra = z - era * _daysPerEra;
    final yearOfEra =
        (dayOfEra -
            dayOfEra ~/ 1460 +
            dayOfEra ~/ 36524 -
            dayOfEra ~/ (_daysPerEra - 1)) ~/
        365;
    final dayOfYear =
        dayOfEra - (365 * yearOfEra + yearOfEra ~/ 4 - yearOfEra ~/ 100);
    final shiftedMonth = (5 * dayOfYear + 2) ~/ 153;
    final day = dayOfYear - (153 * shiftedMonth + 2) ~/ 5 + 1;
    final month = shiftedMonth < 10 ? shiftedMonth + 3 : shiftedMonth - 9;
    final year = yearOfEra + era * 400 + (month <= 2 ? 1 : 0);
    return CivilDate(year, month, day);
  }

  const new _(this.year, this.month, this.day);

  /// The date [year]-[month]-[day], or `null` when it is not a valid date in
  /// years 1–9999.
  static CivilDate? tryOf(int year, int month, int day) {
    if (year < 1 || year > 9999 || month < 1 || month > 12 || day < 1) {
      return null;
    }
    if (day > _daysInMonth(year, month)) return null;
    return CivilDate._(year, month, day);
  }

  /// Parses the strict JSON form `"YYYY-MM-DD"`; `null` for anything else,
  /// including impossible dates such as `"2026-02-30"`.
  static CivilDate? tryParse(String text) {
    final match = _jsonForm.firstMatch(text);
    if (match == null) return null;
    return tryOf(
      int.parse(match.group(1) ?? ''),
      int.parse(match.group(2) ?? ''),
      int.parse(match.group(3) ?? ''),
    );
  }

  static final RegExp _jsonForm = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
  static const int _daysPerEra = 146097;
  static const int _epochShift = 719468;

  /// Year, 1–9999.
  final int year;

  /// Month, 1–12.
  final int month;

  /// Day of month, 1–31 depending on [month] and [year].
  final int day;

  /// Days since 1970-01-01 (negative before it).
  int get epochDay {
    // Days-from-civil (H. Hinnant), shifted so the era starts on 1 March.
    final y = month <= 2 ? year - 1 : year;
    final era = y ~/ 400;
    final yearOfEra = y - era * 400;
    final dayOfYear =
        (153 * (month > 2 ? month - 3 : month + 9) + 2) ~/ 5 + day - 1;
    final dayOfEra =
        yearOfEra * 365 + yearOfEra ~/ 4 - yearOfEra ~/ 100 + dayOfYear;
    return era * _daysPerEra + dayOfEra - _epochShift;
  }

  /// The date [days] days later (earlier when negative).
  ///
  /// Throws [ArgumentError] when the result falls outside years 1–9999.
  CivilDate plusDays(int days) => CivilDate.fromEpochDay(epochDay + days);

  /// The JSON form `"YYYY-MM-DD"`.
  String toJson() => '${_pad(year, 4)}-${_pad(month, 2)}-${_pad(day, 2)}';

  @override
  int compareTo(CivilDate other) => epochDay.compareTo(other.epochDay);

  @override
  bool operator ==(Object other) =>
      other is CivilDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toJson();

  static String _pad(int value, int width) =>
      value.toString().padLeft(width, '0');

  static int _daysInMonth(int year, int month) => switch (month) {
    2 => _isLeapYear(year) ? 29 : 28,
    4 || 6 || 9 || 11 => 30,
    _ => 31,
  };

  static bool _isLeapYear(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
}
