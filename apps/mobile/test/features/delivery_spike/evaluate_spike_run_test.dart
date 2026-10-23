import 'dart:convert';

import 'package:daily_muslim/features/delivery_spike/application/evaluate_spike_run.dart';
import 'package:daily_muslim/features/delivery_spike/domain/spike_protocol.dart';
import 'package:daily_muslim/features/delivery_spike/domain/spike_verdict.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';

const int t0 = 1792000000000;
const int hour = 3600000;

EventLogEntry scheduled(
  String id,
  String path,
  String scenario, {
  int at = t0,
}) => EventLogEntry(
  utcMs: at - 60000,
  level: EventLogLevel.info,
  code: EventCode.alarmScheduled,
  attrs: EventLogAttrs(
    entryId: id,
    reason: path,
    state: scenario,
    durationMs: 60000,
  ),
);

EventLogEntry presented(String id, String stage, int latenessMs) =>
    EventLogEntry(
      utcMs: t0 + latenessMs,
      level: EventLogLevel.info,
      code: EventCode.alarmPresented,
      attrs: EventLogAttrs(
        entryId: id,
        reason: stage,
        durationMs: latenessMs,
      ),
    );

EventLogEntry dismissed(String id, String reason) => EventLogEntry(
  utcMs: t0 + 30000,
  level: EventLogLevel.info,
  code: EventCode.alarmDismissed,
  attrs: EventLogAttrs(entryId: id, reason: reason, durationMs: 30000),
);

EventLogEntry observed(
  String reason, {
  String? entryId,
  int? durationMs,
  int? count,
}) => EventLogEntry(
  utcMs: t0 + hour,
  level: EventLogLevel.info,
  code: EventCode.testResult,
  attrs: EventLogAttrs(
    entryId: entryId,
    reason: reason,
    durationMs: durationMs,
    count: count,
  ),
);

String id(int n) => n.toRadixString(16).padLeft(16, '0');

/// Three passing exact-path runs per required Android scenario.
List<EventLogEntry> passingAndroidRun() {
  var n = 0;
  return [
    for (final scenario in const SpikeCriteria().androidScenarios)
      for (var run = 0; run < 3; run++)
        ...() {
          final entry = id(++n);
          return [
            scheduled(entry, SpikeLabels.androidExact, scenario),
            presented(entry, SpikeLabels.receiver, 120),
            presented(entry, SpikeLabels.fgsStarted, 400),
            presented(entry, SpikeLabels.audioStarted, 900),
          ];
        }(),
  ];
}

T verdictOf<T extends SpikeVerdict>(
  List<SpikeVerdict> verdicts,
  SpikePath path,
) => verdicts.singleWhere((v) => v.path == path) as T;

