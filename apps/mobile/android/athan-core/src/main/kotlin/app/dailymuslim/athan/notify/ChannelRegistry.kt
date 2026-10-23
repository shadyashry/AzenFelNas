package app.dailymuslim.athan.notify

import android.app.NotificationChannel
import android.app.NotificationChannelGroup
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.media.RingtoneManager
import app.dailymuslim.athan.R

/**
 * Notification channels (DESIGN.md §8.1, REQ-ALM-024). A channel's sound cannot change after creation, so the id
 * derives from (kind, soundId, v): a new sound creates a new channel in the kind's group, copies the user's
 * importance, vibration and lock-screen choices from the channel it replaces, and deletes that one.
 */
internal class ChannelRegistry(
    private val context: Context,
) {
    private val manager: NotificationManager = context.getSystemService(NotificationManager::class.java)

    /** The id of the channel for [spec], created or migrated on first use. */
    fun ensure(spec: ChannelSpec): String {
        val id = spec.id
        if (manager.getNotificationChannel(id) != null) return id
        val group = GROUP_PREFIX + spec.kind.name
        manager.createNotificationChannelGroup(NotificationChannelGroup(group, context.getString(nameOf(spec.kind))))
        val replaced = manager.notificationChannels.filter { it.group == group && it.id.startsWith(ChannelSpec.PREFIX) }
        val channel =
            NotificationChannel(id, context.getString(nameOf(spec.kind)), NotificationManager.IMPORTANCE_HIGH).apply {
                setGroup(group)
                if (spec.kind == ChannelKind.PLAYBACK) {
                    setSound(null, null)
                    enableVibration(spec.soundId == ChannelSpec.VIBRATE)
                } else {
                    // D79 fallback: the alarm-stream default sound until S22 ships per-sound URIs.
                    setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM), ALARM_ATTRIBUTES)
                }
                replaced.firstOrNull()?.let { old ->
                    importance = old.importance
                    enableVibration(old.shouldVibrate())
                    lockscreenVisibility = old.lockscreenVisibility
                }
            }
        manager.createNotificationChannel(channel)
        replaced.forEach { manager.deleteNotificationChannel(it.id) }
        return id
    }

    /** Importance of the channel for [spec]; `IMPORTANCE_HIGH` or more passes the probe (§8.1). */
    fun importanceOf(spec: ChannelSpec): Int? = manager.getNotificationChannel(spec.id)?.importance

    private fun nameOf(kind: ChannelKind): Int =
        when (kind) {
            ChannelKind.ATHAN -> R.string.athan_channel_athan
            ChannelKind.PRE_REMINDER -> R.string.athan_channel_pre_reminder
            ChannelKind.IMSAK -> R.string.athan_channel_imsak
            ChannelKind.HORIZON_WARNING -> R.string.athan_channel_horizon_warning
            ChannelKind.PLAYBACK -> R.string.athan_channel_playback
        }

    internal companion object {
        private const val GROUP_PREFIX: String = "athan_group_"

        /** Alarm-stream attributes of every Athan sound (REQ-ALM-023). */
        val ALARM_ATTRIBUTES: AudioAttributes =
            AudioAttributes
                .Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
    }
}
