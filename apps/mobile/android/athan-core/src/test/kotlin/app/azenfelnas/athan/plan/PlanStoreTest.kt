package app.azenfelnas.athan.plan

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.io.TempDir
import java.io.File

internal class PlanStoreTest {
    private val built: String = fixture("schedule_plan", "valid", "built_android.json").readText()

    private fun withGeneration(generation: Long): String =
        built.replaceFirst("\"generation\": 1,", "\"generation\": $generation,")

    @Test
    fun `REQ-ALM-035 a written plan reads back and no temporary file is left`(
        @TempDir dir: File,
    ) {
        val store = PlanStore(dir)
        assertEquals(PlanWriteOutcome.Written(1), store.write(built))
        assertEquals(wireJson.decodeFromString(SchedulePlan.serializer(), built), store.read())
        assertFalse(File(dir, "plan.json.tmp").exists())
    }

    @Test
    fun `REQ-ALM-002 an older generation never replaces the persisted plan`(
        @TempDir dir: File,
    ) {
        val store = PlanStore(dir)
        store.write(withGeneration(5))
        assertEquals(PlanWriteOutcome.Stale(current = 5, offered = 4), store.write(withGeneration(4)))
        assertEquals(5L, store.read()?.generation)
        assertEquals(PlanWriteOutcome.Written(5), store.write(withGeneration(5)))
        assertEquals(PlanWriteOutcome.Written(6), store.write(withGeneration(6)))
    }

    @Test
    fun `REQ-ALM-002 a malformed document is rejected and the plan stays`(
        @TempDir dir: File,
    ) {
        val store = PlanStore(dir)
        store.write(built)
        assertTrue(store.write("{\"generation\":9}") is PlanWriteOutcome.Rejected)
        assertEquals(1L, store.read()?.generation)
    }

    @Test
    fun `REQ-ALM-002 a missing or unreadable plan reads as null`(
        @TempDir dir: File,
    ) {
        val store = PlanStore(dir)
        assertNull(store.read())
        File(dir, PlanStore.PLAN_FILE).writeText("not json")
        assertNull(store.read())
    }

    @Test
    fun `REQ-ALM-035 a snapshot is validated, written atomically and read back`(
        @TempDir dir: File,
    ) {
        val store = SnapshotStore(dir)
        val snapshot = fixture("snapshot", "valid", "built.json").readText()
        assertEquals(SnapshotWriteOutcome.Written, store.write(snapshot))
        assertEquals(wireJson.decodeFromString(Snapshot.serializer(), snapshot), store.read())
        assertTrue(store.write("[]") is SnapshotWriteOutcome.Rejected)
        assertFalse(File(dir, "snapshot.json.tmp").exists())
    }
}
