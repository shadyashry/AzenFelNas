package app.dailymuslim.athan.selftest

import app.dailymuslim.athan.codes.EventCode
import app.dailymuslim.athan.plan.EventAttrs
import app.dailymuslim.athan.plan.EventLevel
import app.dailymuslim.athan.plan.EventsStore
import app.dailymuslim.athan.schedule.AlarmPort
import app.dailymuslim.athan.schedule.AlarmTrigger
import app.dailymuslim.athan.schedule.ArmResult
import app.dailymuslim.athan.schedule.ArmedAlarm
import app.dailymuslim.athan.schedule.DeliveryMode
import app.dailymuslim.athan.schedule.ExactAlarmGate
import app.dailymuslim.athan.schedule.UtcClock

/**
 * The bridge's `startTest(testId, fireInSeconds, soundId)` (DESIGN.md §7.8, §8.3): arms the Athan Test through
 * the same path as a real Athan, `setAlarmClock` when exact alarms are allowed, else the inexact fallback
 * (REQ-ALM-040). `heardByUser` is Dart's to record from the user's answer.
 */
internal class StartAthanTest(
    private val alarms: AlarmPort,
    private val exactGate: ExactAlarmGate,
    private val clock: UtcClock,
    private val events: EventsStore,
) {
    operator fun invoke(
        testId: String,
        fireInSeconds: Int,
        soundId: String,
    ): ArmResult {
        val mode = if (exactGate.canScheduleExact()) DeliveryMode.ALARM_CLOCK else DeliveryMode.INEXACT_IDLE
        val trigger = AlarmTrigger.Test(testId, soundId)
        val result = alarms.arm(ArmedAlarm(trigger, clock.nowUtcMs() + fireInSeconds * MS_PER_SECOND, mode))
        events.append(
            EventCode.TEST_STARTED,
            EventAttrs(entryId = trigger.alarmId, state = mode.name, durationMs = fireInSeconds * MS_PER_SECOND),
            if (result is ArmResult.Armed) EventLevel.INFO else EventLevel.ERROR,
        )
        return result
    }

    private companion object {
        const val MS_PER_SECOND: Long = 1000L
    }
}
