import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' as tz;

import '../support/pinned_tzdata.dart';

/// `package:timezone`'s own reader over [bytes]: zone name → offset lookup.
/// Its database is process-global, so the locations are copied out at once.
Map<String, tz.Location> _packageLocations(Uint8List bytes) {
  tz.initializeDatabase(bytes);
  return Map.of(tz.timeZoneDatabase.locations);
}

Future<Uint8List> _bundledLatestAll() async {
  final library = await Isolate.resolvePackageUri(
    Uri.parse('package:timezone/timezone.dart'),
  );
  if (library == null) throw StateError('package:timezone is not resolvable');
  return File.fromUri(library.resolve('data/latest_all.tzf')).readAsBytesSync();
}

/// Instants that exercise every zone: each transition ±1 ms and 300 seeded
/// random instants in 1850–2100.
List<int> _instants(tz.Location location, Random random) => [
  for (final at in location.transitionAt) ...[at - 1, at, at + 1],
  for (var i = 0; i < 300; i++) -3786825600000 + random.nextInt(1 << 30) * 7350,
];

void _expectSameOffsets(
  PinnedTzDatabase ours,
  Map<String, tz.Location> theirs,
) {
  final random = Random(2026);
  expect(ours.zoneIds.toSet(), theirs.keys.toSet());
  var checked = 0;
  for (final MapEntry(key: zoneId, value: location) in theirs.entries) {
    for (final utcMs in _instants(location, random)) {
      final expected = location.timeZone(utcMs).offset.inSeconds;
      if (ours.offsetSecondsAt(zoneId, utcMs) != expected) {
        fail(
          '$zoneId at $utcMs: ours ${ours.offsetSecondsAt(zoneId, utcMs)}, '
          'package:timezone $expected',
        );
      }
      checked++;
    }
  }
  expect(checked, greaterThan(598 * 300));
}

void main() {
  final pinned = PinnedTzdata.load();

  test('reads the pinned payload exactly as package:timezone does '
      '(REQ-TIME-020)', () {
    _expectSameOffsets(
      pinned.database,
      _packageLocations(pinned.payload),
    );
  });

  test('the pinned build agrees with package:timezone 0.11.2 own 2026e '
      'database at every instant (REQ-TIME-020)', () async {
    // The package builds latest_all.tzf from 2026e with the host's zic; ours
    // uses the release's zic, which only omits a no-op 2038 transition
    // (§15 D66). Offsets must agree everywhere.
    _expectSameOffsets(
      pinned.database,
      _packageLocations(await _bundledLatestAll()),
    );
  });
}
