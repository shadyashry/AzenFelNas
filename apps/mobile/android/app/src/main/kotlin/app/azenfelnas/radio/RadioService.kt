package app.azenfelnas.radio

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.annotation.OptIn
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.session.CommandButton
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaSessionService
import androidx.media3.session.SessionCommand
import androidx.media3.session.SessionError
import androidx.media3.session.SessionResult
import app.azenfelnas.R
import com.google.common.util.concurrent.Futures
import com.google.common.util.concurrent.ListenableFuture

/**
 * Quran radio's one player (DESIGN.md section 15 D122): an ExoPlayer in a Media3 session service, so it keeps playing
 * with the screen locked or the app in the background, shows the media notification and lock-screen controls, and
 * answers headset and Bluetooth buttons. It owns what must work with no Dart alive:
 *
 * - Audio focus and "becoming noisy" (headphones unplugged): Media3 pauses. A transient focus loss (a call, the
 *   app's own Athan) pauses for good: the listener resumes, nothing resumes by itself (REQ-RADIO-011).
 * - Retries (REQ-RADIO-008): a broken stream is tried again 3 times, after 2, 5 and 10 s, then the station is
 *   unavailable. A new station, Pause or Stop cancels a pending retry; a retry from an older station is ignored.
 * - The sleep timer (REQ-RADIO-009): at the deadline it stops, which also cancels retries.
 * - Stop releases the stream and the notification. Nothing starts after a reboot: no media button receiver is
 *   declared and playback resumption is refused.
 *
 * Live streams have no seek: seeking and skipping are not offered to any controller.
 */
@OptIn(UnstableApi::class)
class RadioService : MediaSessionService() {
    private val main = Handler(Looper.getMainLooper())
    private lateinit var player: ExoPlayer
    private var session: MediaSession? = null
    private var attempt = 0
    private var retrying = false
    private var exhausted = false
    private var stopped = false
    private var generation = 0
    private var sleepMinutes = 0
    private var sleepDeadlineUtcMs: Long? = null
    private val sleepTask = Runnable { stopPlayback() }
    private var retryTask: Runnable? = null

    override fun onCreate() {
        super.onCreate()
        player =
            ExoPlayer
                .Builder(this)
                .setAudioAttributes(
                    AudioAttributes
                        .Builder()
                        .setUsage(C.USAGE_MEDIA)
                        .setContentType(C.AUDIO_CONTENT_TYPE_MUSIC)
                        .build(),
                    true,
                ).setHandleAudioBecomingNoisy(true)
                .setWakeMode(C.WAKE_MODE_NETWORK)
                .build()
        player.addListener(listener)
        val stop =
            CommandButton
                .Builder(CommandButton.ICON_STOP)
                .setDisplayName(getString(R.string.radio_stop))
                .setSessionCommand(STOP)
                .build()
        session =
            MediaSession
                .Builder(this, player)
                .setSessionActivity(openRadio(this))
                .setCallback(Callback())
                .build()
                .also { it.setMediaButtonPreferences(listOf(stop)) }
        RadioHub.serviceAlive = true
        publish()
    }

    override fun onGetSession(controllerInfo: MediaSession.ControllerInfo): MediaSession? = session

    /** Swiping the app away keeps a playing station; anything else ends the service. */
    override fun onTaskRemoved(rootIntent: Intent?) {
        if (!player.playWhenReady || player.mediaItemCount == 0) {
            stopPlayback()
            stopSelf()
        }
    }

    override fun onDestroy() {
        main.removeCallbacksAndMessages(null)
        session?.release()
        session = null
        player.removeListener(listener)
        player.release()
        RadioHub.serviceAlive = false
        val stoppedLast = RadioHub.state.phase == RadioPhase.STOPPED
        RadioHub.publish(if (stoppedLast) RadioState(RadioPhase.STOPPED, null, 0, 0, null) else RadioState.READY)
        super.onDestroy()
    }

    private val listener =
        object : Player.Listener {
            override fun onEvents(
                player: Player,
                events: Player.Events,
            ) {
                publish()
            }

            override fun onMediaItemTransition(
                mediaItem: androidx.media3.common.MediaItem?,
                reason: Int,
            ) {
                // A new station: whatever was pending belongs to the old one.
                generation++
                cancelRetry()
                attempt = 0
                exhausted = false
                stopped = false
            }

            override fun onPlayWhenReadyChanged(
                playWhenReady: Boolean,
                reason: Int,
            ) {
                if (playWhenReady) {
                    stopped = false
                    if (exhausted) {
                        exhausted = false
                        attempt = 0
                    }
                } else {
                    cancelRetry()
                }
            }

            override fun onPlaybackSuppressionReasonChanged(playbackSuppressionReason: Int) {
                if (playbackSuppressionReason == Player.PLAYBACK_SUPPRESSION_REASON_TRANSIENT_AUDIO_FOCUS_LOSS) {
                    player.pause()
                }
            }

            override fun onIsPlayingChanged(isPlaying: Boolean) {
                if (isPlaying) attempt = 0
            }

            override fun onPlaybackStateChanged(playbackState: Int) {
                // A live stream that "ends" has dropped: treat it as broken.
                if (playbackState == Player.STATE_ENDED) scheduleRetry()
            }

            override fun onPlayerError(error: PlaybackException) {
                scheduleRetry()
            }
        }

