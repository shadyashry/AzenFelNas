package app.dailymuslim.athan.plan

import kotlinx.serialization.SerializationException
import org.junit.jupiter.api.DynamicTest
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestFactory
import org.junit.jupiter.api.assertThrows

internal class WireModelRoundTripTest {
    @TestFactory
    fun `schedule plan fixtures round-trip`(): List<DynamicTest> =
        roundTripValidFixtures("schedule_plan", SchedulePlan.serializer())

    @TestFactory
    fun `snapshot fixtures round-trip`(): List<DynamicTest> = roundTripValidFixtures("snapshot", Snapshot.serializer())

    @TestFactory
    fun `event log fixtures round-trip`(): List<DynamicTest> =
        roundTripValidFixtures("event_log", EventLogEntry.serializer())

    @Test
    fun `an unknown event code is rejected (REQ-ERR-002)`() {
        val json = fixture("event_log", "invalid", "unknown_event_code.json").readText()

        assertThrows<SerializationException> { wireJson.decodeFromString(EventLogEntry.serializer(), json) }
    }

    @Test
    fun `an unknown entry kind is rejected`() {
        val json =
            fixture("schedule_plan", "valid", "full.json")
                .readText()
                .replace("\"HORIZON_WARNING\"", "\"WAKE_UP\"")

        assertThrows<SerializationException> { wireJson.decodeFromString(SchedulePlan.serializer(), json) }
    }
}
