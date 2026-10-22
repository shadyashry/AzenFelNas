import 'package:dm_packages/src/client/network_kind.dart';
import 'package:dm_packages/src/tuf/target_priority_code.dart';
import 'package:dm_packages/src/tuf/tuf_target.dart';

/// When the client syncs and what it may download (REQ-PKG-004, §7.4).
/// Pure.
final class SyncPolicy {
  /// The policy of §7.4.
  const new();

  /// At most one sync per 6 h, counted from the last attempt.
  static const Duration interval = Duration(hours: 6);

  /// The largest metadata file fetched (§7.4: metadata ≤ 50 kB).
  static const int maxMetadataBytes = 50 * 1000;

  /// Payloads above this size wait for an unmetered network unless urgent.
  static const int largePayloadBytes = 2 * 1000 * 1000;

  /// The largest payload a `.dmpkg` may inflate to.
  static const int maxInflatedBytes = 64 * 1024 * 1024;

  /// Whether a sync may start at [nowUtcMs] after one at [lastSyncUtcMs].
  /// A clock that went backwards allows one at once.
  bool due({required int lastSyncUtcMs, required int nowUtcMs}) =>
      lastSyncUtcMs == 0 ||
      nowUtcMs < lastSyncUtcMs ||
      nowUtcMs - lastSyncUtcMs >= interval.inMilliseconds;

  /// Whether [target] may download on [network] now.
  bool mayDownload(TufTarget target, NetworkKind network) => switch (network) {
    NetworkKind.offline => false,
    NetworkKind.unmetered => true,
    NetworkKind.metered =>
      target.length <= largePayloadBytes ||
          target.custom.priority == TargetPriorityCode.urgent,
  };
}
