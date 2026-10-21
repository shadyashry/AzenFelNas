package app.dailymuslim.athan.codes

import kotlinx.serialization.Serializable

/**
 * Event-log codes of DESIGN.md Appendix J.
 *
 * Mirrors DESIGN.md Appendix J and `dm_core_types` verbatim (REQ-ERR-002); entry names are the wire names.
 */
@Serializable
internal enum class EventCode {
    APP_START,
    PKG_ACTIVATED,
    PKG_ROLLED_BACK,
    PLAN_BUILT,
    PLAN_APPLIED,
    ALARM_SCHEDULED,
    ALARM_PRESENTED,
    ALARM_DISMISSED,
    HEALTH_EVALUATED,
    TEST_STARTED,
    TEST_RESULT,
    CONTEXT_CHANGED,
    SYNC_RESULT,
    RETENTION_RUN,
}
