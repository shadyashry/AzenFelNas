package app.azenfelnas.radio

import android.content.ComponentName
import android.content.Context
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.Player
import androidx.media3.session.MediaController
import androidx.media3.session.SessionToken
import com.google.common.util.concurrent.ListenableFuture
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutionException

/**
 * `dm/radio` and `dm/radio/state` (DESIGN.md section 15 D122): Dart's commands reach [RadioService] through a Media3
 * controller; its state comes back from [RadioHub]. Only HTTPS stream addresses are accepted (the Dart side already
 * keeps them to MP3Quran's hosts). Closing the screen releases the controller; a playing station keeps playing.
 */
class RadioBridge(
    private val context: Context,
) : MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {
    private val main = Handler(Looper.getMainLooper())
    private var controller: ListenableFuture<MediaController>? = null
    private var sink: ((RadioState) -> Unit)? = null

    /** Registers both channels on [messenger]. */
    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, "dm/radio").setMethodCallHandler(this)
        EventChannel(messenger, "dm/radio/state").setStreamHandler(this)
    }

    /** Releases the controller and the state listener (the screen's engine is going). */
    fun release() {
        sink?.let { RadioHub.unlisten(it) }
        sink = null
        controller?.let { MediaController.releaseFuture(it) }
        controller = null
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            "state" -> {
                result.success(RadioHub.state.toMap())
            }

            "play" -> {
                play(call, result)
            }

            "pause", "resume", "stop", "sleep" -> {
                ifRunning(commandOf(call))
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun play(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val item = itemOf(call)
        if (item == null) {
            result.error("bad-request", "a station id and an https url are required", null)
            return
        }
        withController {
            it.setMediaItem(item)
            it.prepare()
            it.play()
        }
        result.success(null)
    }

    override fun onListen(
        arguments: Any?,
        events: EventChannel.EventSink,
    ) {
        sink?.let { RadioHub.unlisten(it) }
        val listener: (RadioState) -> Unit = { events.success(it.toMap()) }
        sink = listener
        RadioHub.listen(listener)
        events.success(RadioHub.state.toMap())
    }

    override fun onCancel(arguments: Any?) {
        sink?.let { RadioHub.unlisten(it) }
        sink = null
    }

    /** Runs [block] only while the service exists: Pause or Stop never starts it. */
    private fun ifRunning(block: (MediaController) -> Unit) {
        if (RadioHub.serviceAlive || controller != null) withController(block)
    }

    private fun withController(block: (MediaController) -> Unit) {
        val future =
            controller ?: MediaController
                .Builder(context, SessionToken(context, ComponentName(context, RadioService::class.java)))
                .buildAsync()
                .also { controller = it }
        future.addListener({
            try {
                block(future.get())
            } catch (_: ExecutionException) {
                if (controller === future) controller = null
            } catch (_: InterruptedException) {
                if (controller === future) controller = null
            }
        }, main::post)
    }
}

/** What Pause, Resume, Stop or Sleep in [call] does to the player. */
private fun commandOf(call: MethodCall): (MediaController) -> Unit =
    when (call.method) {
        "pause" -> {
            { it.pause() }
        }

        "resume" -> {
            {
                if (it.playbackState == Player.STATE_IDLE) it.prepare()
                it.play()
            }
        }

        "stop" -> {
            { it.sendCustomCommand(RadioService.STOP, Bundle.EMPTY) }
        }

        else -> {
            val minutes = Bundle().apply { putInt(RadioService.KEY_MINUTES, call.argument<Int>("minutes") ?: 0) }
            ({ it.sendCustomCommand(RadioService.SLEEP, minutes) })
        }
    }

/** The station [call] asks to play, or `null` without an id and an HTTPS address. */
private fun itemOf(call: MethodCall): MediaItem? {
    val id = call.argument<String>("stationId")
    val url = call.argument<String>("url")?.let(Uri::parse)
    if (id == null || url == null || url.scheme != "https") return null
    return MediaItem
        .Builder()
        .setMediaId(id)
        .setUri(url)
        .setMediaMetadata(
            MediaMetadata
                .Builder()
                .setTitle(call.argument<String>("title").orEmpty())
                .setArtist(call.argument<String>("subtitle").orEmpty())
                .setIsPlayable(true)
                .setIsBrowsable(false)
                .setMediaType(MediaMetadata.MEDIA_TYPE_RADIO_STATION)
                .build(),
        ).build()
}
