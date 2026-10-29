package app.azenfelnas.athan.schedule

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test

internal class RequestCodeTest {
    @Test
    fun `REQ-ALM-021 request codes derive from the entry id and are non-negative`() {
        assertEquals(0x7fffffff, RequestCode.of("ffffffffffffffff"))
        assertEquals(0x23423a97, RequestCode.of("3fd57d3da3423a97"))
        assertTrue(builtPlan.entries.all { RequestCode.of(it.id) >= 0 })
    }

    @Test
    fun `REQ-ALM-021 every entry of the built 30-day plan has its own request code`() {
        val codes = builtPlan.entries.map { RequestCode.of(it.id) }
        assertEquals(codes.size, codes.toSet().size)
    }

    @Test
    fun `REQ-ALM-021 snooze and test alarms derive 16-hex ids distinct from their entry`() {
        val entry = builtPlan.entries.first().id
        val snooze = AlarmTrigger.Snooze(entry).alarmId
        assertTrue(Regex("^[0-9a-f]{16}$").matches(snooze))
        assertNotEquals(entry, snooze)
        assertEquals(snooze, SnoozeId.of(entry))
        assertNotEquals(TestId.of("t1"), TestId.of("t2"))
    }
}
