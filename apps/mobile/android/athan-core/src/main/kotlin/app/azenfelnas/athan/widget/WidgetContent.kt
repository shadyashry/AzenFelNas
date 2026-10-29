package app.azenfelnas.athan.widget

import app.azenfelnas.athan.plan.PrayerEvent

/**
 * What a prayer-times widget shows at an instant (DESIGN.md §7.7, §15 D88), selected from the persisted
 * `Snapshot` by [SelectWidgetContent]; the widget never recalculates (REQ-WID-001).
 */
internal sealed interface WidgetContent {
    /** The app has not written a snapshot yet: the widget asks the user to open the app. */
    data object NoSnapshot : WidgetContent

    /** No prayer of the snapshot lies ahead: the widget asks the user to open the app. */
    data class Expired(
        val generatedAtUtcMs: Long,
    ) : WidgetContent

    /**
     * The next prayer and every displayed time of its prayer [day]; the widget must be redrawn at
     * [refreshAtUtcMs], the next displayed time of any kind.
     */
    data class Showing(
        val day: String,
        val next: WidgetRow,
        val rows: List<WidgetRow>,
        val refreshAtUtcMs: Long,
    ) : WidgetContent
}

/** One displayed time on the widget; [passed] once its instant is not after now. */
internal data class WidgetRow(
    val event: PrayerEvent,
    val displayedUtcMs: Long,
    val displayLocal: String,
    val passed: Boolean,
)
