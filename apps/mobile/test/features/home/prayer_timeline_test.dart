import 'package:daily_muslim/features/home/domain/prayer_timeline.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

const _hour = 3600000;

TimeRowView _row(PrayerEvent event, int? hour) => TimeRowView(
  event: event,
  localTime: hour == null ? null : '$hour:00',
  dayOffset: 0,
  confidence: hour == null
      ? const ConfidenceLabel.unknown(reasonCode: 'polarNight')
      : const ConfidenceLabel.calculated(),
  displayedUtcMs: hour == null ? null : hour * _hour,
);

final List<TimeRowView> _day = [
  _row(PrayerEvent.imsak, 4),
  _row(PrayerEvent.fajr, 5),
  _row(PrayerEvent.sunrise, 6),
  _row(PrayerEvent.dhuhr, 12),
  _row(PrayerEvent.asr, 15),
  _row(PrayerEvent.maghrib, 18),
  _row(PrayerEvent.isha, 20),
];

PrayerTimeline _at(double hour, PrayerEvent? next, [List<TimeRowView>? rows]) =>
    PrayerTimeline.of(
      rows: rows ?? _day,
      nextPrayer: next == null
          ? null
          : (rows ?? _day).firstWhere((row) => row.event == next),
      nowUtcMs: (hour * _hour).round(),
    );

void main() {
  group('The Home arc is a prayer timeline (§15 D105)', () {
    test('it rings the next prayer and fills the line from the real '
        'instants: halfway from Dhuhr to Asr is 3/8 of the arc', () {
      final t = _at(13.5, PrayerEvent.asr);
      expect(t.next, 2);
      expect(t.progress, closeTo(1.5 / 4, 1e-9));
    });

    test('before Fajr nothing has passed', () {
      expect(
        _at(3, PrayerEvent.fajr),
        const PrayerTimeline(next: 0, progress: 0),
      );
    });

    test("after Isha the day has passed and the next day's Fajr is ringed", () {
      expect(
        _at(23, PrayerEvent.fajr),
        const PrayerTimeline(next: 0, progress: 1),
      );
    });

    test('Sunrise is not on the arc: before Dhuhr none is ringed', () {
      final t = _at(5.5, PrayerEvent.sunrise);
      expect(t.next, isNull);
      // Half an hour into the seven from Fajr to Dhuhr.
      expect(t.progress, closeTo(0.5 / 7 / 4, 1e-9));
    });

    test('a prayer without a time is skipped, not invented', () {
      final polar = [
        _row(PrayerEvent.fajr, null),
        _row(PrayerEvent.dhuhr, 12),
        _row(PrayerEvent.asr, 15),
        _row(PrayerEvent.maghrib, 18),
        _row(PrayerEvent.isha, null),
      ];
      expect(_at(10, PrayerEvent.dhuhr, polar).progress, closeTo(1 / 4, 1e-9));
      expect(
        _at(16.5, PrayerEvent.maghrib, polar).progress,
        closeTo(2.5 / 4, 1e-9),
      );
      expect(_at(23, null, polar).progress, closeTo(3 / 4, 1e-9));
    });
  });
}
