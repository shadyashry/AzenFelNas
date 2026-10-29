import 'package:daily_muslim/features/qibla/application/find_shadow_times.dart';
import 'package:daily_muslim/features/qibla/domain/shadow_times.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/runtime_fixtures.dart';

Observer _at(double lat, double lon, String zoneId) => Observer(
  latitudeDeg: lat,
  longitudeDeg: lon,
  zoneId: zoneId,
  source: ObserverSource.manual,
);

int _utc(int year, int month, int day, int hour) =>
    DateTime.utc(year, month, day, hour).millisecondsSinceEpoch;

ShadowTimesFound _found(ShadowTimes times) => switch (times) {
  final ShadowTimesFound found => found,
  ShadowTimesNone() || ShadowTimesNearKaaba() => throw StateError('$times'),
};

void main() {
  final find = FindShadowTimes(bundledRuntimeData().tzdb);
  final london = _at(51.51, -0.13, 'Europe/London');

  group('FindShadowTimes (§15 D91)', () {
    test('REQ-DOM-031 REQ-TIME-020 gives London its raṣd al-qibla morning '
        'in British Summer Time and its evening shadow', () {
      final day = _found(find(london, nowUtcMs: _utc(2026, 5, 27, 8)));
      expect(day.isToday, isTrue);
      expect(day.date, CivilDate(2026, 5, 27));
      expect(day.times.map((t) => t.kind), [
        QiblaSunAlignmentKind.sunTowardQibla,
        QiblaSunAlignmentKind.sunAwayFromQibla,
      ]);
      // Published 09:18 UTC; 10:18 in BST, within 2 min.
      expect(
        day.times.first.localTime,
        matches(RegExp(r'^10:1[6-9]$|^10:20$')),
      );
      expect(
        day.times.first.windowStart.compareTo(day.times.first.localTime),
        lessThanOrEqualTo(0),
      );
      expect(
        day.times.first.windowEnd.compareTo(day.times.first.localTime),
        greaterThanOrEqualTo(0),
      );
    });

    test('REQ-DOM-031 marks a closed window as passed and keeps it listed', () {
      final day = _found(find(london, nowUtcMs: _utc(2026, 5, 27, 12)));
      expect(day.times.map((t) => t.passed), [true, false]);
    });

    test('REQ-DOM-031 flags, never hides, a moment with the Sun above 75°: '
        'Jeddah on the raṣd day', () {
      final day = _found(
        find(_at(21.54, 39.17, 'Asia/Riyadh'), nowUtcMs: _utc(2026, 5, 27, 3)),
      );
      expect(day.times, hasLength(2));
      expect(day.times.first.hardToUse, ShadowDifficulty.highSun);
      expect(day.times.last.hardToUse, isNull);
    });

    test('REQ-DOM-031 moves to the first later day within eight when today '
        'has none: Tromsø as the Sun returns', () {
      final day = _found(
        find(_at(69.65, 18.96, 'Europe/Oslo'), nowUtcMs: _utc(2027, 1, 21, 11)),
      );
      expect(day.isToday, isFalse);
      expect(day.date, CivilDate(2027, 1, 28));
    });

    test('REQ-DOM-031 reports none in polar night', () {
      expect(
        find(
          _at(69.65, 18.96, 'Europe/Oslo'),
          nowUtcMs: _utc(2026, 12, 21, 11),
        ),
        isA<ShadowTimesNone>(),
      );
    });

    test('REQ-DOM-031 offers no Sun method within 1 km of the Kaaba', () {
      expect(
        find(
          _at(21.4229, 39.8263, 'Asia/Riyadh'),
          nowUtcMs: _utc(2026, 5, 27, 3),
        ),
        isA<ShadowTimesNearKaaba>(),
      );
    });
  });
}
