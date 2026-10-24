package app.dailymuslim.athan.widget

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import app.dailymuslim.athan.receive.PENDING_FLAGS

/** The Glance receiver, named here so this file needs no Glance on the compile path. */
internal const val WIDGET_RECEIVER: String = "app.dailymuslim.athan.widget.glance.PrayerTimesWidgetReceiver"

/** `APPWIDGET_UPDATE` for every placed prayer-times widget, addressed to [WIDGET_RECEIVER] only. */
internal fun widgetUpdateIntent(context: Context): Intent {
    val component = ComponentName(context, WIDGET_RECEIVER)
    val ids = AppWidgetManager.getInstance(context).getAppWidgetIds(component)
    return Intent(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
        .setComponent(component)
        .putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
}

/** [RefreshWidgets] by broadcast: the app wrote a new snapshot (a new plan, profile, context or locale). */
internal class AppWidgetRefresh(
    private val context: Context,
) : RefreshWidgets {
    override fun refresh() {
        context.sendBroadcast(widgetUpdateIntent(context))
    }
}

/**
 * The widget's own redraw at the snapshot's next displayed time (§15 D88), so it advances past each prayer and
 * across local midnight with no Dart isolate (REQ-WID-002). A one-minute window, non-wakeup: no exact-alarm
 * permission is spent on a widget, and a sleeping screen shows nothing to correct.
 */
internal class WidgetRedrawAlarm(
    private val context: Context,
) {
    /** Replaces any pending redraw with one at [utcMs]. */
    fun at(utcMs: Long) {
        val alarms = context.getSystemService(AlarmManager::class.java) ?: return
        val pending = PendingIntent.getBroadcast(context, REQUEST_CODE, widgetUpdateIntent(context), PENDING_FLAGS)
        alarms.setWindow(AlarmManager.RTC, utcMs, WINDOW_MS, pending)
    }

    private companion object {
        const val REQUEST_CODE: Int = 0x5728
        const val WINDOW_MS: Long = 60_000L
    }
}
