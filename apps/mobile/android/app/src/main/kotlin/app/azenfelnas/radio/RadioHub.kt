package app.azenfelnas.radio

import android.os.Handler
import android.os.Looper
import java.util.concurrent.CopyOnWriteArraySet

/**
 * The radio player's state as Dart reads it (DESIGN.md section 15 D122): one value, written by [RadioService] only,
 * read by [RadioBridge]. Both live in the app's process, so a plain object is enough; the service keeps it current
 * whether or not a Flutter screen is open.
 */
data class RadioState(
    val phase: String,
    val stationId: String?,
    val attempt: Int,
    val sleepMinutes: Int,
    val sleepDeadlineUtcMs: Long?,
) {
    /** The `dm/radio/state` message. */
    fun toMap(): Map<String, Any?> =
        mapOf(
            "phase" to phase,
            "stationId" to stationId,
            "attempt" to attempt,
            "sleepMinutes" to sleepMinutes,
            "sleepDeadlineUtcMs" to sleepDeadlineUtcMs,
        )

    companion object {
        /** Nothing loaded. */
        val READY = RadioState(RadioPhase.READY, null, 0, 0, null)
    }
}

/** The wire names of the radio phases, the same as Dart's `RadioPhase`. */
object RadioPhase {
    const val READY = "ready"
    const val CONNECTING = "connecting"
    const val PLAYING = "playing"
    const val PAUSED = "paused"
    const val RECONNECTING = "reconnecting"
    const val STOPPED = "stopped"
    const val UNAVAILABLE = "unavailable"
}

/** Holds the current [RadioState] and tells listeners on the main thread. */
object RadioHub {
    private val main = Handler(Looper.getMainLooper())
    private val listeners = CopyOnWriteArraySet<(RadioState) -> Unit>()

    /** The latest state. */
    @Volatile
    var state: RadioState = RadioState.READY
        private set

    /** Whether the radio service exists now (commands need it; reading the state does not). */
    @Volatile
    var serviceAlive: Boolean = false

    /** Sets [next] and tells every listener if it changed. */
    fun publish(next: RadioState) {
        if (next == state) return
        state = next
        main.post { listeners.forEach { it(next) } }
    }

    /** Adds [listener]. */
    fun listen(listener: (RadioState) -> Unit) {
        listeners.add(listener)
    }

    /** Removes [listener]. */
    fun unlisten(listener: (RadioState) -> Unit) {
        listeners.remove(listener)
    }
}
