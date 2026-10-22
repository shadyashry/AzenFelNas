// The S10 done-test (DESIGN.md §13): transition-day conversions ±7 days for
// every zone of the benchmark corpus, against the independent CPython
// `zoneinfo` oracle the data pipeline writes from the same zic output
// (`dst_oracle.json`, schema `tz_transition_oracle.v1`, §15 D66–D67).
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:test/test.dart';

import '../support/pinned_tzdata.dart';

const int _hourMs = 3600000;

List<Map<String, Object?>> _objects(Object? json) => switch (json) {
  final List<Object?> list => [
    for (final item in list)
      switch (item) {
        final Map<String, Object?> object => object,
        _ => throw const FormatException('expected an object'),
      },
  ],
  _ => throw const FormatException('expected a list'),
};

List<int> _ints(Object? json) => switch (json) {
  final List<Object?> list => [
    for (final item in list)
      switch (item) {
        final int value => value,
        _ => throw const FormatException('expected an integer'),
      },
  ],
  _ => throw const FormatException('expected a list'),
};

int _int(Map<String, Object?> json, String key) => switch (json[key]) {
  final int value => value,
  _ => throw FormatException('$key is not an integer'),
};

CivilDate _date(Object? json) => switch (json) {
  final String text =>
    CivilDate.tryParse(text) ?? (throw FormatException(text)),
  _ => throw const FormatException('day is not a string'),
};

void main() {
  final pinned = PinnedTzdata.load();
  final db = pinned.database;
  final oracle = pinned.oracle;
  final zones = _objects(oracle['zones']);
  final fromMs = DateTime.utc(_int(oracle, 'fromYear')).millisecondsSinceEpoch;
  final toMs = DateTime.utc(_int(oracle, 'toYear') + 1).millisecondsSinceEpoch;

  test('the oracle is for the pinned release and covers the corpus', () {
    expect(oracle['tzdbVersion'], db.version);
    expect(zones, hasLength(41));
    expect(_int(oracle, 'windowDays'), 7);
  });

  for (final zone in zones) {
    final zoneId = zone['zoneId'].toString();
    final transitions = _objects(zone['transitions']);
    final days = _objects(zone['days']);

    group('$zoneId (REQ-TIME-020)', () {
      test('changes offset exactly at the oracle transitions and nowhere '
          'else (REQ-TIME-020)', () {
        expect(
          db.offsetSecondsAt(zoneId, fromMs),
          _int(zone, 'offsetAtStartSeconds'),
        );
        for (final t in transitions) {
          final at = _int(t, 'utcMs');
          expect(
            db.offsetSecondsAt(zoneId, at - 1),
            _int(t, 'offsetBeforeSeconds'),
            reason: 'before $at',
          );
          expect(
            db.offsetSecondsAt(zoneId, at),
            _int(t, 'offsetAfterSeconds'),
            reason: 'at $at',
          );
        }
        // Hourly scan: the offset changes once per oracle transition.
        var changes = 0;
        var previous = db.offsetSecondsAt(zoneId, fromMs);
        for (var at = fromMs + _hourMs; at < toMs; at += _hourMs) {
          final current = db.offsetSecondsAt(zoneId, at);
          if (current != previous) changes++;
          previous = current;
        }
        expect(changes, transitions.length);
      });

      test('converts every hour of every transition-window day like the '
          'oracle (REQ-TIME-020, REQ-TIME-001)', () {
        if (transitions.isEmpty) {
          expect(days, isEmpty);
          return;
        }
        expect(days.length, greaterThanOrEqualTo(15));
        for (final day in days) {
          final date = _date(day['day']);
          expect(
            db.startOfDayUtcMs(zoneId, date),
            _int(day, 'startOfDayUtcMs'),
            reason: '$date start',
          );
          final hours = _ints(day['localHourUtcMs']);
          final offsets = _ints(day['hourOffsetsSeconds']);
          for (var h = 0; h < 24; h++) {
            final utcMs = db.utcMsOfLocal(zoneId, date, h * _hourMs);
            expect(utcMs, hours[h], reason: '$date $h:00 local -> UTC');
            final reading = db.localDateTimeOf(zoneId, utcMs);
            expect(reading.offsetSeconds, offsets[h], reason: '$date $h:00');
            // UTC -> local: the reading is h:00, or later only in a gap.
            final inGap =
                utcMs + offsets[h] * 1000 !=
                date.epochDay * LocalDateTime.millisecondsPerDay + h * _hourMs;
            if (!inGap) {
              expect(
                (reading.date, reading.millisecondOfDay),
                (date, h * _hourMs),
                reason: '$date $h:00 round trip',
              );
            }
          }
        }
      });
    });
  }
}
