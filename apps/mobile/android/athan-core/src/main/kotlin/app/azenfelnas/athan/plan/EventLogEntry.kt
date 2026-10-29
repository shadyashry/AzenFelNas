package app.azenfelnas.athan.plan

import app.azenfelnas.athan.codes.EventCode
import app.azenfelnas.athan.codes.FailureCode
import kotlinx.serialization.Serializable

/**
 * Wire form of `event_log.v1` (DESIGN.md Appendix J): one line of `events.jsonl`, drained by Dart (REQ-ALM-041).
 * [EventAttrs] is a closed allow-list, so no coordinate can be logged (REQ-PRIV-001).
 */
@Serializable
internal data class EventLogEntry(
    val utcMs: Long,
    val level: EventLevel,
    val code: EventCode,
    val attrs: EventAttrs,
)

/** Severity of an event-log entry. */
@Serializable
internal enum class EventLevel { DEBUG, INFO, WARN, ERROR }

/** Allowed event attributes; absent ones are null. */
@Serializable
internal data class EventAttrs(
    val code: FailureCode? = null,
    val generation: Long? = null,
    val entryId: String? = null,
    val packageType: String? = null,
    val version: String? = null,
    val state: String? = null,
    val reason: String? = null,
    val durationMs: Long? = null,
    val count: Long? = null,
    val zoneId: String? = null,
    val countryCode: String? = null,
)
