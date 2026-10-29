import 'package:daily_muslim/features/home/application/build_day_views.dart';
import 'package:daily_muslim/features/schedule/application/calculate_schedule.dart';
import 'package:daily_muslim/features/schedule/domain/next_prayer.dart';
import 'package:daily_muslim/features/schedule/domain/schedule.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/app_harness.dart';
import '../../support/runtime_fixtures.dart';

Schedule _ok(Result<Schedule, Failure> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => throw StateError('$failure'),
};

void main() {
  final data = bundledRuntimeData();
  final calculate = CalculateSchedule(FixedClock(harnessNowUtcMs));

  group('CalculateSchedule (US-01, US-06)', () {
    test('REQ-TIME-020 the schedule starts on the local today of the '
        "context's zone and holds a week", () {
      final schedule = _ok(calculate(cairo(), data));
      expect(schedule.days, hasLength(CalculateSchedule.days));
      expect(schedule.days.first.day, CivilDate(2026, 10, 22));
      expect(schedule.days.last.day, CivilDate(2026, 10, 28));
      expect(schedule.tzdbVersion, '2026e');
    });

    test('REQ-DOM-004 each day carries the inputs its Calculation ID '
        'hashes', () {
      final schedule = _ok(calculate(cairo(), data));
      expect(schedule.inputs, hasLength(schedule.days.length));
      for (var i = 0; i < schedule.days.length; i++) {
        expect(
          schedule.inputs[i].inputsHash,
          schedule.days[i].provenance.inputsHash,
        );
        expect(schedule.inputs[i].day, schedule.days[i].day);
      }
    });

    test('REQ-DOM-050 before the Egyptian seed profile takes effect '
        '(2026-10-01, §15 D97) Cairo uses engine.default', () {
      final inSeptember = CalculateSchedule(
        FixedClock(harnessNowUtcMs - 30 * Duration.millisecondsPerDay),
      );
      final schedule = _ok(inSeptember(cairo(), data));
      expect(schedule.engineDefault, isTrue);
    });

    test('REQ-DOM-050 once in effect, Cairo resolves the Egyptian seed '
        'profile with the six events', () {
      final schedule = _ok(calculate(cairo(), data));
      expect(schedule.profileId, 'eg.egas.standard');
      expect(schedule.engineDefault, isFalse);
      final events = {for (final t in schedule.days.first.times) t.event};
      expect(
        events,
        containsAll(<PrayerEvent>[
          PrayerEvent.fajr,
          PrayerEvent.sunrise,
          PrayerEvent.dhuhr,
          PrayerEvent.asr,
          PrayerEvent.maghrib,
          PrayerEvent.isha,
        ]),
      );
    });

    test('REQ-DOM-050 a place outside every country falls back to '
        'engine.default and says so', () {
      final atSea = manualContext(
        latitudeDeg: 0,
        longitudeDeg: -30,
        zoneId: 'Etc/GMT+2',
        country: null,
      );
      final schedule = _ok(calculate(atSea, data));
      expect(schedule.profileId, CalculateSchedule.engineDefaultProfileId);
      expect(schedule.engineDefault, isTrue);
    });
  });

  group('NextPrayer (US-04)', () {
    final days = _ok(calculate(cairo(), data)).days;
    int at(int day, PrayerEvent event) => days[day].times
        .firstWhere((t) => t.event == event)
        .displayedUtcMs!; // SAFETY: Cairo has every event on these days.

    test('REQ-TIME-002 after Isha the next prayer is the next day’s Fajr', () {
      final next = NextPrayer.after(days, at(0, PrayerEvent.isha));
      expect(next?.dayIndex, 1);
      expect(next?.time.event, PrayerEvent.fajr);
    });

    test('REQ-TIME-002 sunrise is not a prayer: after Fajr comes Dhuhr', () {
      final next = NextPrayer.after(days, at(0, PrayerEvent.fajr));
      expect(next?.time.event, PrayerEvent.dhuhr);
      expect(next?.remainingMs(at(0, PrayerEvent.fajr)), greaterThan(0));
    });

    test('REQ-TIME-002 no later prayer in the schedule is null', () {
      expect(NextPrayer.after(days, at(6, PrayerEvent.isha)), isNull);
    });
  });

  group('BuildDayViews', () {
    test('REQ-TIME-020 local wall times come from the pinned TZDB', () {
      final schedule = _ok(calculate(cairo(), data));
      final views = BuildDayViews(data.tzdb)(schedule.days, 'Africa/Cairo');
      for (final row in views.first.rows) {
        final utc = row.displayedUtcMs!; // SAFETY: Cairo has every event.
        final offset = data.tzdb.offsetSecondsAt('Africa/Cairo', utc);
        final minutes = ((utc ~/ 1000 + offset) % 86400) ~/ 60;
        final hh = (minutes ~/ 60).toString().padLeft(2, '0');
        final mm = (minutes % 60).toString().padLeft(2, '0');
        expect(row.localTime, '$hh:$mm');
        expect(row.confidence, isA<ConfidenceLabel>());
      }
    });
  });

  test('Cairo on 2026-10-29 is within a minute of the published Egyptian '
      'General Authority of Survey times (§15 D97)', () {
    // Published for Thursday 29 October 2026, summer time (UTC+3), by
    // gate.ahram.org.eg and masrawy.com from the Survey Authority.
    const published = {
      PrayerEvent.fajr: (5, 39),
      PrayerEvent.sunrise: (7, 6),
      PrayerEvent.dhuhr: (12, 39),
      PrayerEvent.asr: (15, 47),
      PrayerEvent.maghrib: (18, 10),
      PrayerEvent.isha: (19, 29),
    };
    final onThe29th = CalculateSchedule(
      FixedClock(DateTime.utc(2026, 10, 29, 3).millisecondsSinceEpoch),
    );
    final schedule = _ok(onThe29th(cairo(), data));
    expect(schedule.profileId, 'eg.egas.standard');
    for (final time in schedule.days.first.times) {
      final (h, m) = published[time.event] ?? fail('${time.event}');
      final shown = DateTime.fromMillisecondsSinceEpoch(
        time.displayedUtcMs ?? fail('${time.event} has no time'),
        isUtc: true,
      ).add(const Duration(hours: 3));
      final minutes = (shown.hour * 60 + shown.minute) - (h * 60 + m);
      expect(minutes.abs(), lessThanOrEqualTo(1), reason: '${time.event}');
    }
  });
}
