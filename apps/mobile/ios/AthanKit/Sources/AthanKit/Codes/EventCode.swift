/// Event-log codes of DESIGN.md Appendix J.
///
/// Mirrors DESIGN.md Appendix J and `dm_core_types` verbatim (REQ-ERR-002); raw values are the wire names.
enum EventCode: String, Codable, CaseIterable, Sendable {
    case appStart = "APP_START"
    case pkgActivated = "PKG_ACTIVATED"
    case pkgRolledBack = "PKG_ROLLED_BACK"
    case planBuilt = "PLAN_BUILT"
    case planApplied = "PLAN_APPLIED"
    case alarmScheduled = "ALARM_SCHEDULED"
    case alarmPresented = "ALARM_PRESENTED"
    case alarmDismissed = "ALARM_DISMISSED"
    case healthEvaluated = "HEALTH_EVALUATED"
    case testStarted = "TEST_STARTED"
    case testResult = "TEST_RESULT"
    case contextChanged = "CONTEXT_CHANGED"
    case syncResult = "SYNC_RESULT"
    case retentionRun = "RETENTION_RUN"
}