void main() {
  const evaluate = EvaluateSpikeRun();
  const now = t0 + 2 * hour;

  test('an empty run is insufficient evidence on every path', () {
    final verdicts = evaluate(const [], nowUtcMs: now);
    expect(verdicts.map((v) => v.path), SpikePath.values);
    expect(verdicts, everyElement(isA<SpikeInsufficientEvidence>()));
  });

  group('Android exact alarm → foreground service', () {
    test('REQ-ALM-020 REQ-ALM-023 three on-time runs per scenario is a go', () {
      final verdict = verdictOf<SpikeGo>(
        evaluate(passingAndroidRun(), nowUtcMs: now),
        SpikePath.androidExactFgs,
      );
      expect(verdict.entries, 21);
    });

    test('REQ-ALM-023 a refused service start is a no-go', () {
      final events = [
        ...passingAndroidRun(),
        scheduled(id(99), SpikeLabels.androidExact, 'swiped'),
        presented(id(99), SpikeLabels.receiver, 100),
        presented(id(99), SpikeLabels.fgsDenied, 150),
      ];
      final verdict = verdictOf<SpikeNoGo>(
        evaluate(events, nowUtcMs: now),
        SpikePath.androidExactFgs,
      );
      expect(verdict.failures.single, isA<ForegroundServiceDenied>());
    });

    test('REQ-ALM-020 a stage later than 5 s is a no-go', () {
      final events = [
        scheduled(id(1), SpikeLabels.androidExact, 'doze'),
        presented(id(1), SpikeLabels.fgsStarted, 400),
        presented(id(1), SpikeLabels.audioStarted, 7000),
      ];
      final failure =
          verdictOf<SpikeNoGo>(
                evaluate(events, nowUtcMs: now),
                SpikePath.androidExactFgs,
              ).failures.single
              as DeliveredLate;
      expect(failure.stage, SpikeLabels.audioStarted);
      expect(failure.latenessMs, 7000);
    });

    test(
      'REQ-ALM-023 a receiver without audio is a no-go naming the stage',
      () {
        final events = [
          scheduled(id(1), SpikeLabels.androidExact, 'reboot_locked'),
          presented(id(1), SpikeLabels.receiver, 100),
        ];
        final failure =
            verdictOf<SpikeNoGo>(
                  evaluate(events, nowUtcMs: now),
                  SpikePath.androidExactFgs,
                ).failures.single
                as NoAudio;
        expect(failure.lastStage, SpikeLabels.receiver);
      },
    );

    test('REQ-ALM-020 a missed entry fails only once it is 30 min overdue', () {
      final events = [scheduled(id(1), SpikeLabels.androidExact, 'doze')];
      expect(
        verdictOf<SpikeInsufficientEvidence>(
          evaluate(events, nowUtcMs: t0 + 29 * 60000),
          SpikePath.androidExactFgs,
        ).missing['doze'],
        3,
      );
      expect(
        verdictOf<SpikeNoGo>(
          evaluate(events, nowUtcMs: t0 + 30 * 60000),
          SpikePath.androidExactFgs,
        ).failures.single,
        isA<NotDelivered>(),
      );
    });

    test('REQ-ALM-023 a tester who did not hear it makes a no-go', () {
      final events = [
        ...passingAndroidRun(),
        observed(SpikeLabels.notHeard, entryId: id(1)),
      ];
      expect(
        verdictOf<SpikeNoGo>(
          evaluate(events, nowUtcMs: now),
          SpikePath.androidExactFgs,
        ).failures.single,
        isA<NotHeard>(),
      );
    });

    test('REQ-ALM-020 a missing scenario is counted, not passed', () {
      final events = passingAndroidRun()
          .where((e) => e.attrs.state != 'battery_saver')
          .toList();
      final verdict = verdictOf<SpikeInsufficientEvidence>(
        evaluate(events, nowUtcMs: now),
        SpikePath.androidExactFgs,
      );
      // The receipts of the dropped entries no longer have a scheduled entry.
      expect(verdict.missing, {'battery_saver': 3});
    });
  });

  group('Android inexact fallback', () {
    test('REQ-ALM-027 a notification within 15 min passes; later fails', () {
      final events = [
        for (var n = 1; n <= 3; n++) ...[
          scheduled(id(n), SpikeLabels.androidInexact, 'exact_revoked'),
          presented(id(n), SpikeLabels.notificationPosted, n * 4 * 60000),
        ],
      ];
      expect(
        verdictOf<SpikeGo>(
          evaluate(events, nowUtcMs: now),
          SpikePath.androidInexactFallback,
        ).entries,
        3,
      );
      final late = [
        ...events,
        scheduled(id(9), SpikeLabels.androidInexact, 'exact_revoked'),
        presented(id(9), SpikeLabels.notificationPosted, 16 * 60000),
      ];
      expect(
        verdictOf<SpikeNoGo>(
          evaluate(late, nowUtcMs: now),
          SpikePath.androidInexactFallback,
        ).failures.single,
        isA<DeliveredLate>(),
      );
    });
  });

  group('iOS AlarmKit', () {
    List<EventLogEntry> alarmKitRun({required bool alerting}) {
      var n = 0;
      return [
        for (final scenario in const SpikeCriteria().iosScenarios)
          for (var run = 0; run < 3; run++)
            ...() {
              final entry = id(++n);
              return [
                scheduled(entry, SpikeLabels.iosAlarmKit, scenario),
                if (alerting)
                  presented(entry, SpikeLabels.alarmKitAlerting, 300)
                else
                  dismissed(entry, SpikeLabels.userStop),
              ];
            }(),
      ];
    }

    test('REQ-ALM-030 the Stop receipt alone proves delivery', () {
      for (final alerting in [true, false]) {
        expect(
          verdictOf<SpikeGo>(
            evaluate(alarmKitRun(alerting: alerting), nowUtcMs: now),
            SpikePath.iosAlarmKitDelivery,
          ).entries,
          15,
        );
      }
    });

    test('REQ-ALM-030 not heard under the silent switch is a no-go', () {
      final events = [
        ...alarmKitRun(alerting: true),
        observed(SpikeLabels.notHeard, entryId: id(10)),
      ];
      expect(
        verdictOf<SpikeNoGo>(
          evaluate(events, nowUtcMs: now),
          SpikePath.iosAlarmKitDelivery,
        ).failures.single,
        isA<NotHeard>(),
      );
    });

    test('REQ-ALM-034 long audio: three full plays go, any cut is no-go', () {
      final full = [
        for (var n = 0; n < 3; n++)
          observed(SpikeLabels.longAudioFull, durationMs: 180000),
      ];
      expect(
        evaluate(full, nowUtcMs: now)[SpikePath.iosAlarmKitLongAudio.index],
        isA<SpikeGo>(),
      );
      final cut = [
        ...full,
        observed(SpikeLabels.longAudioCut, durationMs: 30000),
      ];
      final failure =
          verdictOf<SpikeNoGo>(
                evaluate(cut, nowUtcMs: now),
                SpikePath.iosAlarmKitLongAudio,
              ).failures.single
              as AudioCut;
      expect(failure.heardMs, 30000);
    });
  });

  group('iOS notification budget', () {
    test('REQ-ALM-032 64 pending requests is a go, anything else no-go', () {
      expect(
        evaluate([
          observed(SpikeLabels.pendingBudget, count: 64),
        ], nowUtcMs: now)[SpikePath.iosNotificationBudget.index],
        isA<SpikeGo>(),
      );
      final failure =
          verdictOf<SpikeNoGo>(
                evaluate([
                  observed(SpikeLabels.pendingBudget, count: 70),
                ], nowUtcMs: now),
                SpikePath.iosNotificationBudget,
              ).failures.single
              as BudgetMismatch;
      expect((failure.pending, failure.budget), (70, 64));
    });
  });

  test('REQ-ALM-041 the run reads the events.jsonl wire form', () {
    final lines = [
      for (final e in passingAndroidRun()) jsonEncode(e.toJson()),
    ];
    final events = [
      for (final line in lines)
        EventLogEntry.fromJson(jsonDecode(line) as Map<String, Object?>),
    ];
    expect(
      evaluate(events, nowUtcMs: now)[SpikePath.androidExactFgs.index],
      isA<SpikeGo>(),
    );
  });
}
