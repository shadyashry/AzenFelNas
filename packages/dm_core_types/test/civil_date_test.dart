import 'package:dm_core_types/dm_core_types.dart';
import 'package:glados/glados.dart';

/// Any epoch day between 0001-01-01 and 9999-12-31.
final Generator<int> _epochDays = any.intInRange(-719162, 2932897);

void main() {
  group('CivilDate', () {
    test('serialises to and parses from "YYYY-MM-DD"', () {
      final date = CivilDate(2026, 10, 21);
      expect(date.toJson(), '2026-10-21');
      expect(CivilDate.tryParse('2026-10-21'), date);
      expect(CivilDate(7, 1, 2).toJson(), '0007-01-02');
    });

    test('rejects malformed and impossible dates', () {
      for (final text in [
        '2026-02-29',
        '2026-13-01',
        '2026-00-10',
        '2026-04-31',
        '0000-01-01',
        '2026-1-01',
        '2026-10-21T00:00',
        ' 2026-10-21',
        '',
      ]) {
        expect(CivilDate.tryParse(text), isNull, reason: text);
      }
      expect(() => CivilDate(2026, 2, 30), throwsArgumentError);
    });

    test('follows the Gregorian leap-year rule', () {
      expect(CivilDate.tryOf(2024, 2, 29), isNotNull);
      expect(CivilDate.tryOf(2000, 2, 29), isNotNull);
      expect(CivilDate.tryOf(1900, 2, 29), isNull);
      expect(CivilDate.tryOf(2026, 2, 29), isNull);
    });

    test('counts epoch days from 1970-01-01', () {
      expect(CivilDate(1970, 1, 1).epochDay, 0);
      expect(CivilDate(1969, 12, 31).epochDay, -1);
      expect(CivilDate(2000, 3, 1).epochDay, 11017);
      expect(CivilDate(1, 1, 1).epochDay, -719162);
      expect(CivilDate(9999, 12, 31).epochDay, 2932896);
    });

    test('plusDays crosses month, year and leap-day boundaries', () {
      expect(CivilDate(2024, 2, 28).plusDays(1), CivilDate(2024, 2, 29));
      expect(CivilDate(2026, 12, 31).plusDays(1), CivilDate(2027, 1, 1));
      expect(CivilDate(2026, 3, 1).plusDays(-1), CivilDate(2026, 2, 28));
      expect(() => CivilDate(9999, 12, 31).plusDays(1), throwsArgumentError);
    });

    test('orders chronologically and compares by value', () {
      final dates = [
        CivilDate(2026, 10, 21),
        CivilDate(2025, 12, 31),
        CivilDate(2026, 1, 1),
      ]..sort();
      expect(dates.map((d) => d.toJson()), [
        '2025-12-31',
        '2026-01-01',
        '2026-10-21',
      ]);
      expect(CivilDate(2026, 1, 1).hashCode, CivilDate(2026, 1, 1).hashCode);
    });

    Glados(_epochDays).test('epoch day round-trips through the date', (day) {
      expect(CivilDate.fromEpochDay(day).epochDay, day);
    });

    Glados(_epochDays).test('JSON form round-trips through tryParse', (day) {
      final date = CivilDate.fromEpochDay(day);
      expect(CivilDate.tryParse(date.toJson()), date);
    });

    Glados2(_epochDays, any.intInRange(-400, 400)).test(
      'plusDays(n) then plusDays(-n) is the identity',
      (day, n) {
        final date = CivilDate.fromEpochDay(day);
        final shifted = date.epochDay + n;
        if (shifted < -719162 || shifted > 2932896) return;
        expect(date.plusDays(n).plusDays(-n), date);
      },
    );

    Glados2(_epochDays, _epochDays).test(
      'ordering agrees with epoch-day order',
      (a, b) {
        final cmp = CivilDate.fromEpochDay(a)
            .compareTo(CivilDate.fromEpochDay(b));
        expect(cmp.sign, a.compareTo(b).sign);
      },
    );
  });
}
