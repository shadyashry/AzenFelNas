package app.dailymuslim.athan.schedule

import app.dailymuslim.athan.plan.EntryKind
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test

internal class ArmingWindowTest {
    private val start = builtPlan.generatedAtUtcMs
    private val kindById = builtPlan.entries.associate { it.id to it.kind }

    private fun kindOf(alarm: ArmedAlarm): EntryKind? = kindById[(alarm.trigger as AlarmTrigger.PlanEntry).entryId]

    @Test
    fun `REQ-ALM-020 ATHAN entries use setAlarmClock when exact alarms are allowed`() {
        val alarms = ArmingWindow(capacity = 400).alarms(builtPlan, start, exactAllowed = true)

        assertTrue(alarms.filter { kindOf(it) == EntryKind.ATHAN }.all { it.mode == DeliveryMode.ALARM_CLOCK })
        assertTrue(alarms.filter { kindOf(it) != EntryKind.ATHAN }.all { it.mode == DeliveryMode.EXACT_IDLE })
    }

    @Test
    fun `REQ-ALM-027 without exact alarms every entry uses the inexact scheduler`() {
        val alarms = ArmingWindow().alarms(builtPlan, start, exactAllowed = false)

        assertTrue(alarms.isNotEmpty())
        assertTrue(alarms.all { it.mode == DeliveryMode.INEXACT_IDLE })
    }

    @Test
    fun `REQ-ALM-001 alarms fire at the plan's absolute instants`() {
        val byId = builtPlan.entries.associateBy { it.id }
        val alarms = ArmingWindow(capacity = 400).alarms(builtPlan, start, exactAllowed = true)

        assertEquals(builtPlan.entries.size, alarms.size)
        alarms.forEach { assertEquals(byId.getValue(it.trigger.alarmId).fireAtUtcMs, it.fireAtUtcMs) }
    }

    @Test
    fun `REQ-ALM-002 the window arms the nearest future entries up to its capacity`() {
        val now = builtPlan.entries[10].fireAtUtcMs
        val alarms = ArmingWindow(capacity = 20).alarms(builtPlan, now, exactAllowed = true)

        assertEquals(20, alarms.size)
        assertTrue(alarms.all { it.fireAtUtcMs > now })
        assertEquals(alarms.sortedBy { it.fireAtUtcMs }, alarms)
        val firstSkipped =
            builtPlan.entries
                .map { it.fireAtUtcMs }
                .filter { it > now }
                .sorted()[20]
        assertTrue(alarms.last().fireAtUtcMs <= firstSkipped)
    }

    @Test
    fun `REQ-ALM-010 the default window stays below the platform alarm cap`() {
        assertTrue(ArmingWindow.DEFAULT_CAPACITY < 500)
        assertEquals(ArmingWindow.DEFAULT_CAPACITY, ArmingWindow().alarms(builtPlan, start, exactAllowed = true).size)
    }
}
