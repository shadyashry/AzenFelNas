// Pigeon source of the Athan platform contract (DESIGN.md §7.8, §15 D83).
// Generate with `melos run gen:pigeon`; the outputs are committed (§15 D22).
// Pigeon's parser reads classic constructors only.
// ignore_for_file: unnecessary_type_name_in_constructor

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/athan_scheduler_api.g.dart',
    kotlinOut: '../../apps/mobile/android/app/src/main/kotlin/app/dailymuslim/pigeon/AthanSchedulerApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'app.dailymuslim.pigeon'),
    swiftOut: '../../apps/mobile/ios/Runner/Pigeon/AthanSchedulerApi.g.swift',
  ),
)
/// Overall Athan readiness as the platform evaluated it (§8.3).
enum HealthState { ready, limited, notReady, unknown }

/// Why Health is not `ready` (§7.8); names equal the Kotlin and Swift labels.
enum HealthReason {
  needsNotificationPermission,
  needsExactAlarmPermission,
  needsAlarmKitAuthorization,
  mutedChannel,
  batteryRestricted,
  stalePlan,
  horizonEnding,
  failedTest,
  clockSkew,
  noSoundAsset,
  inexactFallback,
  unverifiableDelivery,
  forceStoppedPreviously,
}

/// One platform probe; [positive] is null when the platform cannot tell.
class ProbeResult {
  ProbeResult({required this.name, required this.positive, this.detail});

  String name;
  bool? positive;
  String? detail;
}

/// The native Health evaluation (§7.8); Dart re-derives the state from
/// [probes] (§15 D83) and keeps [state] only for diagnostics.
class AthanHealthReport {
  AthanHealthReport({
    required this.state,
    required this.reasons,
    required this.probes,
    required this.evaluatedAtUtcMs,
    required this.platformPath,
  });

  HealthState state;
  List<HealthReason> reasons;
  List<ProbeResult> probes;
  int evaluatedAtUtcMs;

  /// `androidExact | androidInexact | iosAlarmKit | iosNotification`.
  String platformPath;
}

/// The native Athan layer (§8.1, §8.2). Every call is idempotent.
@HostApi()
abstract class AthanSchedulerApi {
  /// Persists and arms a `schedule_plan.v1` document (idempotent by entry
  /// id + generation); the outcome is a `PLAN_APPLIED` event.
  @async
  void reconcile(String schedulePlanJson);

  /// Disarms entries of plans older than [generation].
  @async
  void cancelGenerationsBelow(int generation);

  /// Evaluates every probe now.
  @async
  AthanHealthReport health();

  /// Arms the Athan Test through the real path (REQ-ALM-040); false when
  /// the platform refused to arm it.
  @async
  bool startTest(String testId, int fireInSeconds, String soundId);

  /// Drains `events.jsonl`: one `event_log.v1` JSON document per item,
  /// receipts and system events included (REQ-ALM-041).
  List<String> drainEvents();
}
