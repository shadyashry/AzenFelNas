package app.azenfelnas.athan.plan

import app.azenfelnas.athan.codes.EventCode
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.io.TempDir
import java.io.File

internal class EventsStoreTest {
    @Test
    fun `REQ-ALM-041 a drain returns every receipt once, oldest first`(
        @TempDir dir: File,
    ) {
        var now = 1L
        val store = EventsStore(dir) { now++ }
        store.append(EventCode.ALARM_PRESENTED, EventAttrs(entryId = "a"))
        store.append(EventCode.ALARM_DISMISSED, EventAttrs(entryId = "a"))

        val drained = store.drain()

        assertEquals(listOf(EventCode.ALARM_PRESENTED, EventCode.ALARM_DISMISSED), drained.map { it.code })
        assertEquals(listOf(1L, 2L), drained.map { it.utcMs })
        assertTrue(store.drain().isEmpty())
    }

    @Test
    fun `REQ-ALM-041 lines appended after a drain are kept for the next one`(
        @TempDir dir: File,
    ) {
        val store = EventsStore(dir) { 0L }
        store.append(EventCode.PLAN_APPLIED, EventAttrs(count = 1))
        store.drain()
        store.append(EventCode.PLAN_APPLIED, EventAttrs(count = 2))

        assertEquals(listOf(2L), store.drain().map { it.attrs.count })
    }

    @Test
    fun `REQ-ALM-041 lines of an interrupted drain come back first and unparseable lines are skipped`(
        @TempDir dir: File,
    ) {
        val store = EventsStore(dir) { 0L }
        store.append(EventCode.ALARM_PRESENTED, EventAttrs(entryId = "old"))
        File(dir, "events.jsonl").renameTo(File(dir, "events.jsonl.draining"))
        File(dir, "events.jsonl").appendText("not json\n")
        store.append(EventCode.ALARM_PRESENTED, EventAttrs(entryId = "new"))

        assertEquals(listOf("old", "new"), store.drain().map { it.attrs.entryId })
    }
}
