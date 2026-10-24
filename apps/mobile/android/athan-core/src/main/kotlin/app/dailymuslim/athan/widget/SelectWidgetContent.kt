package app.dailymuslim.athan.widget

import app.dailymuslim.athan.plan.PrayerEvent
import app.dailymuslim.athan.plan.Snapshot

/**
 * The widget content of a snapshot at an instant (DESIGN.md §7.7, §15 D88). Pure; the same rules as the Swift
 * `WidgetTimeline` and `schemas/vectors/widget_content.v1.json`:
 * - next = the first Fajr, Dhuhr, Asr, Maghrib or Isha whose displayed instant is after now (Imsak and sunrise
 *   are listed but are not prayers, as on Home);
 * - rows = every item of next's prayer day in time order, so the list rolls to the next day once its Isha has
 *   passed and needs no zone rules at local midnight (REQ-WID-002);
 * - refresh at the earliest displayed instant after now; no prayer ahead = [WidgetContent.Expired].
 */
internal class SelectWidgetContent {
    /** The content of [snapshot] (null: none written yet) at [nowUtcMs]. */
    operator fun invoke(
        snapshot: Snapshot?,
        nowUtcMs: Long,
    ): WidgetContent {
        val items = snapshot?.items?.sortedBy { it.displayedUtcMs }.orEmpty()
        val next = items.firstOrNull { it.event in PRAYERS && it.displayedUtcMs > nowUtcMs }
        return when {
            snapshot == null -> {
                WidgetContent.NoSnapshot
            }

            next == null -> {
                WidgetContent.Expired(snapshot.generatedAtUtcMs)
            }

            else -> {
                WidgetContent.Showing(
                    day = next.day,
                    next = WidgetRow(next.event, next.displayedUtcMs, next.displayLocal, passed = false),
                    rows =
                        items.filter { it.day == next.day }.map {
                            WidgetRow(it.event, it.displayedUtcMs, it.displayLocal, it.displayedUtcMs <= nowUtcMs)
                        },
                    refreshAtUtcMs = items.first { it.displayedUtcMs > nowUtcMs }.displayedUtcMs,
                )
            }
        }
    }

    private companion object {
        val PRAYERS: Set<PrayerEvent> =
            setOf(PrayerEvent.FAJR, PrayerEvent.DHUHR, PrayerEvent.ASR, PrayerEvent.MAGHRIB, PrayerEvent.ISHA)
    }
}