    private fun scheduleRetry() {
        if (!player.playWhenReady || stopped) return
        if (attempt >= RETRY_DELAYS_MS.size) {
            retrying = false
            exhausted = true
            publish()
            return
        }
        val delay = RETRY_DELAYS_MS[attempt]
        attempt++
        retrying = true
        val run = generation
        val task =
            Runnable {
                if (run == generation && retrying && !stopped) {
                    retrying = false
                    player.prepare()
                    player.play()
                }
            }
        retryTask = task
        main.postDelayed(task, delay)
        publish()
    }

    private fun cancelRetry() {
        retrying = false
        retryTask?.let { main.removeCallbacks(it) }
        retryTask = null
    }

    private fun stopPlayback() {
        generation++
        cancelRetry()
        main.removeCallbacks(sleepTask)
        sleepMinutes = 0
        sleepDeadlineUtcMs = null
        attempt = 0
        exhausted = false
        stopped = true
        player.stop()
        player.clearMediaItems()
        publish()
    }

    private fun setSleep(minutes: Int) {
        main.removeCallbacks(sleepTask)
        if (minutes <= 0) {
            sleepMinutes = 0
            sleepDeadlineUtcMs = null
        } else {
            val ms = minutes * MS_PER_MINUTE
            sleepMinutes = minutes
            sleepDeadlineUtcMs = System.currentTimeMillis() + ms
            main.postDelayed(sleepTask, ms)
        }
        publish()
    }

    private fun phase(): String =
        when {
            stopped -> RadioPhase.STOPPED
            retrying -> RadioPhase.RECONNECTING
            exhausted || player.playerError != null -> RadioPhase.UNAVAILABLE
            else -> player.radioPhase(attempt)
        }

    private fun publish() {
        val deadline = sleepDeadlineUtcMs
        if (deadline != null && System.currentTimeMillis() >= deadline && !stopped) {
            // The phone slept past the deadline: stop now.
            main.post(sleepTask)
        }
        RadioHub.publish(
            RadioState(
                phase = phase(),
                stationId = if (stopped) null else player.currentMediaItem?.mediaId,
                attempt = if (retrying || phase() == RadioPhase.RECONNECTING) attempt else 0,
                sleepMinutes = sleepMinutes,
                sleepDeadlineUtcMs = deadline,
            ),
        )
    }

    private inner class Callback : MediaSession.Callback {
        override fun onConnect(
            session: MediaSession,
            controller: MediaSession.ControllerInfo,
        ): MediaSession.ConnectionResult {
            val commands =
                MediaSession.ConnectionResult.DEFAULT_SESSION_COMMANDS
                    .buildUpon()
                    .add(STOP)
                    .add(SLEEP)
                    .build()
            val player =
                MediaSession.ConnectionResult.DEFAULT_PLAYER_COMMANDS
                    .buildUpon()
                    .removeAll(
                        Player.COMMAND_SEEK_TO_PREVIOUS,
                        Player.COMMAND_SEEK_TO_PREVIOUS_MEDIA_ITEM,
                        Player.COMMAND_SEEK_TO_NEXT,
                        Player.COMMAND_SEEK_TO_NEXT_MEDIA_ITEM,
                        Player.COMMAND_SEEK_BACK,
                        Player.COMMAND_SEEK_FORWARD,
                        Player.COMMAND_SEEK_IN_CURRENT_MEDIA_ITEM,
                        Player.COMMAND_SEEK_TO_DEFAULT_POSITION,
                    ).build()
            return MediaSession.ConnectionResult
                .AcceptedResultBuilder(session)
                .setAvailableSessionCommands(commands)
                .setAvailablePlayerCommands(player)
                .build()
        }

        override fun onCustomCommand(
            session: MediaSession,
            controller: MediaSession.ControllerInfo,
            customCommand: SessionCommand,
            args: Bundle,
        ): ListenableFuture<SessionResult> {
            when (customCommand.customAction) {
                ACTION_STOP -> stopPlayback()
                ACTION_SLEEP -> setSleep(args.getInt(KEY_MINUTES))
                else -> return Futures.immediateFuture(SessionResult(SessionError.ERROR_NOT_SUPPORTED))
            }
            return Futures.immediateFuture(SessionResult(SessionResult.RESULT_SUCCESS))
        }
    }

    companion object {
        const val ACTION_STOP = "app.azenfelnas.radio.STOP"
        const val ACTION_SLEEP = "app.azenfelnas.radio.SLEEP"
        const val KEY_MINUTES = "minutes"
        val STOP = SessionCommand(ACTION_STOP, Bundle.EMPTY)
        val SLEEP = SessionCommand(ACTION_SLEEP, Bundle.EMPTY)
        private val RETRY_DELAYS_MS = longArrayOf(2_000L, 5_000L, 10_000L)
        private const val MS_PER_MINUTE = 60_000L
    }
}

/** The phase the player's own state gives, once Stop, retries and exhaustion are ruled out. */
private fun Player.radioPhase(attempt: Int): String =
    when (playbackState) {
        Player.STATE_BUFFERING -> {
            when {
                !playWhenReady -> RadioPhase.PAUSED
                attempt > 0 -> RadioPhase.RECONNECTING
                else -> RadioPhase.CONNECTING
            }
        }

        Player.STATE_READY -> {
            if (isPlaying) RadioPhase.PLAYING else RadioPhase.PAUSED
        }

        Player.STATE_ENDED -> {
            RadioPhase.UNAVAILABLE
        }

        else -> {
            RadioPhase.READY
        }
    }

/** Tapping the notification opens Radio (`azenfelnas://app/radio`, a linkable route). */
private fun openRadio(context: Context): PendingIntent =
    PendingIntent.getActivity(
        context,
        0,
        Intent(Intent.ACTION_VIEW, Uri.parse("azenfelnas://app/radio")).setPackage(context.packageName),
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
    )
