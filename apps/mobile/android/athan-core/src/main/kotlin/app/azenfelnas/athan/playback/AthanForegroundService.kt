package app.azenfelnas.athan.playback

import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import app.azenfelnas.athan.bridge.AthanGraph
import app.azenfelnas.athan.notify.ChannelKind
import app.azenfelnas.athan.notify.ChannelRegistry
import app.azenfelnas.athan.plan.EventLevel
import app.azenfelnas.athan.receive.AlertText
import app.azenfelnas.athan.receive.PENDING_FLAGS
import app.azenfelnas.athan.receive.Presentation
import app.azenfelnas.athan.receive.ReceiptStage
import app.azenfelnas.athan.schedule.AlarmTrigger
import app.azenfelnas.athan.schedule.ArmedAlarm
import app.azenfelnas.athan.schedule.DeliveryMode
import app.azenfelnas.athan.schedule.RequestCode

/**
 * Full Athan playback (REQ-ALM-023): a `mediaPlayback` foreground service playing on the alarm stream with
 * `USAGE_ALARM`, started from the exact-alarm background-start exemption (ADR-012, S19). Audio is
 * `<device-protected files>/athan/<soundId>.m4a`, else the default alarm sound with an `AUDIO_ASSET_MISSING`
 * receipt. Stop ends it; Snooze re-arms the entry once, `policy.snoozeMinutes` later (REQ-ALM-042).
 */
