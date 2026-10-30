package app.azenfelnas.athan.bridge

import android.content.Context
import app.azenfelnas.athan.playback.AthanForegroundService
import app.azenfelnas.athan.playback.BundledAudioInstaller
import app.azenfelnas.athan.playback.PreviewPlayer
import java.io.File

/**
 * Downloaded Athan voices for the app module's `dm/athan_audio` channel (DESIGN.md §15 D111): the copy the alarm
 * service plays before the first unlock, and previews that an Athan always ends. Install and remove block on I/O; the
 * caller runs them off the main thread.
 */
public class AthanVoiceHost(
    private val context: Context,
) {
    private val installer: BundledAudioInstaller = BundledAudioInstaller(AthanGraph(context).audio)

    /** Installs the voice file at [path] as [soundId] when its sha256 is [sha256]; true when it is there. */
    public fun install(
        soundId: String,
        path: String,
        sha256: String,
    ): Boolean = installer.installFile(soundId, File(path), sha256)

    /** Deletes the alarm service's copy of [soundId]; true when none is left. */
    public fun remove(soundId: String): Boolean = installer.remove(soundId)

    /**
     * Previews the voice file at [path] on the alarm stream (REQ-ALM-054), replacing any other preview; false while
     * an Athan plays. [onEnded] runs when it ends by itself or for an Athan, never when it is stopped or replaced.
     */
    public fun preview(
        path: String,
        onEnded: () -> Unit,
    ): Boolean = PreviewPlayer.gate.start(File(path), onEnded)

    /** Stops the preview, if any. */
    public fun stopPreview() {
        PreviewPlayer.gate.stop()
    }

    /** Whether an Athan is playing now (§15 D118). */
    public fun athanPlaying(): Boolean = PreviewPlayer.gate.isAthanPlaying()

    /** Ends the Athan playing now, if any: the app's own Stop (§15 D118, REQ-ALM-043). */
    public fun stopAthan() {
        AthanForegroundService.stop(context)
    }

    /** Tells [listener] each time an Athan starts or ends, on the thread that changed it; null stops telling. */
    public fun watchAthan(listener: ((Boolean) -> Unit)?) {
        PreviewPlayer.gate.watchAthan(listener)
    }
}
