package app.dailymuslim.athan.notify

import java.security.MessageDigest

/** What a notification channel carries; with the sound it derives the channel id (REQ-ALM-024). */
internal enum class ChannelKind {
    ATHAN,
    PRE_REMINDER,
    IMSAK,
    HORIZON_WARNING,

    /** The silent ongoing notification of the playback service; its audio is the service's own. */
    PLAYBACK,
}

/** One channel: [kind] with [soundId], at channel scheme [version]. */
internal data class ChannelSpec(
    val kind: ChannelKind,
    val soundId: String,
    val version: Int = CURRENT_VERSION,
) {
    /** `"athan_" + sha256("kind|soundId|v").hex[0:12]` (DESIGN.md §8.1): a new sound is a new channel. */
    val id: String
        get() =
            PREFIX +
                MessageDigest
                    .getInstance("SHA-256")
                    .digest("${kind.name}|$soundId|$version".toByteArray(Charsets.UTF_8))
                    .joinToString("") { "%02x".format(it) }
                    .take(ID_HEX_DIGITS)

    internal companion object {
        /** Every channel id this layer creates starts with it. */
        const val PREFIX: String = "athan_"

        /** Bumped only when channel settings that users cannot change must change (D81). */
        const val CURRENT_VERSION: Int = 1

        /** Sound of the silent playback channel. */
        const val SILENT: String = "silent"

        /** Sound of the playback channel that vibrates once when it is posted (`policy.vibrate`). */
        const val VIBRATE: String = "vibrate"

        private const val ID_HEX_DIGITS: Int = 12
    }
}
