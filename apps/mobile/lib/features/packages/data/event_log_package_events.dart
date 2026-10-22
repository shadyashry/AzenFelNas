import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';

/// [RecordPackageEvent] as `event_log.v1` entries (Appendix J):
/// `PKG_ACTIVATED`, `PKG_ROLLED_BACK` and `SYNC_RESULT` with `packageType`,
/// `version`, `reason`, `count` and `code` only (REQ-PRIV-001). A version
/// outside the schema's pattern is left out rather than logged.
final class EventLogPackageEvents implements RecordPackageEvent {
  /// Appends every entry with [_append] (the S16 event-log ring buffer).
  const new(this._append);

  final Future<void> Function(EventLogEntry entry) _append;

  @override
  Future<void> record(PackageEvent event) => _append(entryOf(event));

  /// The Appendix J entry of [event].
  static EventLogEntry entryOf(PackageEvent event) => switch (event) {
    PackageActivated(:final type, :final version, :final source) =>
      EventLogEntry(
        utcMs: event.utcMs,
        level: EventLogLevel.info,
        code: EventCode.pkgActivated,
        attrs: EventLogAttrs(
          packageType: type.wire,
          version: _loggable(version),
          reason: source.wire,
        ),
      ),
    PackageRolledBack(:final type, :final toVersion) => EventLogEntry(
      utcMs: event.utcMs,
      level: EventLogLevel.warn,
      code: EventCode.pkgRolledBack,
      attrs: EventLogAttrs(
        packageType: type.wire,
        version: _loggable(toVersion),
      ),
    ),
    SyncFinished(:final outcome, :final activated, :final failure) =>
      EventLogEntry(
        utcMs: event.utcMs,
        level: failure == null ? EventLogLevel.info : EventLogLevel.warn,
        code: EventCode.syncResult,
        attrs: EventLogAttrs(reason: outcome, count: activated, code: failure),
      ),
    FreshnessUnverified(:final expiredRoles) => EventLogEntry(
      utcMs: event.utcMs,
      level: EventLogLevel.warn,
      code: EventCode.syncResult,
      attrs: EventLogAttrs(
        reason: 'freshness_unverified',
        count: expiredRoles,
        code: FailureCode.pkgExpiredWarning,
      ),
    ),
  };

  static String? _loggable(String version) =>
      _versionPattern.hasMatch(version) ? version : null;

  /// `event_log.v1` `attrs.version`.
  static final RegExp _versionPattern = RegExp(
    r'^(\d{4}\.\d{1,2}\.\d+|\d{4}[a-z]|\d+\.\d+\.\d+)$',
  );
}
