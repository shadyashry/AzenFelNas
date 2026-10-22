import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/package_source.dart';
import 'package:dm_packages/src/client/package_type.dart';
import 'package:meta/meta.dart';

/// What the package client reports to the event log (Appendix J
/// `PKG_ACTIVATED`, `PKG_ROLLED_BACK`, `SYNC_RESULT`). No variant can hold
/// a coordinate or an identifier (REQ-PRIV-001).
@immutable
sealed class PackageEvent {
  const new({required this.utcMs});

  /// When it happened, UTC epoch milliseconds.
  final int utcMs;
}

/// [type] [version] became active.
final class PackageActivated extends PackageEvent {
  /// The event.
  const new({
    required super.utcMs,
    required this.type,
    required this.version,
    required this.source,
  });

  /// The package type.
  final PackageType type;

  /// The version now active.
  final String version;

  /// Where it came from.
  final PackageSource source;

  @override
  String toString() => 'PackageActivated(${type.wire}/$version)';
}

/// [type] went back from [fromVersion] to [toVersion].
final class PackageRolledBack extends PackageEvent {
  /// The event.
  const new({
    required super.utcMs,
    required this.type,
    required this.fromVersion,
    required this.toVersion,
  });

  /// The package type.
  final PackageType type;

  /// The version rolled back from.
  final String fromVersion;

  /// The version active again.
  final String toVersion;

  @override
  String toString() =>
      'PackageRolledBack(${type.wire}: $fromVersion → $toVersion)';
}

/// One sync ended: [outcome] (`activated`, `up_to_date`, `deferred`,
/// `skipped_interval`, `offline`, `failed`), [activated] packages, and the
/// [failure] code when one stopped it or a package.
final class SyncFinished extends PackageEvent {
  /// The event.
  const new({
    required super.utcMs,
    required this.outcome,
    required this.activated,
    this.failure,
  });

  /// The outcome name.
  final String outcome;

  /// How many packages became active.
  final int activated;

  /// The failure that stopped the sync or a package, if any.
  final FailureCode? failure;

  @override
  String toString() => 'SyncFinished($outcome, $activated, $failure)';
}

/// Signed metadata had expired: times keep working (REQ-PKG-002).
final class FreshnessUnverified extends PackageEvent {
  /// The event; [expiredRoles] is how many roles had expired.
  const new({required super.utcMs, required this.expiredRoles});

  /// The number of expired roles.
  final int expiredRoles;

  @override
  String toString() => 'FreshnessUnverified($expiredRoles)';
}
