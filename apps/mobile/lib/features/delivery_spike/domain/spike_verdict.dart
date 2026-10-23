import 'package:daily_muslim/features/delivery_spike/domain/spike_protocol.dart';

/// The go / no-go of one [SpikePath] (DESIGN.md §13 S19 done-test).
sealed class SpikeVerdict {
  const new(this.path);

  /// The path judged.
  final SpikePath path;
}

/// Every required scenario has enough due entries and all of them passed.
final class SpikeGo extends SpikeVerdict {
  /// A go for [path] over [entries] judged entries.
  const new(super.path, {required this.entries});

  /// Due entries (or observations) judged.
  final int entries;
}

/// At least one due entry failed.
final class SpikeNoGo extends SpikeVerdict {
  /// A no-go for [path].
  const new(super.path, {required this.failures});

  /// Why, one per failed entry or observation.
  final List<SpikeFailure> failures;
}

/// Nothing failed, but a required scenario lacks due entries.
final class SpikeInsufficientEvidence extends SpikeVerdict {
  /// Not decidable yet for [path].
  const new(super.path, {required this.missing});

  /// Scenario (or observation) → how many more due entries it needs.
  final Map<String, int> missing;
}

/// Why an entry or observation failed.
sealed class SpikeFailure {
  const new(this.entryId);

  /// The entry, or `null` for an observation without one.
  final String? entryId;
}

/// No receipt by `missedAfterMs` after the trigger.
final class NotDelivered extends SpikeFailure {
  /// [entryId] was never delivered.
  const new(String super.entryId, {required this.scenario});

  /// Its scenario.
  final String scenario;
}

/// A stage ran later than allowed.
final class DeliveredLate extends SpikeFailure {
  /// [entryId]'s [stage] ran [latenessMs] after the trigger.
  const new(
    String super.entryId, {
    required this.stage,
    required this.latenessMs,
  });

  /// The stage label (`SpikeLabels`).
  final String stage;

  /// How late.
  final int latenessMs;
}

/// The receiver ran but the foreground service could not start.
final class ForegroundServiceDenied extends SpikeFailure {
  /// [entryId]'s service start was refused.
  const new(String super.entryId);
}

/// The receiver ran but neither the service nor audio followed.
final class NoAudio extends SpikeFailure {
  /// [entryId] reached [lastStage] and no further.
  const new(String super.entryId, {required this.lastStage});

  /// The last stage recorded.
  final String lastStage;
}

/// The tester reported not hearing a delivered entry.
final class NotHeard extends SpikeFailure {
  /// [entryId] was not heard.
  const new(String super.entryId);
}

/// A long clip stopped before its end.
final class AudioCut extends SpikeFailure {
  /// The clip stopped after [heardMs].
  const new({required this.heardMs}) : super(null);

  /// How long it was heard.
  final int heardMs;
}

/// iOS kept more (or fewer) pending requests than the budget.
final class BudgetMismatch extends SpikeFailure {
  /// [pending] requests were pending; [budget] was expected.
  const new({required this.pending, required this.budget}) : super(null);

  /// Observed pending count.
  final int pending;

  /// Expected budget.
  final int budget;
}
