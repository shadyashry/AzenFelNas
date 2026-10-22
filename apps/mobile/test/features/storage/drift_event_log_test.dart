import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:daily_muslim/features/storage/data/drift_event_log.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

EventLogEntry _entry(int i) => EventLogEntry(
  utcMs: i,
  level: EventLogLevel.info,
  code: EventCode.syncResult,
  attrs: EventLogAttrs(count: i, zoneId: 'Africa/Cairo'),
);

void main() {
  late DmDatabase db;
  late DriftEventLog log;

  setUp(() {
    db = DmDatabase(NativeDatabase.memory());
    log = DriftEventLog(db);
  });
  tearDown(() => db.close());

  test('entries round-trip through event_log in order', () async {
    await log(_entry(1));
    await log(_entry(2));
    expect(await log.entries(), [_entry(1), _entry(2)]);
  });

  test(
    'the ring keeps the newest ${DriftEventLog.capacity} entries '
    '(REQ-DATA-001)',
    () async {
      const extra = 3;
      await db.transaction(() async {
        for (var i = 0; i < DriftEventLog.capacity + extra; i++) {
          await log(_entry(i));
        }
      });
      final kept = await log.entries();
      expect(kept, hasLength(DriftEventLog.capacity));
      expect(kept.first.utcMs, extra);
      expect(kept.last.utcMs, DriftEventLog.capacity + extra - 1);
    },
  );

  test('a stored row carries only allow-listed attribute keys '
      '(REQ-PRIV-001)', () async {
    await log(_entry(1));
    final row = await db.select(db.eventLog).getSingle();
    expect(row.attrsJson, '{"count":1,"zoneId":"Africa/Cairo"}');
  });
}
