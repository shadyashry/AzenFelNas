package app.dailymuslim.athan.widget

/** Asks the platform to redraw every placed prayer-times widget from the persisted snapshot. Never throws. */
internal fun interface RefreshWidgets {
    /** Requests the redraw; the widgets read the snapshot themselves. */
    fun refresh()
}
