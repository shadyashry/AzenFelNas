package app.azenfelnas.athan.spike

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager

/** Spike notification channels and notifications; text is not localised (debug only). */
internal class SpikeNotifications(
    private val context: Context,
) {
    private val manager: NotificationManager = context.getSystemService(NotificationManager::class.java)

    fun ensureChannels() {
        manager.createNotificationChannel(
            NotificationChannel(PLAYBACK_CHANNEL, "S19 spike playback", NotificationManager.IMPORTANCE_HIGH).apply {
                setSound(null, null)
            },
        )
        manager.createNotificationChannel(
            NotificationChannel(FALLBACK_CHANNEL, "S19 spike fallback", NotificationManager.IMPORTANCE_HIGH).apply {
                setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM), ALARM_ATTRIBUTES)
            },
        )
    }

    fun playback(entryId: String): Notification {
        ensureChannels()
        val stop =
            PendingIntent.getService(
                context,
                SpikeScheduler.requestCode(entryId),
                Intent(context, SpikePlaybackService::class.java).setAction(SpikePlaybackService.ACTION_STOP),
                SpikeScheduler.FLAGS,
            )
        return Notification
            .Builder(context, PLAYBACK_CHANNEL)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("S19 spike alarm $entryId")
            .setCategory(Notification.CATEGORY_ALARM)
            .setOngoing(true)
            .addAction(Notification.Action.Builder(null, "Stop", stop).build())
            .build()
    }

    fun postFallback(entryId: String) {
        ensureChannels()
        manager.notify(
            SpikeScheduler.requestCode(entryId),
            Notification
                .Builder(context, FALLBACK_CHANNEL)
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle("S19 spike fallback $entryId")
                .setCategory(Notification.CATEGORY_ALARM)
                .build(),
        )
    }

    companion object {
        const val PLAYBACK_CHANNEL: String = "spike_s19_playback"
        const val FALLBACK_CHANNEL: String = "spike_s19_fallback"

        val ALARM_ATTRIBUTES: AudioAttributes =
            AudioAttributes
                .Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
    }
}
