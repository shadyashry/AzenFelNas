import 'package:daily_muslim/features/athan/application/plan_entry_id.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

void main() {
  group('PlanEntryId (§7.7)', () {
    test('REQ-ALM-021 the id is the first 16 hex digits of sha256 over '
        '"contextId|day|event|kind" in wire names', () {
      expect(
        PlanEntryId.of(
          contextId: 'ctx_1',
          day: '2026-10-22',
          event: PrayerEventCode.fajr,
          kind: ScheduleEntryKind.athan,
        ),
        '2c67dc30f7563e6c',
      );
      expect(
        PlanEntryId.of(
          contextId: 'ctx_1',
          day: '2026-10-22',
          event: PrayerEventCode.isha,
          kind: ScheduleEntryKind.preReminder,
        ),
        '44f47bf366d402ad',
      );
    });

    test('REQ-ALM-021 a horizon warning hashes an empty event', () {
      expect(
        PlanEntryId.of(
          contextId: 'ctx_1',
          day: '2026-10-22',
          kind: ScheduleEntryKind.horizonWarning,
        ),
        'edb0b2ebdc013065',
      );
    });
  });
}
