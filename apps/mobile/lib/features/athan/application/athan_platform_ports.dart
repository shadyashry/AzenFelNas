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

/// Drains the native `events.jsonl` (§7.8 `drainEvents`, REQ-ALM-041).
abstract interface class DrainNativeEvents {
  /// The valid `event_log.v1` entries since the last drain, oldest first;
  /// empty when no host answered. Never throws; invalid lines are dropped.
  Future<List<EventLogEntry>> call();
}
