import 'package:daily_muslim/features/athan/application/build_snapshot.dart';
import 'package:daily_muslim/features/athan/application/plan_context_id.dart';
import 'package:daily_muslim/features/athan/domain/snapshot_request.dart';
import 'package:daily_muslim/features/schedule/domain/observer_of.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/app_harness.dart';
import '../../support/runtime_fixtures.dart';
import 'plan_fixtures.dart';

void main() {
  final build = BuildSnapshot(bundledRuntimeData().tzdb);
  final snapshot = build(
    SnapshotRequest(
      contextId: PlanContextId.of(1),
      observer: ObserverOf.context(cairo()),
      days: cairoPlanDays().take(4).toList(),
      nowUtcMs: harnessNowUtcMs,
      locale: PlanLocale.ar,
      health: const SnapshotHealth(
        state: HealthStateCode.unknown,
        reasonsCount: 0,
      ),
    ),
  );

  group('BuildSnapshot (§7.7, Appendix I)', () {
    test('REQ-TIME-001 the snapshot holds the displayed times of the next '
        '48 h with zone and TZDB version', () {
      expect(snapshot.zoneId, 'Africa/Cairo');
      expect(snapshot.tzdbVersion, bundledRuntimeData().tzdb.version);
      expect(snapshot.items, isNotEmpty);
      for (final item in snapshot.items) {
        expect(item.displayedUtcMs, greaterThanOrEqualTo(harnessNowUtcMs));
        expect(
          item.displayedUtcMs,
          lessThan(harnessNowUtcMs + BuildSnapshot.windowMs),
        );
      }
      // Two days of seven events, less the ones already past.
      expect(snapshot.items.length, inInclusiveRange(12, 15));
    });

    test('REQ-UX-001 every label but Calculated carries its range, count, '
        'source or reason', () {
      expect(
        BuildSnapshot.confidenceOf(const ConfidenceLabel.calculated()).detail,
        isNull,
      );
      expect(
        BuildSnapshot.confidenceOf(
          const ConfidenceLabel.estimated(rangeMinutes: 7),
        ),
        const SnapshotConfidence(
          kind: ConfidenceKindCode.estimated,
          detail: '±7 min',
        ),
      );
      expect(
        BuildSnapshot.confidenceOf(
          const ConfidenceLabel.observed(count: 3, lastSeenUtcMs: 0),
        ).detail,
        'n=3',
      );
      expect(
        BuildSnapshot.confidenceOf(
          const ConfidenceLabel.unknown(reasonCode: 'NO_EVENT'),
        ).detail,
        'NO_EVENT',
      );
    });

    test('REQ-TIME-001 the sky timeline starts now and changes phase at '
        'every segment', () {
      final sky = snapshot.skyTimeline;
      expect(sky.first.fromUtcMs, harnessNowUtcMs);
      for (var i = 1; i < sky.length; i++) {
        expect(sky[i].fromUtcMs, greaterThan(sky[i - 1].fromUtcMs));
        expect(sky[i].phase, isNot(sky[i - 1].phase));
      }
      expect(sky.map((s) => s.phase), contains(SkyPhaseCode.night));
    });

    test('REQ-UX-001 the built snapshot matches the committed schema '
        'fixture', () {
      expectFixture(
        'snapshot/valid/built.json',
        fixtureText(snapshot.toJson()),
      );
      expect(Snapshot.fromJson(snapshot.toJson()), snapshot);
    });
  });
}
