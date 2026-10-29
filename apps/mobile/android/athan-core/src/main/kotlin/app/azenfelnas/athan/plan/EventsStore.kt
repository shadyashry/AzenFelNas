package app.azenfelnas.athan.plan

import app.azenfelnas.athan.codes.EventCode
import java.io.File

/** Serialises appends and drains of every [EventsStore] in the process (receivers, service and bridge). */
private val eventsLock: Any = Any()

/**
 * `<plan directory>/events.jsonl` (DESIGN.md §8.1): native code appends `event_log.v1` lines, Dart drains them on
 * every start (REQ-ALM-041). It sits in device-protected storage, so receipts written before the first unlock
 * survive. [drain] moves the file aside before reading, so a line is returned once and never lost.
 */
internal class EventsStore(
    directory: File,
    private val nowUtcMs: () -> Long,
) {
    private val file = File(directory, EVENTS_FILE)
    private val draining = File(directory, "$EVENTS_FILE.draining")

    /** Appends one line. */
    fun append(
        code: EventCode,
        attrs: EventAttrs,
        level: EventLevel = EventLevel.INFO,
    ) {
        val entry = EventLogEntry(utcMs = nowUtcMs(), level = level, code = code, attrs = attrs)
        synchronized(eventsLock) {
            file.absoluteFile.parentFile?.mkdirs()
            file.appendText(wireJson.encodeToString(EventLogEntry.serializer(), entry) + "\n", Charsets.UTF_8)
        }
    }

    /** Every parseable line not drained before, oldest first; the store is empty afterwards. */
    fun drain(): List<EventLogEntry> =
        synchronized(eventsLock) {
            // A drain interrupted after the rename left its lines in `draining`; they are older than `file`.
            val text =
                buildString {
                    if (draining.isFile) append(draining.readText(Charsets.UTF_8))
                    if (file.isFile) {
                        val moved = File(file.path + ".moving")
                        if (file.renameTo(moved)) {
                            append(moved.readText(Charsets.UTF_8))
                            moved.delete()
                        }
                    }
                }
            draining.delete()
            text
                .lineSequence()
                .filter { it.isNotBlank() }
                .mapNotNull(::decodeLine)
                .toList()
        }

    private fun decodeLine(line: String): EventLogEntry? = decodeWire(EventLogEntry.serializer(), line).valueOrNull()

    internal companion object {
        /** File name inside the plan directory (§8.1). */
        const val EVENTS_FILE: String = "events.jsonl"
    }
}
