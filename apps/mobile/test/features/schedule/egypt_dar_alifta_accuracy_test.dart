import 'dart:io';

import 'package:daily_muslim/features/home/application/build_day_views.dart';
import 'package:daily_muslim/features/schedule/application/calculate_schedule.dart';
import 'package:daily_muslim/features/schedule/domain/schedule.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/runtime_fixtures.dart';

/// The published minute for each event, in the CSV's column order.
const List<PrayerEvent> _columns = [
  PrayerEvent.fajr,
  PrayerEvent.sunrise,
  PrayerEvent.dhuhr,
  PrayerEvent.asr,
  PrayerEvent.maghrib,
  PrayerEvent.isha,
];

int _minutes(String hhmm) {
  final [h, m] = hhmm.split(':').map(int.parse).toList();
  return h * 60 + m;
}

void main() {
  test('Cairo matches Dar al-Ifta for every day of October 2026, across the '
      'end of summer time: each of the 186 times within one minute, no '
      'prayer shown before the authority, sunrise never after it '
      '(§15 D97, D131)', () {
    final data = bundledRuntimeData();
    final published = {
      for (final row
          in File('test/fixtures/dar_alifta_cairo_2026_10.csv')
              .readAsLinesSync()
              .where((l) => l.isNotEmpty && !l.startsWith('#'))
              .map((l) => l.split(',')))
        row[0]: row.sublist(1),
    };
    final shown = <String, Map<PrayerEvent, String>>{};
    // Home's own path: the schedule a phone in Cairo holds each week, and
    // the wall times BuildDayViews shows from the pinned TZDB.
    for (final first in [1, 8, 15, 22, 29]) {
      final calculate = CalculateSchedule(
        FixedClock(DateTime.utc(2026, 10, first, 9).millisecondsSinceEpoch),
      );
      final schedule = switch (calculate(cairo(), data)) {
        Ok<Schedule, Failure>(:final value) => value,
        Err(:final failure) => fail('$failure'),
      };
      expect(schedule.profileId, 'eg.egas.standard');
      final views = BuildDayViews(data.tzdb)(schedule.days, 'Africa/Cairo');
      for (final (i, day) in schedule.days.indexed) {
        shown[day.day.toString()] = {
          for (final row in views[i].rows)
            if (row.localTime case final String time) row.event: time,
        };
      }
    }
    var total = 0;
    var exact = 0;
    final problems = <String>[];
    for (final MapEntry(key: date, value: times) in published.entries) {
      final app = shown[date] ?? fail('no schedule for $date');
      for (final (c, event) in _columns.indexed) {
        final local = app[event] ?? fail('$date $event not shown');
        final off = _minutes(local) - _minutes(times[c]);
        total++;
        if (off == 0) exact++;
        final early = event != PrayerEvent.sunrise && off < 0;
        final lateSunrise = event == PrayerEvent.sunrise && off > 0;
        if (off.abs() > 1 || early || lateSunrise) {
          problems.add(
            '$date ${event.name} app $local, published '
            '${times[c]}',
          );
        }
      }
    }
    expect(total, 186);
    expect(problems, isEmpty);
    // The authority rounds to the nearest minute; the app rounds entries up
    // (ADR-005), so about four in ten times are the same minute.
    expect(exact, greaterThanOrEqualTo(75), reason: '$exact/$total');
  });
}
