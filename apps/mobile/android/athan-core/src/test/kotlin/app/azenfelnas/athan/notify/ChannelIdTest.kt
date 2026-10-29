package app.azenfelnas.athan.notify

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotEquals
import org.junit.jupiter.api.Test

internal class ChannelIdTest {
    @Test
    fun `REQ-ALM-024 channel ids are athan_ plus 12 hex digits of sha256 over kind, soundId and v`() {
        // printf 'ATHAN|athan_makkah_v1|1' | sha256sum | cut -c1-12
        assertEquals("athan_b09845dd13f6", ChannelSpec(ChannelKind.ATHAN, "athan_makkah_v1").id)
    }

    @Test
    fun `REQ-ALM-024 a sound change yields a new channel id`() {
        assertNotEquals(
            ChannelSpec(ChannelKind.ATHAN, "athan_makkah_v1").id,
            ChannelSpec(ChannelKind.ATHAN, "athan_madinah_v1").id,
        )
    }

    @Test
    fun `REQ-ALM-024 kind and scheme version take part in the id`() {
        val spec = ChannelSpec(ChannelKind.PRE_REMINDER, "notification_default")
        assertNotEquals(spec.id, spec.copy(kind = ChannelKind.IMSAK).id)
        assertNotEquals(spec.id, spec.copy(version = 2).id)
    }
}
