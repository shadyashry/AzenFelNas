import 'package:dm_packages/src/client/active_package.dart';
import 'package:dm_packages/src/client/sync_outcome.dart';
import 'package:dm_packages/src/verify/freshness_warning.dart';
import 'package:dm_packages/src/verify/package_failure.dart';
import 'package:meta/meta.dart';

/// What one `SyncPackages` run did.
@immutable
final class SyncReport {
  /// The report.
  new({
    required this.outcome,
    List<ActivePackage> activated = const [],
    List<String> deferred = const [],
    Map<String, PackageFailure> targetFailures = const {},
    List<FreshnessWarning> warnings = const [],
    this.failure,
    this.serverDateUtcMs,
  }) : activated = List.unmodifiable(activated),
       deferred = List.unmodifiable(deferred),
       targetFailures = Map.unmodifiable(targetFailures),
       warnings = List.unmodifiable(warnings);

  /// How the sync ended.
  final SyncOutcome outcome;

  /// The packages that became active.
  final List<ActivePackage> activated;

  /// Target names left for an unmetered network (REQ-PKG-004).
  final List<String> deferred;

  /// Targets that were chosen but not activated, by name.
  final Map<String, PackageFailure> targetFailures;

  /// Expired metadata roles: `FRESHNESS_UNVERIFIED` (REQ-PKG-002).
  final List<FreshnessWarning> warnings;

  /// What stopped a [SyncOutcome.failed] sync.
  final PackageFailure? failure;

  /// The CDN `Date` header of `timestamp.json`, for the clock-integrity
  /// check of §7.6 (REQ-TIME-010); the caller passes it to
  /// `CheckClockIntegrity`. Never used to accept or reject anything.
  final int? serverDateUtcMs;

  @override
  String toString() =>
      'SyncReport(${outcome.wire}, activated ${activated.length}, '
      'deferred ${deferred.length}, failures ${targetFailures.length}, '
      'warnings ${warnings.length}, $failure)';
}
