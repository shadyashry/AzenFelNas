package app.azenfelnas.athan.schedule

import app.azenfelnas.athan.plan.EntryKind
import app.azenfelnas.athan.plan.SchedulePlan

/**
 * Which plan entries are armed now (D81): the next [capacity] future entries by fire instant, so the app stays
 * well under the platform's per-app alarm cap. Every fire and every system event reconciles again, which rolls
 * the window forward.
 */
internal class ArmingWindow(
    private val capacity: Int = DEFAULT_CAPACITY,
) {
    /** Alarms for [plan] at [nowUtcMs]; ATHAN entries use `setAlarmClock` when [exactAllowed] (REQ-ALM-020). */
    fun alarms(
        plan: SchedulePlan,
        nowUtcMs: Long,
        exactAllowed: Boolean,
    ): List<ArmedAlarm> =
        plan.entries
            .filter { it.fireAtUtcMs > nowUtcMs }
            .sortedWith(compareBy({ it.fireAtUtcMs }, { it.id }))
            .take(capacity)
            .map { entry ->
                ArmedAlarm(
                    trigger = AlarmTrigger.PlanEntry(entry.id),
                    fireAtUtcMs = entry.fireAtUtcMs,
                    mode = modeOf(entry.kind, exactAllowed),
                )
            }

    private fun modeOf(
        kind: EntryKind,
        exactAllowed: Boolean,
    ): DeliveryMode =
        when {
            !exactAllowed -> DeliveryMode.INEXACT_IDLE
            kind == EntryKind.ATHAN -> DeliveryMode.ALARM_CLOCK
            else -> DeliveryMode.EXACT_IDLE
        }

    internal companion object {
        /** Armed alarms at most; Android 12+ caps an app at 500 pending alarms (D81). */
        const val DEFAULT_CAPACITY: Int = 200
    }
}
