package app.dailymuslim.athan.spike

import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.IBinder
import app.dailymuslim.athan.codes.EventCode
import app.dailymuslim.athan.plan.EventAttrs
import java.io.File

/**
 * `mediaPlayback` foreground service playing on the alarm stream with `USAGE_ALARM` (REQ-ALM-023). Audio is
 * `<device-protected files>/athan/spike.ogg` when pushed, else the default alarm sound (which may be unreadable
 * before the first unlock; that is a spike finding).
 */
public class SpikePlaybackService : Service() {
    private var player: MediaPlayer? = null
    private var entryId: String? = null
    private var startedAtMs: Long = 0L

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int,
    ): Int {
        if (intent?.action == ACTION_STOP) {
            finish(SpikeLabels.USER_STOP)
        } else {
            val id = intent?.getStringExtra(SpikeLabels.EXTRA_ENTRY_ID)
            if (id != null) start(id, intent.getLongExtra(SpikeLabels.EXTRA_TRIGGER_MS, 0L))
        }
        return START_NOT_STICKY
    }

    private fun start(
        id: String,
        triggerUtcMs: Long,
    ) {
        val notification = SpikeNotifications(this).playback(id)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                SpikeScheduler.requestCode(id),
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK,
            )
        } else {
            startForeground(SpikeScheduler.requestCode(id), notification)
        }
        val log = SpikeEventLog(this)
        log.append(EventCode.ALARM_PRESENTED, SpikeAlarmReceiver.receipt(id, SpikeLabels.FGS_STARTED, triggerUtcMs))
        player?.release()
        entryId = id
        player =
            MediaPlayer().apply {
                setAudioAttributes(SpikeNotifications.ALARM_ATTRIBUTES)
                setDataSource(this@SpikePlaybackService, audioUri())
                setOnPreparedListener {
                    it.start()
                    startedAtMs = System.currentTimeMillis()
                    log.append(
                        EventCode.ALARM_PRESENTED,
                        SpikeAlarmReceiver.receipt(id, SpikeLabels.AUDIO_STARTED, triggerUtcMs),
                    )
                }
                setOnCompletionListener { finish(SpikeLabels.AUDIO_COMPLETED) }
                prepareAsync()
            }
    }

    private fun audioUri(): Uri {
        val pushed = File(createDeviceProtectedStorageContext().filesDir, "athan/spike.ogg")
        return if (pushed.exists()) Uri.fromFile(pushed) else RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
    }

    private fun finish(reason: String) {
        val id = entryId
        if (id != null) {
            SpikeEventLog(this).append(
                EventCode.ALARM_DISMISSED,
                EventAttrs(entryId = id, reason = reason, durationMs = System.currentTimeMillis() - startedAtMs),
            )
        }
        player?.release()
        player = null
        entryId = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        player?.release()
        player = null
        super.onDestroy()
    }

    internal companion object {
        const val ACTION_STOP: String = "app.dailymuslim.athan.spike.STOP"
    }
}
