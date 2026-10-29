package app.azenfelnas.athan.schedule

/** How one alarm is handed to `AlarmManager` (ADR-012, D81). */
internal enum class DeliveryMode {
    /** `setAlarmClock`: Doze-exempt, alarm icon, may start the playback service (REQ-ALM-020). */
    ALARM_CLOCK,

    /** `setExactAndAllowWhileIdle`: exact, for non-Athan entries while exact alarms are allowed. */
    EXACT_IDLE,

    /** `setAndAllowWhileIdle`: the inexact fallback when exact alarms are not allowed (REQ-ALM-027). */
    INEXACT_IDLE,
}

/** What fires: an entry of the persisted plan, its one snooze, or a user-started Athan Test (REQ-ALM-040). */
internal sealed interface AlarmTrigger {
    /** Id that derives the request code (REQ-ALM-021). */
    val alarmId: String

    /** Entry [entryId] of the persisted plan; it is looked up in the plan when it fires. */
    data class PlanEntry(
        val entryId: String,
    ) : AlarmTrigger {
        override val alarmId: String get() = entryId
    }

    /** The single snooze of [entryId] (REQ-ALM-042); a snoozed alarm offers no further snooze. */
    data class Snooze(
        val entryId: String,
    ) : AlarmTrigger {
        override val alarmId: String get() = SnoozeId.of(entryId)
    }

    /** Athan Test [testId] playing [soundId] through the real path (REQ-ALM-040). */
    data class Test(
        val testId: String,
        val soundId: String,
    ) : AlarmTrigger {
        override val alarmId: String get() = TestId.of(testId)
    }
}

/** One alarm to arm at the absolute instant [fireAtUtcMs] (REQ-ALM-001). */
internal data class ArmedAlarm(
    val trigger: AlarmTrigger,
    val fireAtUtcMs: Long,
    val mode: DeliveryMode,
)
