/// Event-log codes of DESIGN.md Appendix J, used by the on-device event log.
///
/// Mirrored verbatim in Kotlin and Swift via `dm_contracts` (REQ-ERR-002);
/// [wire] is the stable cross-language name and never changes for a value.
enum EventCode {
  /// `APP_START`.
  appStart('APP_START'),

  /// `PKG_ACTIVATED`.
  pkgActivated('PKG_ACTIVATED'),

  /// `PKG_ROLLED_BACK`.
  pkgRolledBack('PKG_ROLLED_BACK'),

  /// `PLAN_BUILT`.
  planBuilt('PLAN_BUILT'),

  /// `PLAN_APPLIED`.
  planApplied('PLAN_APPLIED'),

  /// `ALARM_SCHEDULED`.
  alarmScheduled('ALARM_SCHEDULED'),

  /// `ALARM_PRESENTED`.
  alarmPresented('ALARM_PRESENTED'),

  /// `ALARM_DISMISSED`.
  alarmDismissed('ALARM_DISMISSED'),

  /// `HEALTH_EVALUATED`.
  healthEvaluated('HEALTH_EVALUATED'),

  /// `TEST_STARTED`.
  testStarted('TEST_STARTED'),

  /// `TEST_RESULT`.
  testResult('TEST_RESULT'),

  /// `CONTEXT_CHANGED`.
  contextChanged('CONTEXT_CHANGED'),

  /// `SYNC_RESULT`.
  syncResult('SYNC_RESULT'),

  /// `RETENTION_RUN`.
  retentionRun('RETENTION_RUN');

  new(this.wire);

  /// The cross-language name from DESIGN.md Appendix J.
  final String wire;

  /// The code whose [wire] name is [wire], or `null` if none is.
  static EventCode? fromWire(String wire) => _byWire[wire];

  static final Map<String, EventCode> _byWire = {
    for (final code in values) code.wire: code,
  };
}
