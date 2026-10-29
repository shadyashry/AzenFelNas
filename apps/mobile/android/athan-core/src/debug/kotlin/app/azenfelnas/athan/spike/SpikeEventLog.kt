package app.azenfelnas.athan.spike

import android.content.Context
import app.azenfelnas.athan.codes.EventCode
import app.azenfelnas.athan.plan.EventAttrs
import app.azenfelnas.athan.plan.EventLevel
import app.azenfelnas.athan.plan.EventLogEntry
import app.azenfelnas.athan.plan.wireJson
import java.io.File

/**
 * Appends `event_log.v1` lines to `<device-protected files>/plan/events.jsonl` (DESIGN.md §8.1), so receipts
 * written before the first unlock survive and Dart (or `adb shell run-as`) reads them later.
 */
internal class SpikeEventLog(
    context: Context,
) {
    private val file: File =
        File(context.createDeviceProtectedStorageContext().filesDir, "plan/events.jsonl")

    fun append(
        code: EventCode,
        attrs: EventAttrs,
        level: EventLevel = EventLevel.INFO,
    ) {
        val entry = EventLogEntry(utcMs = System.currentTimeMillis(), level = level, code = code, attrs = attrs)
        synchronized(LOCK) {
            file.parentFile?.mkdirs()
            file.appendText(wireJson.encodeToString(EventLogEntry.serializer(), entry) + "\n")
        }
    }

    /** Every parseable line, oldest first. */
    fun readAll(): List<EventLogEntry> =
        synchronized(LOCK) {
            if (!file.exists()) return emptyList()
            file.readLines().filter { it.isNotBlank() }.mapNotNull { line ->
                runCatching { wireJson.decodeFromString(EventLogEntry.serializer(), line) }.getOrNull()
            }
        }

    private companion object {
        val LOCK: Any = Any()
    }
}
