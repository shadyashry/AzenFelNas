import 'dart:io';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_hijri/dm_hijri.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/runtime_fixtures.dart';

/// The published Awqaf minute for each event, in the CSV's column order.
const List<PrayerEvent> _columns = [
  PrayerEvent.fajr,
  PrayerEvent.sunrise,
  PrayerEvent.dhuhr,
  PrayerEvent.asr,
  PrayerEvent.maghrib,
  PrayerEvent.isha,
];

void main() {
  test('ae.awqaf.standard reproduces the Awqaf table of Abu Dhabi over four '
      'seasons: at least 92 % of 738 times to the minute, every time within '
      "one minute, Maghrib never before the authority's (§15 D99)", () {
    final data = bundledRuntimeData();
    // The bundled profile itself, on every published day of the year (its
    // effectiveFrom only decides from when the app selects it).
    final profile = data.profiles.profiles.singleWhere(
      (p) => p.profileId == 'ae.awqaf.standard',
    );
    final abuDhabi = Observer(
      latitudeDeg: 24.45118,
      longitudeDeg: 54.39696,
      zoneId: 'Asia/Dubai',
      source: ObserverSource.manual,
    );
    final rows = File('test/fixtures/awqaf_musaffah_2026.csv')
        .readAsLinesSync()
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .map((l) => l.split(','));
    var exact = 0;
    var total = 0;
    var maghribEarly = 0;
    final misses = <String>[];
    for (final row in rows) {
      final [y, mo, d] = row[0].split('-').map(int.parse).toList();
      final day = switch (const CalculateRange()(
        observer: abuDhabi,
        profile: profile,
        from: CivilDate(y, mo, d),
        days: 1,
        tzdb: data.tzdb,
        hijriFor: (day) => const BuildHijriState()(day: day),
      )) {
        Ok(:final value) => value.single,
        Err(:final failure) => fail('$failure'),
      };
      for (final time in day.times) {
        final column = _columns.indexOf(time.event);
        if (column < 0) continue;
        final shown = DateTime.fromMillisecondsSinceEpoch(
          time.displayedUtcMs ?? fail('${row[0]} ${time.event} has no time'),
          isUtc: true,
        ).add(const Duration(hours: 4));
        final [h, m] = row[column + 1].split(':').map(int.parse).toList();
        final off = (shown.hour * 60 + shown.minute) - (h * 60 + m);
        total++;
        if (off == 0) exact++;
        if (off.abs() > 1) misses.add('${row[0]} ${time.event.name} $off');
        if (time.event == PrayerEvent.maghrib && off < 0) maghribEarly++;
      }
    }
    expect(total, 738);
    expect(misses, isEmpty);
    expect(exact / total, greaterThanOrEqualTo(0.92), reason: '$exact/$total');
    expect(maghribEarly, 0);
  });
}
