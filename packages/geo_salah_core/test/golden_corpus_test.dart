import 'dart:convert';
import 'dart:io';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:test/test.dart';

import 'support/bench_profile_files.dart';
import 'support/engine_fixtures.dart';
import 'support/fake_tz_database.dart';
import 'support/fixtures.dart';

/// The golden corpus v2 (§6.7, ADR-019, §15 D48):
/// `test/golden/<city>/<profileId>/<year>.json`, written by
/// `tool/update_golden.dart` after the lab confirmed the Sunrise, Dhuhr and
/// Maghrib instants within ADR-019 tolerance. Every event's origin, raw
/// instant and displayed instant must match exactly.
List<File> _goldenFiles() =>
    Directory('test/golden')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

Map<String, Object?> _timeJson(PrayerTime time) => {
  'event': time.event.name.toUpperCase(),
  'origin': switch (time.origin) {
    Primary() => {'kind': 'PRIMARY'},
    Fallback() => {'kind': 'FALLBACK'},
    NoEvent(:final reason) => {'kind': 'NO_EVENT', 'reason': reason.code},
  },
  if (time.rawUtcMs case final int raw) 'rawUtcMs': raw,
  if (time.displayedUtcMs case final int displayed) 'displayedUtcMs': displayed,
};

/// The golden observer and its fixed-offset zone.
({Observer observer, FakeTzDatabase tzdb}) _setUp(Object? json) =>
    switch (json) {
      {
        'latitudeDeg': final num lat,
        'longitudeDeg': final num lon,
        'zoneId': final String zoneId,
        'offsetSeconds': final int offsetSeconds,
      } =>
        (
          observer: Observer(
            latitudeDeg: lat.toDouble(),
            longitudeDeg: lon.toDouble(),
            zoneId: zoneId,
            source: ObserverSource.benchmark,
          ),
          tzdb: FakeTzDatabase({zoneId: offsetSeconds}),
        ),
      _ => throw FormatException('Not a golden observer: $json'),
    };

void main() {
  final files = _goldenFiles();

  test('covers all 49 Appendix H cities, 2026–2028 (REQ-TEST-001)', () {
    final cities = {
      for (final file in files)
        file.parent.parent.path.split(RegExp(r'[\\/]')).last,
    };
    expect(cities, hasLength(49));
    expect(files, hasLength(49 * 3));
  });

  for (final file in files) {
    final name = file.path.replaceAll(r'\', '/').split('test/golden/').last;
    test('reproduces $name exactly (REQ-TEST-001, REQ-DOM-004)', () {
      // Arrange
      final golden = asJsonObject(jsonDecode(file.readAsStringSync()));
      final (:observer, :tzdb) = _setUp(golden['observer']);
      final profile = readEngineDefault();
      expect(golden['schemaVersion'], 2);
      expect(golden['profileVersion'], profile.version);

      for (final dayJson in asJsonList(golden['days']).map(asJsonObject)) {
        final day = switch (dayJson['day']) {
          final String text => CivilDate.tryParse(text),
          _ => null,
        };
        if (day == null) fail('Bad day in $name: $dayJson');

        // Act
        final result = const CalculateDay()(
          observer: observer,
          profile: profile,
          day: day,
          tzdb: tzdb,
          hijri: testHijri,
        );

        // Assert
        switch (result) {
          case Ok(:final value):
            expect(
              [for (final time in value.times) _timeJson(time)],
              dayJson['times'],
              reason: '$name $day',
            );
          case Err(:final failure):
            fail('$name $day: ${failure.detail}');
        }
      }
    });
  }
}
