// S19 spike verdict (DESIGN.md §13 S19, docs/adr/ADR-025-s19-native-spike.md).
//
//   cd apps/mobile && dart run tool/spike_verdict.dart <events.jsonl>... [--now <utcMs>]
//
// Reads the events.jsonl files pulled from the test devices and prints one
// go / no-go line per delivery path; exits 0 only when every path is a go.
import 'dart:convert';
import 'dart:io';

import 'package:daily_muslim/features/delivery_spike/application/evaluate_spike_run.dart';
import 'package:daily_muslim/features/delivery_spike/domain/spike_verdict.dart';
import 'package:dm_contracts/dm_contracts.dart';

void main(List<String> args) {
  final nowAt = args.indexOf('--now');
  final now = nowAt >= 0 && nowAt + 1 < args.length
      ? int.parse(args[nowAt + 1])
      : DateTime.now().millisecondsSinceEpoch;
  final files = [
    for (var i = 0; i < args.length; i++)
      if (i != nowAt && i != nowAt + 1) args[i],
  ];
  if (files.isEmpty) {
    stderr.writeln('usage: spike_verdict.dart <events.jsonl>... [--now <ms>]');
    exitCode = 64;
    return;
  }
  final events = [
    for (final file in files)
      for (final line in File(file).readAsLinesSync())
        if (line.trim().isNotEmpty)
          EventLogEntry.fromJson(jsonDecode(line) as Map<String, Object?>),
  ];
  final verdicts = const EvaluateSpikeRun()(events, nowUtcMs: now);
  for (final verdict in verdicts) {
    stdout.writeln('${verdict.path.name}: ${describe(verdict)}');
  }
  exitCode = verdicts.every((v) => v is SpikeGo) ? 0 : 1;
}

String describe(SpikeVerdict verdict) => switch (verdict) {
  SpikeGo(:final entries) => 'GO ($entries judged)',
  SpikeNoGo(:final failures) => 'NO-GO: ${failures.map(failure).join('; ')}',
  SpikeInsufficientEvidence(:final missing) =>
    'INSUFFICIENT: needs '
        '${missing.entries.map((e) => '${e.value} × ${e.key}').join(', ')}',
};

String failure(SpikeFailure f) => switch (f) {
  NotDelivered(:final entryId, :final scenario) =>
    '$entryId not delivered ($scenario)',
  DeliveredLate(:final entryId, :final stage, :final latenessMs) =>
    '$entryId $stage late by $latenessMs ms',
  ForegroundServiceDenied(:final entryId) => '$entryId service start refused',
  NoAudio(:final entryId, :final lastStage) =>
    '$entryId stopped after $lastStage',
  NotHeard(:final entryId) => '$entryId not heard',
  AudioCut(:final heardMs) => 'long clip cut after $heardMs ms',
  BudgetMismatch(:final pending, :final budget) =>
    '$pending pending, expected $budget',
};
