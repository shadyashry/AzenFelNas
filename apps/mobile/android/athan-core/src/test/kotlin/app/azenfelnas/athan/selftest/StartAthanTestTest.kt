package app.azenfelnas.athan.selftest

import app.azenfelnas.athan.codes.EventCode
import app.azenfelnas.athan.plan.EventsStore
import app.azenfelnas.athan.schedule.AlarmTrigger
import app.azenfelnas.athan.schedule.ArmResult
import app.azenfelnas.athan.schedule.ArmedAlarm
import app.azenfelnas.athan.schedule.DeliveryMode
import app.azenfelnas.athan.schedule.FakeAlarmPort
import app.azenfelnas.athan.schedule.FixedClock
import app.azenfelnas.athan.schedule.TestId
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.io.TempDir
import java.io.File

internal class StartAthanTestTest {
    private val clock = FixedClock(1_000_000L)

    @Test
    fun `REQ-ALM-040 the Athan Test fires in 60 s through setAlarmClock`(
        @TempDir dir: File,
    ) {
        val alarms = FakeAlarmPort()
        val events = EventsStore(dir) { clock.nowUtcMs }

        val result = StartAthanTest(alarms, { true }, clock, events)("t1", 60, "athan_makkah_v1")

        assertEquals(ArmResult.Armed, result)
        assertEquals(
            ArmedAlarm(AlarmTrigger.Test("t1", "athan_makkah_v1"), 1_060_000L, DeliveryMode.ALARM_CLOCK),
            alarms.armed.getValue(TestId.of("t1")),
        )
        val started = events.drain().single()
        assertEquals(EventCode.TEST_STARTED, started.code)
        assertEquals(TestId.of("t1"), started.attrs.entryId)
    }

    @Test
    fun `REQ-ALM-027 without exact alarms the Athan Test uses the inexact path users really get`(
        @TempDir dir: File,
    ) {
        val alarms = FakeAlarmPort()

        StartAthanTest(alarms, { false }, clock, EventsStore(dir) { 0L })("t2", 60, "athan_makkah_v1")

        assertEquals(DeliveryMode.INEXACT_IDLE, alarms.armed.getValue(TestId.of("t2")).mode)
    }
}
