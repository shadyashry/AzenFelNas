package app.dailymuslim.athan.spike

/**
 * Receipt labels of the S19 spike; mirrors `SpikeLabels` in
 * `apps/mobile/lib/features/delivery_spike/domain/spike_protocol.dart` verbatim.
 */
internal object SpikeLabels {
    const val ANDROID_EXACT: String = "android_exact"
    const val ANDROID_INEXACT: String = "android_inexact"
    const val RECEIVER: String = "receiver"
    const val FGS_STARTED: String = "fgs_started"
    const val FGS_DENIED: String = "fgs_denied"
    const val AUDIO_STARTED: String = "audio_started"
    const val NOTIFICATION_POSTED: String = "notification_posted"
    const val USER_STOP: String = "user_stop"
    const val AUDIO_COMPLETED: String = "audio_completed"
    const val HEARD: String = "heard"
    const val NOT_HEARD: String = "not_heard"

    const val EXTRA_ENTRY_ID: String = "entryId"
    const val EXTRA_TRIGGER_MS: String = "triggerUtcMs"
    const val EXTRA_PATH: String = "path"
}
