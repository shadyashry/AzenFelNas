import 'package:daily_muslim/features/athan/domain/native_event.dart';
import 'package:daily_muslim/features/athan/domain/platform_health.dart';
import 'package:dm_contracts/dm_contracts.dart';

/// Reads the native probes (§7.8 `health()`). Never throws: a missing host
/// is `PlatformHealth.unavailable`.
abstract interface class ReadPlatformHealth {
  /// The current report.
  Future<PlatformHealth> call();
}

/// Arms the Athan Test through the real path (§7.8 `startTest`).
abstract interface class ArmAthanTest {
  /// True when armed; false when refused or no host answered. Never throws.
  Future<bool> call({
    required String testId,
    required int fireInSeconds,
    required String soundId,
  });
}

/// Drains the native `events.jsonl` into the event log (§7.8
/// `drainEvents`, REQ-ALM-041); run on every start and before a Test answer
/// is stored.
abstract interface class DrainNativeEvents {
  /// Appends every valid `event_log.v1` line to the event log and returns
  /// them, oldest first; empty when no host answered. Never throws; invalid
  /// lines are dropped.
  Future<List<NativeEvent>> call();
}

/// Hands a `SchedulePlan` to the native scheduler (ADR-002, §7.7
/// `applyPlan`). The host replaces its stored plan whole (write, then
/// rename) and re-arms from it, so it holds either the old plan or the new
/// one, never a mix. A plan older than the stored generation is refused;
/// the same generation is written again (`PlanStore`, §7.8).
abstract interface class ApplySchedulePlan {
  /// True when the host stored and armed [plan]; false when it refused or
  /// no host answered, and its previous plan is still armed. Never throws.
  Future<bool> call(SchedulePlan plan);
}
