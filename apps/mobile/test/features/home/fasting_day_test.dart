import 'package:daily_muslim/features/home/application/build_day_views.dart';
import 'package:daily_muslim/features/home/application/build_fasting_day.dart';
import 'package:daily_muslim/features/home/domain/day_view.dart';
import 'package:daily_muslim/features/home/domain/fasting_day.dart';
import 'package:daily_muslim/features/schedule/application/calculate_schedule.dart';
import 'package:daily_muslim/features/schedule/domain/schedule.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/runtime_fixtures.dart';

/// 2027-02-20T10:00:00Z: noon in Cairo, in Ramadan 1448 by the tabular
/// calendar the seed uses without a `hijri` package.
const int _ramadanNoon = 1803117600000;

/// 2026-11-10T10:00:00Z: Jumada al-Ula 1448, not Ramadan.
const int _november = 1794304800000;

Schedule _schedule(int now, {int hijriOverrideDays = 0}) =>
    switch (CalculateSchedule(FixedClock(now))(
      cairo(),
      bundledRuntimeData(),
      hijriOverrideDays: hijriOverrideDays,
    )) {
      Ok(:final value) => value,
      Err(:final failure) => throw StateError('$failure'),
    };

FastingDay _fasting(Schedule schedule, int now) => const BuildFastingDay()(
  views: BuildDayViews(bundledRuntimeData().tzdb)(
    schedule.days,
    schedule.zoneId,
  ),
  hijri: [for (final inputs in schedule.inputs) inputs.hijri],
  nowUtcMs: now,
);

int _at(Schedule schedule, int day, PrayerEvent event) =>
    schedule.days[day].times
        .firstWhere((t) => t.event == event)
        .displayedUtcMs ??
    (throw StateError('$event has no time'));

void main() {
  group('REQ-RAM-001 Home Ramadan card', () {
    test('in Ramadan the window runs from the day\'s own Fajr to its own '
        'Maghrib, with the Hijri confidence', () {
      final schedule = _schedule(_ramadanNoon);
      final card = _fasting(schedule, _ramadanNoon);

      expect(card, isA<FastingWindow>());
      if (card case FastingWindow(:final ramadan, :final begins, :final ends)) {
        expect(begins.displayedUtcMs, _at(schedule, 0, PrayerEvent.fajr));
        expect(ends.displayedUtcMs, _at(schedule, 0, PrayerEvent.maghrib));
        expect(ramadan.day, schedule.inputs.first.hijri.dateAtDawn.day);
        expect(ramadan.confidence, HijriConfidence.expected);
      }
    });

    test('after Maghrib the card shows the next day\'s fast', () {
      final schedule = _schedule(_ramadanNoon);
      final afterIftar = _at(schedule, 0, PrayerEvent.maghrib) + 60000;
      final card = _fasting(schedule, afterIftar);

      if (card case FastingWindow(:final begins)) {
        expect(begins.displayedUtcMs, _at(schedule, 1, PrayerEvent.fajr));
      } else {
        fail('expected a window, got $card');
      }
    });

    test('the ±1 override moves the Ramadan day and is labelled as the '
        'user\'s', () {
      final base = _fasting(_schedule(_ramadanNoon), _ramadanNoon);
      final shifted = _fasting(
        _schedule(_ramadanNoon, hijriOverrideDays: 1),
        _ramadanNoon,
      );

      if ((base, shifted) case (
        FastingWindow(ramadan: final a),
        FastingWindow(ramadan: final b),
      )) {
        expect(b.day, a.day + 1);
        expect(b.confidence, HijriConfidence.userOverride);
      } else {
        fail('expected two windows');
      }
    });

    test('outside Ramadan there is no card', () {
      expect(_fasting(_schedule(_november), _november), isA<NotFasting>());
    });

    test('a Ramadan day without a Fajr time says Unknown rather than invent '
        'a window', () {
      final schedule = _schedule(_ramadanNoon);
      final views = BuildDayViews(
        bundledRuntimeData().tzdb,
      )(schedule.days, schedule.zoneId);
      final noFajr = [
        for (final view in views)
          DayView(
            date: view.date,
            calculationId: view.calculationId,
            rows: [
              for (final row in view.rows)
                if (row.event != PrayerEvent.fajr) row,
            ],
          ),
      ];
      expect(
        const BuildFastingDay()(
          views: noFajr,
          hijri: [for (final inputs in schedule.inputs) inputs.hijri],
          nowUtcMs: _ramadanNoon,
        ),
        isA<FastingUnknown>(),
      );
    });
  });
}
