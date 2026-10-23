package app.dailymuslim.athan.notify

import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import app.dailymuslim.athan.R
import app.dailymuslim.athan.playback.AthanForegroundService
import app.dailymuslim.athan.receive.AlertText
import app.dailymuslim.athan.receive.PENDING_FLAGS
import app.dailymuslim.athan.receive.Presentation
import app.dailymuslim.athan.schedule.RequestCode

/** Builds and posts the layer's notifications from pre-rendered plan text (`NotificationFactory`, §8.1). */
internal class AlertNotifications(
    private val context: Context,
    private val channels: ChannelRegistry,
) {
    private val manager: NotificationManager = context.getSystemService(NotificationManager::class.java)

    /** Posts the high-importance alert of [notify] (the D79 fallback, and every non-Athan entry). */
    fun post(notify: Presentation.Notify) {
        val text = notify.text ?: testText()
        val notification =
            Notification
                .Builder(context, channels.ensure(ChannelSpec(notify.kind, notify.soundId)))
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle(text.title)
                .setContentText(text.body)
                .setCategory(
                    if (notify.kind ==
                        ChannelKind.ATHAN
                    ) {
                        Notification.CATEGORY_ALARM
                    } else {
                        Notification.CATEGORY_REMINDER
                    },
                ).setAutoCancel(true)
                .setContentIntent(openApp(notify.alarmId))
                .build()
        manager.notify(RequestCode.of(notify.alarmId), notification)
    }

    /** The ongoing notification of the playback service, with Stop and, once, Snooze (REQ-ALM-042). */
    fun playback(playback: Presentation.Playback): Notification {
        val text = playback.text ?: testText()
        val sound = if (playback.vibrate) ChannelSpec.VIBRATE else ChannelSpec.SILENT
        val builder =
            Notification
                .Builder(context, channels.ensure(ChannelSpec(ChannelKind.PLAYBACK, sound)))
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle(text.title)
                .setContentText(text.body)
                .setCategory(Notification.CATEGORY_ALARM)
                .setOngoing(true)
                .setContentIntent(openApp(playback.alarmId))
                .addAction(
                    action(R.string.athan_action_stop, AthanForegroundService.stopIntent(context, playback.alarmId)),
                )
        playback.snoozeEntryId?.let { entryId ->
            builder.addAction(
                action(R.string.athan_action_snooze, AthanForegroundService.snoozeIntent(context, entryId)),
            )
        }
        return builder.build()
    }

    private fun action(
        label: Int,
        intent: PendingIntent,
    ): Notification.Action = Notification.Action.Builder(null, context.getString(label), intent).build()

    private fun openApp(alarmId: String): PendingIntent? =
        context.packageManager.getLaunchIntentForPackage(context.packageName)?.let {
            PendingIntent.getActivity(context, RequestCode.of(alarmId), it, PENDING_FLAGS)
        }

    private fun testText(): AlertText =
        AlertText(context.getString(R.string.athan_test_title), context.getString(R.string.athan_test_body))
}