public class AthanForegroundService : Service() {
    private var player: MediaPlayer? = null
    private var alarmId: String? = null
    private var startedAtMs: Long = 0L

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int,
    ): Int {
        val graph = AthanGraph(this)
        when (intent?.action) {
            ACTION_PLAY -> {
                playbackOf(intent)?.let { play(graph, it) } ?: stopSelf()
            }

            ACTION_SNOOZE -> {
                intent.getStringExtra(EXTRA_ENTRY_ID)?.let { snooze(graph, it) }
                    ?: finish(graph, ReceiptStage.USER_STOP)
            }

            else -> {
                finish(graph, ReceiptStage.USER_STOP)
            }
        }
        return START_NOT_STICKY
    }

    private fun play(
        graph: AthanGraph,
        playback: Presentation.Playback,
    ) {
        val notification = graph.notifications.playback(playback)
        val id = RequestCode.of(playback.alarmId)
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(id, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
            } else {
                startForeground(id, notification)
            }
        } catch (e: IllegalStateException) {
            fallBack(graph, playback, e)
            stopSelf()
            return
        }
        graph.receipts.presented(playback.alarmId, ReceiptStage.FGS_STARTED)
        player?.release()
        alarmId = playback.alarmId
        player =
            MediaPlayer().apply {
                setAudioAttributes(ChannelRegistry.ALARM_ATTRIBUTES)
                setWakeMode(this@AthanForegroundService, PowerManager.PARTIAL_WAKE_LOCK)
                setDataSource(this@AthanForegroundService, audioUri(graph, playback))
                setOnPreparedListener {
                    it.start()
                    startedAtMs = graph.clock.nowUtcMs()
                    graph.receipts.presented(playback.alarmId, ReceiptStage.AUDIO_STARTED)
                }
                setOnCompletionListener { finish(graph, ReceiptStage.AUDIO_COMPLETED) }
                setOnErrorListener { _, _, _ ->
                    graph.receipts.presented(playback.alarmId, ReceiptStage.AUDIO_FAILED, level = EventLevel.ERROR)
                    graph.notifications.post(playback.fallback)
                    finish(graph, ReceiptStage.AUDIO_FAILED)
                    true
                }
                prepareAsync()
            }
    }

    private fun audioUri(
        graph: AthanGraph,
        playback: Presentation.Playback,
    ): Uri {
        if (graph.audio.isPresent(playback.soundId)) return Uri.fromFile(graph.audio.fileOf(playback.soundId))
        graph.receipts.audioMissing(playback.alarmId)
        return RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
    }

    private fun snooze(
        graph: AthanGraph,
        entryId: String,
    ) {
        val minutes =
            graph.planStore
                .read()
                ?.policy
                ?.snoozeMinutes ?: 0
        if (minutes > 0) {
            val mode = if (graph.alarms.canScheduleExact()) DeliveryMode.ALARM_CLOCK else DeliveryMode.INEXACT_IDLE
            graph.alarms.arm(
                ArmedAlarm(AlarmTrigger.Snooze(entryId), graph.clock.nowUtcMs() + minutes * MS_PER_MINUTE, mode),
            )
        }
        finish(graph, ReceiptStage.SNOOZED)
    }

    private fun finish(
        graph: AthanGraph,
        stage: ReceiptStage,
    ) {
        alarmId?.let { graph.receipts.dismissed(it, stage, graph.clock.nowUtcMs() - startedAtMs) }
        player?.release()
        player = null
        alarmId = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        player?.release()
        player = null
        super.onDestroy()
    }

    public companion object {
        private const val ACTION_PLAY = "app.azenfelnas.athan.PLAY"
        private const val ACTION_STOP = "app.azenfelnas.athan.STOP"
        private const val ACTION_SNOOZE = "app.azenfelnas.athan.SNOOZE"
        private const val EXTRA_ALARM_ID = "app.azenfelnas.athan.ALARM_ID"
        private const val EXTRA_ENTRY_ID = "app.azenfelnas.athan.ENTRY_ID"
        private const val EXTRA_SOUND = "app.azenfelnas.athan.SOUND"
        private const val EXTRA_TITLE = "app.azenfelnas.athan.TITLE"
        private const val EXTRA_BODY = "app.azenfelnas.athan.BODY"
        private const val EXTRA_SNOOZE_MINUTES = "app.azenfelnas.athan.SNOOZE_MINUTES"
        private const val EXTRA_VIBRATE = "app.azenfelnas.athan.VIBRATE"
        private const val EXTRA_FALLBACK_KIND = "app.azenfelnas.athan.FALLBACK_KIND"
        private const val EXTRA_FALLBACK_SOUND = "app.azenfelnas.athan.FALLBACK_SOUND"
        private const val MS_PER_MINUTE: Long = 60_000L
        private const val FGS_DENIED_EXCEPTION = "ForegroundServiceStartNotAllowedException"

        /**
         * Starts playback of [playback]; when the platform refuses the start, posts its notification fallback (D79)
         * and records `fgs_denied`.
         */
        internal fun start(
            context: Context,
            graph: AthanGraph,
            playback: Presentation.Playback,
        ) {
            try {
                context.startForegroundService(playIntent(context, playback))
            } catch (e: IllegalStateException) {
                fallBack(graph, playback, e)
            }
        }

        private fun fallBack(
            graph: AthanGraph,
            playback: Presentation.Playback,
            error: IllegalStateException,
        ) {
            // ForegroundServiceStartNotAllowedException (API 31+) extends IllegalStateException; matched by name so
            // the class is never resolved on API 26–30.
            val denied = error.javaClass.simpleName == FGS_DENIED_EXCEPTION
            graph.receipts.presented(
                playback.alarmId,
                if (denied) ReceiptStage.FGS_DENIED else ReceiptStage.AUDIO_FAILED,
                level = EventLevel.ERROR,
            )
            graph.notifications.post(playback.fallback)
            graph.receipts.presented(playback.alarmId, ReceiptStage.NOTIFICATION_POSTED)
        }

        internal fun stopIntent(
            context: Context,
            alarmId: String,
        ): PendingIntent =
            PendingIntent.getService(
                context,
                RequestCode.of(alarmId),
                Intent(context, AthanForegroundService::class.java).setAction(ACTION_STOP),
                PENDING_FLAGS,
            )

        internal fun snoozeIntent(
            context: Context,
            entryId: String,
            minutes: Int,
        ): PendingIntent =
            PendingIntent.getService(
                context,
                RequestCode.of(entryId),
                Intent(
                    context,
                    AthanForegroundService::class.java,
                ).setAction(ACTION_SNOOZE)
                    .putExtra(EXTRA_ENTRY_ID, entryId)
                    .putExtra(EXTRA_SNOOZE_MINUTES, minutes),
                PENDING_FLAGS,
            )

        private fun playIntent(
            context: Context,
            playback: Presentation.Playback,
        ): Intent =
            Intent(context, AthanForegroundService::class.java)
                .setAction(ACTION_PLAY)
                .putExtra(EXTRA_ALARM_ID, playback.alarmId)
                .putExtra(EXTRA_SOUND, playback.soundId)
                .putExtra(EXTRA_TITLE, playback.text?.title)
                .putExtra(EXTRA_BODY, playback.text?.body)
                .putExtra(EXTRA_ENTRY_ID, playback.snoozeEntryId)
                .putExtra(EXTRA_SNOOZE_MINUTES, playback.snoozeMinutes)
                .putExtra(EXTRA_VIBRATE, playback.vibrate)
                .putExtra(EXTRA_FALLBACK_KIND, playback.fallback.kind.name)
                .putExtra(EXTRA_FALLBACK_SOUND, playback.fallback.soundId)

        private fun playbackOf(intent: Intent): Presentation.Playback? {
            val alarmId = intent.getStringExtra(EXTRA_ALARM_ID)
            val soundId = intent.getStringExtra(EXTRA_SOUND)
            if (alarmId == null || soundId == null) return null
            val title = intent.getStringExtra(EXTRA_TITLE)
            val body = intent.getStringExtra(EXTRA_BODY)
            val text = if (title != null && body != null) AlertText(title, body) else null
            val kind =
                ChannelKind.entries.firstOrNull { it.name == intent.getStringExtra(EXTRA_FALLBACK_KIND) }
                    ?: ChannelKind.ATHAN
            return Presentation.Playback(
                alarmId = alarmId,
                soundId = soundId,
                text = text,
                snoozeEntryId = intent.getStringExtra(EXTRA_ENTRY_ID),
                snoozeMinutes = intent.getIntExtra(EXTRA_SNOOZE_MINUTES, 0),
                vibrate = intent.getBooleanExtra(EXTRA_VIBRATE, true),
                fallback =
                    Presentation.Notify(
                        alarmId,
                        kind,
                        intent.getStringExtra(EXTRA_FALLBACK_SOUND) ?: soundId,
                        text,
                    ),
            )
        }
    }
}
