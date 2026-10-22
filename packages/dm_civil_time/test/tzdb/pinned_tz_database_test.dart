import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:test/test.dart';

import '../support/pinned_tzdata.dart';

/// Fake [TzDatabase] port: fixed offsets, as the engine tests use.
final class _FixedOffsets implements TzDatabase {
  const new(this._offsets);

  final Map<String, int> _offsets;

  @override
  String get version => 'fake';

  @override
  int offsetSecondsAt(String zoneId, int utcMs) =>
      _offsets[zoneId] ?? (throw ArgumentError.value(zoneId, 'zoneId'));
}

/// The §6.2 `TzDatabase` port contract, run against the real and the fake
/// implementation (REQ-TEST-004).
void _tzDatabaseContract(String name, TzDatabase Function() create) {
  group('$name honours the TzDatabase contract (REQ-TEST-004)', () {
    test('names its data version (REQ-TEST-004)', () {
      expect(create().version, isNotEmpty);
    });

    test('answers a supported zone deterministically (REQ-TEST-004)', () {
      final db = create();
      const at = 1761000000000;
      expect(
        db.offsetSecondsAt('Africa/Cairo', at),
        db.offsetSecondsAt('Africa/Cairo', at),
      );
      expect(
        db.offsetSecondsAt('Africa/Cairo', at).abs(),
        lessThanOrEqualTo(26 * 3600),
      );
    });

    test('throws ArgumentError for an unsupported zone (REQ-TEST-004)', () {
      expect(
        () => create().offsetSecondsAt('Mars/Olympus', 0),
        throwsArgumentError,
      );
    });
  });
}

void main() {
  final db = PinnedTzdata.load().database;

  _tzDatabaseContract('PinnedTzDatabase', () => db);
  _tzDatabaseContract(
    'fixed-offset fake',
    () => const _FixedOffsets({'Africa/Cairo': 7200}),
  );

  group('PinnedTzDatabase (REQ-TIME-020)', () {
    test('uses the pinned data, not the OS: Cairo is UTC+3 in July 2026 '
        '(REQ-TIME-020)', () {
      final july = DateTime.utc(2026, 7).millisecondsSinceEpoch;
      expect(db.offsetSecondsAt('Africa/Cairo', july), 3 * 3600);
      expect(db.offsetSecondsAt('Asia/Riyadh', july), 3 * 3600);
    });

    test('a skipped calendar day has no start (Pacific/Apia 2011-12-30)', () {
      expect(
        db.startOfDayUtcMs('Pacific/Apia', CivilDate(2011, 12, 30)),
        isNull,
      );
      expect(
        db.startOfDayUtcMs('Pacific/Apia', CivilDate(2011, 12, 31)),
        DateTime.utc(2011, 12, 30, 10).millisecondsSinceEpoch,
      );
    });

    test('derives local time before 1970 and across the date line', () {
      final reading = db.localDateTimeOf('Pacific/Kiritimati', -1);
      expect(reading.date, CivilDate(1969, 12, 31));
      expect(reading.offsetSeconds, -10 * 3600 - 40 * 60);
      expect(
        db.localDateTimeOf('Pacific/Kiritimati', 1761000000000).offsetSeconds,
        14 * 3600,
      );
    });

    test('refuses a reading outside one day and an unknown zone', () {
      final day = CivilDate(2026, 1, 1);
      expect(() => db.utcMsOfLocal('UTC', day, -1), throwsRangeError);
      expect(() => db.utcMsOfLocal('UTC', day, 86400000), throwsRangeError);
      expect(() => db.localDateTimeOf('Mars/Olympus', 0), throwsArgumentError);
    });
  });
}
