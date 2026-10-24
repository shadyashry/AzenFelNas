package app.dailymuslim.athan.widget

import app.dailymuslim.athan.plan.Snapshot
import app.dailymuslim.athan.plan.repoRoot
import app.dailymuslim.athan.plan.wireJson
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.long
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.DynamicTest
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestFactory
import java.io.File

/** S28 done-test, native half (DESIGN.md §7.7, §15 D88): the shared widget content vectors. */
internal class SelectWidgetContentTest {
    private val select = SelectWidgetContent()
    private val vectors: JsonObject =
        wireJson.parseToJsonElement(File(repoRoot, "schemas/vectors/widget_content.v1.json").readText()).jsonObject
    private val snapshot: Snapshot =
        wireJson.decodeFromString(
            Snapshot.serializer(),
            File(repoRoot, "schemas/${vectors.getValue("snapshot").jsonPrimitive.content}").readText(),
        )

    @TestFactory
    fun `REQ-WID-002 widget content follows the shared vectors across midnight`(): List<DynamicTest> =
        vectors.getValue("cases").jsonArray.map { element ->
            val case = element.jsonObject
            DynamicTest.dynamicTest(case.getValue("name").jsonPrimitive.content) {
                val actual = select(snapshot, case.getValue("nowUtcMs").jsonPrimitive.long)
                assertEquals(expected(case.getValue("expect").jsonObject), actual)
            }
        }

    @Test
    fun `REQ-WID-001 no snapshot asks for the app`() {
        assertEquals(WidgetContent.NoSnapshot, select(null, 0L))
    }

    @Test
    fun `REQ-WID-003 a rewritten snapshot is shown at once`() {
        val updated = snapshot.copy(items = snapshot.items.map { it.copy(displayLocal = "00:00") })
        val content = select(updated, snapshot.generatedAtUtcMs)
        check(content is WidgetContent.Showing)
        assertEquals(setOf("00:00"), content.rows.map { it.displayLocal }.toSet())
    }

    private fun expected(expect: JsonObject): WidgetContent {
        if (expect.getValue("kind").jsonPrimitive.content == "expired") {
            return WidgetContent.Expired(snapshot.generatedAtUtcMs)
        }
        val day = expect.getValue("day").jsonPrimitive.content
        val ofDay = snapshot.items.filter { it.day == day }.sortedBy { it.displayedUtcMs }
        val rows =
            expect.getValue("rows").jsonArray.mapIndexed { i, row ->
                val r = row.jsonObject
                WidgetRow(
                    event = ofDay[i].event,
                    displayedUtcMs = ofDay[i].displayedUtcMs,
                    displayLocal = r.getValue("displayLocal").jsonPrimitive.content,
                    passed = r.getValue("passed").jsonPrimitive.boolean,
                ).also { assertEquals(r.getValue("event").jsonPrimitive.content, it.event.name) }
            }
        val nextUtcMs = expect.getValue("nextUtcMs").jsonPrimitive.long
        return WidgetContent.Showing(
            day = day,
            next = rows.first { it.displayedUtcMs == nextUtcMs }.copy(passed = false),
            rows = rows,
            refreshAtUtcMs = expect.getValue("refreshAtUtcMs").jsonPrimitive.long,
        )
    }
}
