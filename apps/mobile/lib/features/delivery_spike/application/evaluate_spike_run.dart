import 'package:daily_muslim/features/delivery_spike/domain/spike_protocol.dart';
import 'package:daily_muslim/features/delivery_spike/domain/spike_verdict.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Judges an S19 spike run: the `events.jsonl` lines pulled from the test
/// devices → one [SpikeVerdict] per [SpikePath], in enum order (DESIGN.md
/// §13 S19 done-test, §15 D79).
///
/// An entry is judged once it has a receipt or once `missedAfterMs` has
/// passed since its trigger at [call]'s `nowUtcMs`; younger entries without
/// a receipt are pending and ignored. Pure.
final class EvaluateSpikeRun {
  /// The use case under [criteria].
  const new({this.criteria = const SpikeCriteria()});

  /// The thresholds.
  final SpikeCriteria criteria;

  /// One verdict per path for [events], judged at [nowUtcMs].
  List<SpikeVerdict> call(
    Iterable<EventLogEntry> events, {
    required int nowUtcMs,
  }) {
    final run = _Run.of(events);
    return [
      for (final path in SpikePath.values)
        switch (path) {
          SpikePath.androidExactFgs => _judgeEntries(
            path,
            run,
            nowUtcMs,
            label: SpikeLabels.androidExact,
            scenarios: criteria.androidScenarios,
            judge: _judgeExactFgs,
          ),
          SpikePath.androidInexactFallback => _judgeEntries(
            path,
            run,
            nowUtcMs,
            label: SpikeLabels.androidInexact,
            scenarios: criteria.androidFallbackScenarios,
            judge: _judgeInexact,
          ),
          SpikePath.iosAlarmKitDelivery => _judgeEntries(
            path,
            run,
            nowUtcMs,
            label: SpikeLabels.iosAlarmKit,
            scenarios: criteria.iosScenarios,
            judge: _judgeAlarmKit,
          ),
          SpikePath.iosAlarmKitLongAudio => _judgeLongAudio(run),
          SpikePath.iosNotificationBudget => _judgeBudget(run),
        },
    ];
  }

  SpikeVerdict _judgeEntries(
    SpikePath path,
    _Run run,
    int nowUtcMs, {
    required String label,
    required Set<String> scenarios,
    required SpikeFailure? Function(_Entry) judge,
  }) {
    final failures = <SpikeFailure>[];
    final passed = <String, int>{};
    for (final entry in run.entries.values.where((e) => e.path == label)) {
      final due = nowUtcMs - entry.triggerUtcMs >= criteria.missedAfterMs;
      if (entry.stages.isEmpty && entry.dismissals.isEmpty) {
        if (due) {
          failures.add(NotDelivered(entry.id, scenario: entry.scenario));
        }
        continue;
      }
      final failure = entry.notHeard ? NotHeard(entry.id) : judge(entry);
      if (failure != null) {
        failures.add(failure);
      } else {
        passed.update(entry.scenario, (n) => n + 1, ifAbsent: () => 1);
      }
    }
    if (failures.isNotEmpty) return SpikeNoGo(path, failures: failures);
    final missing = {
      for (final scenario in scenarios)
        if ((passed[scenario] ?? 0) < criteria.minRunsPerScenario)
          scenario: criteria.minRunsPerScenario - (passed[scenario] ?? 0),
    };
    if (missing.isNotEmpty) {
      return SpikeInsufficientEvidence(path, missing: missing);
    }
    return SpikeGo(
      path,
      entries: passed.values.fold(0, (sum, n) => sum + n),
    );
  }

  SpikeFailure? _judgeExactFgs(_Entry entry) {
    if (entry.stages.containsKey(SpikeLabels.fgsDenied)) {
      return ForegroundServiceDenied(entry.id);
    }
    for (final stage in [SpikeLabels.fgsStarted, SpikeLabels.audioStarted]) {
      final lateness = entry.stages[stage];
      if (lateness == null) {
        return NoAudio(entry.id, lastStage: entry.lastStage);
      }
      if (lateness > criteria.maxExactLatenessMs) {
        return DeliveredLate(entry.id, stage: stage, latenessMs: lateness);
      }
    }
    return null;
  }

  SpikeFailure? _judgeInexact(_Entry entry) {
    final lateness = entry.stages[SpikeLabels.notificationPosted];
    if (lateness == null) {
      return NoAudio(entry.id, lastStage: entry.lastStage);
    }
    if (lateness > criteria.maxInexactLatenessMs) {
      return DeliveredLate(
        entry.id,
        stage: SpikeLabels.notificationPosted,
        latenessMs: lateness,
      );
    }
    return null;
  }

