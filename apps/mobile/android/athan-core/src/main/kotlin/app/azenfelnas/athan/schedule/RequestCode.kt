package app.azenfelnas.athan.schedule

/**
 * `PendingIntent` request codes (REQ-ALM-021): the low 31 bits of a 16-hex-digit entry id, so the same entry
 * always maps to the same `PendingIntent` and re-arming replaces instead of duplicating.
 */
internal object RequestCode {
    private const val ID_TAIL_HEX: Int = 8
    private const val HEX: Int = 16

    /** The request code of [entryId] (16 lowercase hex digits, DESIGN.md §7.7). */
    fun of(entryId: String): Int = (entryId.takeLast(ID_TAIL_HEX).toLong(HEX) and Int.MAX_VALUE.toLong()).toInt()
}
