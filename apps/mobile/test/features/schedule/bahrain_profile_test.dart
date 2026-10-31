import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:daily_muslim/features/schedule/application/calculate_schedule.dart';
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

/// Manama city centre as a manual context.
ResolvedContext _manama() => manualContext(
  latitudeDeg: 26.2235,
  longitudeDeg: 50.5876,
  zoneId: 'Asia/Bahrain',
  country: 'BH',
  label: 'Manama',
);

void main() {
  final data = bundledRuntimeData();
  final calculate = CalculateSchedule(FixedClock(harnessNowUtcMs));

  test('REQ-DOM-050 Manama resolves the interim Bahrain profile, not the '
      'engine default (§15 D130)', () {
    final schedule = _ok(calculate(_manama(), data));
    expect(schedule.profileId, 'bh.ummalqura.interim');
    expect(schedule.engineDefault, isFalse);
  });

  test('Bahrain Isha is 90 minutes after Maghrib on every day of the week '
      '(§15 D130)', () {
    final schedule = _ok(calculate(_manama(), data));
    for (final day in schedule.days) {
      int shown(PrayerEvent event) =>
          day.times.singleWhere((t) => t.event == event).displayedUtcMs ??
          fail('${day.day} $event has no time');
      expect(
        shown(PrayerEvent.isha) - shown(PrayerEvent.maghrib),
        90 * Duration.millisecondsPerMinute,
        reason: '${day.day}',
      );
    }
  });
}
