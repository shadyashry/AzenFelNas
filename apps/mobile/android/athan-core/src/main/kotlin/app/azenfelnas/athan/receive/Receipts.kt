package app.azenfelnas.athan.receive

import app.azenfelnas.athan.codes.EventCode
import app.azenfelnas.athan.codes.FailureCode
import app.azenfelnas.athan.plan.EventAttrs
import app.azenfelnas.athan.plan.EventLevel
import app.azenfelnas.athan.plan.EventsStore

/** Delivery stage written to `attrs.reason` of a receipt; labels match the S19 spike (ADR-025, D79). */
internal enum class ReceiptStage(
    val label: String,
) {
    RECEIVER("receiver"),
    FGS_STARTED("fgs_started"),
    FGS_DENIED("fgs_denied"),
    AUDIO_STARTED("audio_started"),
    AUDIO_FAILED("audio_failed"),
    NOTIFICATION_POSTED("notification_posted"),
    DROPPED("dropped"),
    USER_STOP("user_stop"),
    SNOOZED("snoozed"),
    AUDIO_COMPLETED("audio_completed"),
}

/**
 * Alarm receipts in `events.jsonl` (REQ-ALM-041): `ALARM_PRESENTED` lines become `ReceiptState.presented` and
 * `ALARM_DISMISSED` lines `dismissed` when Dart drains them. Only ids, stages and durations are written
 * (REQ-PRIV-001).
 */
internal class Receipts(
    private val events: EventsStore,
) {
    /** [alarmId] reached [stage]; [lateMs] is how long after its fire instant, when known. */
    fun presented(
        alarmId: String,
        stage: ReceiptStage,
        lateMs: Long? = null,
        level: EventLevel = EventLevel.INFO,
    ) {
        events.append(
            EventCode.ALARM_PRESENTED,
            EventAttrs(entryId = alarmId, reason = stage.label, durationMs = lateMs),
            level,
        )
    }

    /** [alarmId] ended at [stage] after [playedMs]. */
    fun dismissed(
        alarmId: String,
        stage: ReceiptStage,
        playedMs: Long?,
    ) {
        events.append(
            EventCode.ALARM_DISMISSED,
            EventAttrs(entryId = alarmId, reason = stage.label, durationMs = playedMs),
        )
    }

    /** The Athan audio of [alarmId] is not on disk; the default alarm sound plays instead. */
    fun audioMissing(alarmId: String) {
        events.append(
            EventCode.ALARM_PRESENTED,
            EventAttrs(code = FailureCode.AUDIO_ASSET_MISSING, entryId = alarmId),
            EventLevel.WARN,
        )
    }
}
