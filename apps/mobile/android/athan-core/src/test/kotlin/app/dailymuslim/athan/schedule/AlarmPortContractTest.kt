package app.dailymuslim.athan.schedule

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Test

/**
 * The [AlarmPort] contract every implementation keeps: arming the same id replaces, disarming a missing alarm is
 * not an error. Runs against the fake here; `AndroidAlarmPort` runs it in the S21 device suite
 * (`docs/test-plans/s21-android-athan-device-suite.md`, D81).
 */
internal abstract class AlarmPortContract {
    abstract fun port(): AlarmPort

    abstract fun armedIds(): Set<String>

    private val alarm = ArmedAlarm(AlarmTrigger.PlanEntry("00000000000000aa"), 1_000L, DeliveryMode.ALARM_CLOCK)

    @Test
    fun `REQ-ALM-021 arming the same entry id twice keeps one alarm`() {
        val port = port()
        port.arm(alarm)
        val result = port.arm(alarm.copy(fireAtUtcMs = 2_000L))
        assertEquals(ArmResult.Armed, result)
        assertEquals(setOf(alarm.trigger.alarmId), armedIds())
    }

    @Test
    fun `REQ-ALM-002 disarming an alarm that is not armed is not an error`() {
        val port = port()
        port.disarm(AlarmTrigger.Snooze("00000000000000bb"))
        port.arm(alarm)
        port.disarm(alarm.trigger)
        assertFalse(alarm.trigger.alarmId in armedIds())
    }
}

internal class FakeAlarmPortContractTest : AlarmPortContract() {
    private val fake = FakeAlarmPort()

    override fun port(): AlarmPort = fake

    override fun armedIds(): Set<String> = fake.armed.keys
}
