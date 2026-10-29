package app.azenfelnas.athan.schedule

/**
 * Why the alarms are reconciled. [label] is written to `attrs.reason` of `PLAN_APPLIED`; for system events it is
 * the `SystemEventKind` wire name of DESIGN.md §7.8, so the bridge can drain them as system events (REQ-ALM-041).
 */
internal enum class ReconcileCause(
    val label: String,
) {
    BOOT("boot"),
    LOCKED_BOOT("lockedBoot"),
    TIME_CHANGED("timeChanged"),
    TIMEZONE_CHANGED("timezoneChanged"),
    PACKAGE_REPLACED("packageReplaced"),
    PERMISSION_CHANGED("permissionChanged"),
    PLAN_APPLIED("planApplied"),

    /** An alarm fired; the arming window rolls forward. */
    ALARM_FIRED("alarmFired"),
}
