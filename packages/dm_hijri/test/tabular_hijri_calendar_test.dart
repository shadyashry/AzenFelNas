import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_hijri/dm_hijri.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:glados/glados.dart';

const TabularHijriCalendar _calendar = TabularHijriCalendar();

/// Civil days 1900-01-01 … 2199-12-31 as epoch days.
final Generator<int> _epochDays = any.intInRange(
  CivilDate(1900, 1, 1).epochDay,
  CivilDate(2200, 1, 1).epochDay,
);

/// Hijri years 1 … 2000.
final Generator<int> _years = any.intInRange(1, 2001);

void main() {
  group('tabular calendar (ADR-016)', () {
    test('starts 1 Muharram 1 AH on JDN 1948439, 15 July 622 Julian = '
        '18 July 622 proleptic Gregorian', () {
      const first = HijriDate(year: 1, month: 1, day: 1);

      expect(_calendar.toCivil(first), CivilDate(622, 7, 18));
      expect(_calendar.fromCivil(CivilDate(622, 7, 18)), first);
      // JDN 2440588 is 1970-01-01.
      expect(
        CivilDate(622, 7, 18).epochDay + 2440588,
        TabularHijriCalendar.epochJdn,
      );
    });

    test('refuses a civil day before the epoch', () {
      expect(
        () => _calendar.fromCivil(CivilDate(622, 7, 17)),
        throwsRangeError,
      );
    });

    test('makes years 2, 5, 7, 10, 13, 16, 18, 21, 24, 26 and 29 of every '
        '30-year cycle leap years', () {
      const leap = {2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29};
      for (final cycle in [0, 1, 47, 48]) {
        for (var yearOfCycle = 1; yearOfCycle <= 30; yearOfCycle++) {
          expect(
            _calendar.isLeapYear(cycle * 30 + yearOfCycle),
            leap.contains(yearOfCycle),
            reason: 'cycle $cycle year $yearOfCycle',
          );
        }
      }
    });

    test('alternates 30- and 29-day months, with 30 days in month 12 of a '
        'leap year', () {
      for (final year in [1446, 1447]) {
        expect(
          [
            for (var month = 1; month <= 12; month++)
              _calendar.monthLength(year, month),
          ],
          [
            30,
            29,
            30,
            29,
            30,
            29,
            30,
            29,
            30,
            29,
            30,
            if (_calendar.isLeapYear(year)) 30 else 29,
          ],
        );
      }
      // 1446 and 1447 are years 6 and 7 of their cycle.
      expect(_calendar.isLeapYear(1446), isFalse);
      expect(_calendar.isLeapYear(1447), isTrue);
    });

    test('gives a 30-year cycle 10631 days', () {
      final start = _calendar.toCivil(
        const HijriDate(year: 1441, month: 1, day: 1),
      );
      final end = _calendar.toCivil(
        const HijriDate(year: 1471, month: 1, day: 1),
      );
      expect(end.epochDay - start.epochDay, 10631);
    });

    test('puts 1 Muharram 1447 on 2025-06-26 (1446 years = 48 cycles + 6 '
        'years: 1446 × 354 + 48 × 11 + 2 leap days = 512414 days after '
        'JDN 1948439)', () {
      expect(
        _calendar.toCivil(const HijriDate(year: 1447, month: 1, day: 1)),
        CivilDate(2025, 6, 26),
      );
      expect(
        _calendar.toCivil(const HijriDate(year: 1447, month: 9, day: 1)),
        CivilDate(2026, 2, 17),
      );
    });

    test('refuses a Hijri date that does not exist', () {
      for (final date in const [
        HijriDate(year: 0, month: 1, day: 1),
        HijriDate(year: 1447, month: 13, day: 1),
        HijriDate(year: 1447, month: 2, day: 30),
        HijriDate(year: 1447, month: 1, day: 0),
      ]) {
        expect(
          () => _calendar.toCivil(date),
          throwsRangeError,
          reason: '$date',
        );
      }
    });

    Glados(_epochDays).test('maps a civil day to a Hijri date and back to '
        'the same day', (epochDay) {
      final day = CivilDate.fromEpochDay(epochDay);
      expect(_calendar.toCivil(_calendar.fromCivil(day)), day);
    });

    Glados(_epochDays).test('advances the Hijri date by exactly one day per '
        'civil day', (epochDay) {
      final today = _calendar.fromCivil(CivilDate.fromEpochDay(epochDay));
      final tomorrow = _calendar.fromCivil(
        CivilDate.fromEpochDay(epochDay + 1),
      );
      final lastOfMonth =
          today.day == _calendar.monthLength(today.year, today.month);
      expect(
        tomorrow,
        switch ((lastOfMonth, today.month)) {
          (false, _) => HijriDate(
            year: today.year,
            month: today.month,
            day: today.day + 1,
          ),
          (true, 12) => HijriDate(year: today.year + 1, month: 1, day: 1),
          (true, _) => HijriDate(
            year: today.year,
            month: today.month + 1,
            day: 1,
          ),
        },
      );
    });

    Glados(_years).test('gives every Hijri year 354 or 355 days, 355 exactly '
        'in a leap year', (year) {
      final start = _calendar.toCivil(HijriDate(year: year, month: 1, day: 1));
      final next = _calendar.toCivil(
        HijriDate(year: year + 1, month: 1, day: 1),
      );
      expect(
        next.epochDay - start.epochDay,
        _calendar.isLeapYear(year) ? 355 : 354,
      );
    });
  });
}
