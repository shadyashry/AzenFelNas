package app.azenfelnas.athan.schedule

/** Result of arming one alarm. */
internal sealed interface ArmResult {
    /** `AlarmManager` accepted the alarm. */
    data object Armed : ArmResult

    /** The platform refused it, e.g. exact alarms were revoked between the check and the call. */
    data class Refused(
        val reason: String,
    ) : ArmResult
}

/** The platform alarm service, as the reconciler needs it (ADR-012). */
internal interface AlarmPort {
    /** Arms [alarm], replacing an alarm with the same id. */
    fun arm(alarm: ArmedAlarm): ArmResult

    /** Cancels the alarm of [trigger]; a missing alarm is not an error. */
    fun disarm(trigger: AlarmTrigger)
}

/** Whether exact alarms may be scheduled now (`canScheduleExactAlarms`, always true below API 31). */
internal fun interface ExactAlarmGate {
    fun canScheduleExact(): Boolean
}

/** Wall-clock UTC epoch milliseconds. */
internal fun interface UtcClock {
    fun nowUtcMs(): Long
}
