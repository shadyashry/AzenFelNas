import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_hijri/dm_hijri.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:glados/glados.dart';

const BuildHijriState _build = BuildHijriState();
const TabularHijriCalendar _calendar = TabularHijriCalendar();

/// The tabular 1 Ramadan 1447 (tabular_hijri_calendar_test.dart).
final CivilDate _firstOfRamadan = CivilDate(2026, 2, 17);

void main() {
  group('BuildHijriState (§6.2, ADR-016)', () {
    Glados(
      any.intInRange(
        CivilDate(2000, 1, 1).epochDay,
        CivilDate(2100, 1, 1).epochDay,
      ),
    ).test('gives hijri(D) at dawn and hijri(D + 1) at night, labelled '
        'Expected without a package version', (epochDay) {
      final day = CivilDate.fromEpochDay(epochDay);

      final state = _build(day: day);

      expect(state.dateAtDawn, _calendar.fromCivil(day));
      expect(
        state.dateAtNight,
        _calendar.fromCivil(CivilDate.fromEpochDay(epochDay + 1)),
      );
      expect(state.confidence, HijriConfidence.expected);
      expect(state.packageVersion, isNull);
    });

    test('lets Ramadan govern the night before its first fast and the dawn '
        'of its first day (§6.4 ¶6)', () {
      final eve = _build(
        day: CivilDate.fromEpochDay(_firstOfRamadan.epochDay - 1),
      );
      final first = _build(day: _firstOfRamadan);

      expect(eve.dateAtNight, const HijriDate(year: 1447, month: 9, day: 1));
      expect((eve.ramadanAtDawn, eve.ramadanAtNight), (false, true));
      expect((first.ramadanAtDawn, first.ramadanAtNight), (true, true));
    });

    test('ends Ramadan at the night before Eid: the last fast has a Ramadan '
        'dawn and a Shawwal night', () {
      final lastFast = _calendar.toCivil(
        HijriDate(
          year: 1447,
          month: 9,
          day: _calendar.monthLength(1447, 9),
        ),
      );

      final state = _build(day: lastFast);

      expect((state.ramadanAtDawn, state.ramadanAtNight), (true, false));
    });

    test('applies the ±1-day user override before building and labels the '
        'state userOverride (§9.5, Appendix K)', () {
      final later = _build(day: _firstOfRamadan, overrideDays: 1);
      final earlier = _build(day: _firstOfRamadan, overrideDays: -1);

      expect(later.dateAtDawn, const HijriDate(year: 1447, month: 9, day: 2));
      expect(later.confidence, HijriConfidence.userOverride);
      expect(
        earlier.dateAtDawn,
        _calendar.fromCivil(
          CivilDate.fromEpochDay(_firstOfRamadan.epochDay - 1),
        ),
      );
      expect(earlier.confidence, HijriConfidence.userOverride);
    });

    test('refuses an override outside −1…1', () {
      expect(
        () => _build(day: _firstOfRamadan, overrideDays: 2),
        throwsRangeError,
      );
    });
  });
}
