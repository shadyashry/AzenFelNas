package app.azenfelnas.athan.widget.glance

import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver

/** The prayer-times widget's receiver (DESIGN.md §7.7, §15 D88); `exported=false`, as every receiver here. */
public class PrayerTimesWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = PrayerTimesWidget()
}
