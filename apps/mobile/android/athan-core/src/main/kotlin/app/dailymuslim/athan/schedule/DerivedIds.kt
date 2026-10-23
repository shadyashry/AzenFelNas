package app.dailymuslim.athan.schedule

import java.security.MessageDigest

/** 16-hex-digit ids for alarms that are not plan entries, derived like plan ids (sha256, DESIGN.md §7.7). */
internal object DerivedId {
    private const val ID_HEX_DIGITS: Int = 16

    /** Lowercase hex of sha256(UTF-8 [text]), first 16 digits. */
    fun of(text: String): String =
        MessageDigest
            .getInstance("SHA-256")
            .digest(text.toByteArray(Charsets.UTF_8))
            .joinToString("") { "%02x".format(it) }
            .take(ID_HEX_DIGITS)
}

/** Alarm id of the snooze of a plan entry. */
internal object SnoozeId {
    fun of(entryId: String): String = DerivedId.of("$entryId|SNOOZE")
}

/** Alarm id of an Athan Test. */
internal object TestId {
    fun of(testId: String): String = DerivedId.of("TEST|$testId")
}
