package app.azenfelnas.athan.widget.glance

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.LocalContext
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import app.azenfelnas.athan.R
import app.azenfelnas.athan.bridge.AthanGraph
import app.azenfelnas.athan.plan.PrayerEvent
import app.azenfelnas.athan.widget.WidgetContent
import app.azenfelnas.athan.widget.WidgetRow

/**
 * The prayer-times widget (DESIGN.md §7.7, §15 D88): draws [WidgetContent] selected from the persisted snapshot
 * and schedules its next redraw; it never calculates a time (REQ-WID-001).
 */
internal class PrayerTimesWidget : GlanceAppWidget() {
    override suspend fun provideGlance(
        context: Context,
        id: GlanceId,
    ) {
        val graph = AthanGraph(context)
        val content = graph.selectWidgetContent(graph.snapshotStore.read(), graph.clock.nowUtcMs())
        if (content is WidgetContent.Showing) graph.widgetRedraw.at(content.refreshAtUtcMs)
        val open = context.packageManager.getLaunchIntentForPackage(context.packageName)
        provideContent {
            GlanceTheme {
                val base = GlanceModifier.fillMaxSize().background(GlanceTheme.colors.widgetBackground).padding(12.dp)
                Column(modifier = if (open == null) base else base.clickable(actionStartActivity(open))) {
                    PrayerTimesBody(content)
                }
            }
        }
    }
}

@Composable
private fun PrayerTimesBody(content: WidgetContent) {
    val context = LocalContext.current
    when (content) {
        WidgetContent.NoSnapshot, is WidgetContent.Expired -> {
            Text(context.getString(R.string.widget_open_app), style = TextStyle(color = GlanceTheme.colors.onSurface))
        }

        is WidgetContent.Showing -> {
            Text(
                context.getString(
                    R.string.widget_next,
                    eventName(context, content.next.event),
                    content.next.displayLocal,
                ),
                style = TextStyle(fontWeight = FontWeight.Bold, color = GlanceTheme.colors.onSurface),
            )
            content.rows.forEach { TimeRow(it) }
        }
    }
}

@Composable
private fun TimeRow(row: WidgetRow) {
    val context = LocalContext.current
    val color = if (row.passed) GlanceTheme.colors.onSurfaceVariant else GlanceTheme.colors.onSurface
    Row(modifier = GlanceModifier.fillMaxWidth()) {
        Text(eventName(context, row.event), style = TextStyle(color = color), modifier = GlanceModifier.defaultWeight())
        Text(row.displayLocal, style = TextStyle(color = color))
    }
}

private fun eventName(
    context: Context,
    event: PrayerEvent,
): String =
    context.getString(
        when (event) {
            PrayerEvent.IMSAK -> R.string.widget_event_imsak
            PrayerEvent.FAJR -> R.string.widget_event_fajr
            PrayerEvent.SUNRISE -> R.string.widget_event_sunrise
            PrayerEvent.DHUHR -> R.string.widget_event_dhuhr
            PrayerEvent.ASR -> R.string.widget_event_asr
            PrayerEvent.MAGHRIB -> R.string.widget_event_maghrib
            PrayerEvent.ISHA -> R.string.widget_event_isha
        },
    )