  SpikeFailure? _judgeAlarmKit(_Entry entry) {
    // AlarmKit alerts while the app is dead, so the Stop intent's receipt is
    // proof of delivery on its own; lateness is known only when the app saw
    // the `alerting` state.
    final lateness = entry.stages[SpikeLabels.alarmKitAlerting];
    if (lateness != null && lateness > criteria.maxExactLatenessMs) {
      return DeliveredLate(
        entry.id,
        stage: SpikeLabels.alarmKitAlerting,
        latenessMs: lateness,
      );
    }
    if (lateness == null && !entry.dismissals.contains(SpikeLabels.userStop)) {
      return NoAudio(entry.id, lastStage: entry.lastStage);
    }
    return null;
  }

  SpikeVerdict _judgeLongAudio(_Run run) {
    const path = SpikePath.iosAlarmKitLongAudio;
    final cuts = [
      for (final ms in run.observations[SpikeLabels.longAudioCut] ?? <int>[])
        AudioCut(heardMs: ms),
    ];
    if (cuts.isNotEmpty) return SpikeNoGo(path, failures: cuts);
    final full = run.observations[SpikeLabels.longAudioFull]?.length ?? 0;
    if (full < criteria.minLongAudioRuns) {
      return SpikeInsufficientEvidence(
        path,
        missing: {SpikeLabels.longAudioFull: criteria.minLongAudioRuns - full},
      );
    }
    return SpikeGo(path, entries: full);
  }

  SpikeVerdict _judgeBudget(_Run run) {
    const path = SpikePath.iosNotificationBudget;
    final counts = run.observations[SpikeLabels.pendingBudget] ?? <int>[];
    if (counts.isEmpty) {
      return const SpikeInsufficientEvidence(
        path,
        missing: {SpikeLabels.pendingBudget: 1},
      );
    }
    final wrong = [
      for (final pending in counts)
        if (pending != criteria.notificationBudget)
          BudgetMismatch(pending: pending, budget: criteria.notificationBudget),
    ];
    if (wrong.isNotEmpty) return SpikeNoGo(path, failures: wrong);
    return SpikeGo(path, entries: counts.length);
  }
}

/// One scheduled spike entry and its receipts.
final class _Entry {
  new({
    required this.id,
    required this.path,
    required this.scenario,
    required this.triggerUtcMs,
  });

  final String id;
  final String path;
  final String scenario;
  final int triggerUtcMs;

  /// `ALARM_PRESENTED` stage → lateness ms, in arrival order.
  final Map<String, int> stages = {};

  /// `ALARM_DISMISSED` reasons.
  final Set<String> dismissals = {};

  bool notHeard = false;

  String get lastStage => stages.isEmpty ? 'none' : stages.keys.last;
}

/// The events grouped by entry and by observation.
final class _Run {
  new _(this.entries, this.observations);

  factory of(Iterable<EventLogEntry> events) {
    final entries = <String, _Entry>{};
    final observations = <String, List<int>>{};
    final receipts = <EventLogEntry>[];
    for (final event in events) {
      final attrs = event.attrs;
      final id = attrs.entryId;
      final reason = attrs.reason;
      final delay = attrs.durationMs;
      final scenario = attrs.state;
      if (event.code == EventCode.alarmScheduled &&
          id != null &&
          reason != null &&
          delay != null &&
          scenario != null) {
        entries[id] = _Entry(
          id: id,
          path: reason,
          scenario: scenario,
          triggerUtcMs: event.utcMs + delay,
        );
      } else {
        receipts.add(event);
      }
    }
    for (final event in receipts) {
      final attrs = event.attrs;
      final reason = attrs.reason;
      if (reason == null) continue;
      final entry = entries[attrs.entryId];
      switch (event.code) {
        case EventCode.alarmPresented:
          entry?.stages[reason] = attrs.durationMs ?? 0;
        case EventCode.alarmDismissed:
          entry?.dismissals.add(reason);
        case EventCode.testResult:
          if (reason == SpikeLabels.notHeard) {
            entry?.notHeard = true;
          } else if (reason == SpikeLabels.pendingBudget) {
            final count = attrs.count;
            if (count != null) {
              (observations[reason] ??= []).add(count);
            }
          } else {
            (observations[reason] ??= []).add(attrs.durationMs ?? 0);
          }
        case _:
          break;
      }
    }
    return _Run._(entries, observations);
  }

  final Map<String, _Entry> entries;
  final Map<String, List<int>> observations;
}
