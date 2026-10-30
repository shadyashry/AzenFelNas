package app.azenfelnas.athan.playback

import android.media.MediaPlayer
import app.azenfelnas.athan.notify.ChannelRegistry
import java.io.File

/** One preview being played; [release] stops it. */
internal fun interface PreviewPlayback {
    fun release()
}

/**
 * Plays an Athan voice for the user to hear (DESIGN.md §15 D111, REQ-ALM-054): one preview at a time, on the alarm
 * stream so it sounds as loud as the Athan will. Scheduled playback always wins: [AthanForegroundService] calls
 * [athanStarted] before it plays, which ends any preview, and a preview never starts while an Athan plays.
 * Thread-safe; [onEnded] runs when a preview ends by itself or for an Athan, never when it is replaced or stopped.
 */
internal class PreviewGate(
    private val play: (file: File, onDone: () -> Unit) -> PreviewPlayback?,
) {
    private var current: PreviewPlayback? = null
    private var onEnded: (() -> Unit)? = null
    private var athanPlaying: Boolean = false

    /** Starts [file] in place of any other preview; false while an Athan plays or when [file] cannot play. */
    @Synchronized
    fun start(
        file: File,
        onEnded: () -> Unit,
    ): Boolean {
        if (athanPlaying || !file.isFile) return false
        releaseCurrent()
        var started: PreviewPlayback? = null
        started = play(file) { ended(started) }
        current = started
        this.onEnded = if (started != null) onEnded else null
        return started != null
    }

    /** Stops the preview, if any, without calling its `onEnded`. */
    @Synchronized
    fun stop() {
        releaseCurrent()
    }

    /** An Athan is about to play: the preview ends and none starts until [athanEnded]. */
    @Synchronized
    fun athanStarted() {
        athanPlaying = true
        val notify = onEnded
        releaseCurrent()
        notify?.invoke()
    }

    /** The Athan stopped. */
    @Synchronized
    fun athanEnded() {
        athanPlaying = false
    }

    /** Whether a preview is playing. */
    @Synchronized
    fun isPlaying(): Boolean = current != null

    @Synchronized
    private fun ended(playback: PreviewPlayback?) {
        if (playback == null || playback !== current) return
        val notify = onEnded
        releaseCurrent()
        notify?.invoke()
    }

    private fun releaseCurrent() {
        current?.release()
        current = null
        onEnded = null
    }
}

/** The process-wide preview gate over [MediaPlayer]. */
internal object PreviewPlayer {
    val gate: PreviewGate = PreviewGate(::mediaPlayer)

    private fun mediaPlayer(
        file: File,
        onDone: () -> Unit,
    ): PreviewPlayback? =
        try {
            val player =
                MediaPlayer().apply {
                    setAudioAttributes(ChannelRegistry.ALARM_ATTRIBUTES)
                    setDataSource(file.path)
                    setOnPreparedListener { it.start() }
                    setOnCompletionListener { onDone() }
                    setOnErrorListener { _, _, _ ->
                        onDone()
                        true
                    }
                    prepareAsync()
                }
            PreviewPlayback { player.release() }
        } catch (_: java.io.IOException) {
            null
        } catch (_: IllegalStateException) {
            null
        }
}
