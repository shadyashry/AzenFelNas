package app.azenfelnas.athan.playback

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.io.TempDir
import java.io.File

internal class PreviewGateTest {
    private class FakePlayer {
        val playing = mutableListOf<File>()
        val released = mutableListOf<File>()
        val finish = mutableMapOf<File, () -> Unit>()

        fun play(
            file: File,
            onDone: () -> Unit,
        ): PreviewPlayback {
            playing += file
            finish[file] = onDone
            return PreviewPlayback { released += file }
        }
    }

    private fun voice(
        dir: File,
        name: String,
    ): File = File(dir, name).apply { writeText(name) }

    @Test
    fun `REQ-ALM-054 a new preview replaces the playing one without reporting an end`(
        @TempDir dir: File,
    ) {
        val player = FakePlayer()
        val gate = PreviewGate(player::play)
        var ended = 0
        val a = voice(dir, "a.m4a")
        val b = voice(dir, "b.m4a")

        assertTrue(gate.start(a) { ended++ })
        assertTrue(gate.start(b) { ended++ })

        assertEquals(listOf(a), player.released)
        assertEquals(0, ended)
        // The replaced player finishing late is ignored.
        player.finish.getValue(a)()
        assertEquals(0, ended)
        assertTrue(gate.isPlaying())
    }

    @Test
    fun `REQ-ALM-054 an Athan ends the preview and no preview starts until it stops`(
        @TempDir dir: File,
    ) {
        val player = FakePlayer()
        val gate = PreviewGate(player::play)
        var ended = 0
        val a = voice(dir, "a.m4a")
        gate.start(a) { ended++ }

        gate.athanStarted()

        assertEquals(listOf(a), player.released)
        assertEquals(1, ended)
        assertFalse(gate.start(a) { ended++ })
        assertFalse(gate.isPlaying())
        gate.athanEnded()
        assertTrue(gate.start(a) { ended++ })
    }

    @Test
    fun `REQ-ALM-054 stop and the end of the file release the player once`(
        @TempDir dir: File,
    ) {
        val player = FakePlayer()
        val gate = PreviewGate(player::play)
        var ended = 0
        val a = voice(dir, "a.m4a")
        gate.start(a) { ended++ }
        player.finish.getValue(a)()
        assertEquals(1, ended)
        assertFalse(gate.isPlaying())

        gate.start(a) { ended++ }
        gate.stop()
        assertEquals(1, ended)
        assertEquals(2, player.released.size)
    }

    @Test
    fun `REQ-ALM-054 a missing file never starts a player`(
        @TempDir dir: File,
    ) {
        val player = FakePlayer()
        assertFalse(PreviewGate(player::play).start(File(dir, "gone.m4a")) {})
        assertTrue(player.playing.isEmpty())
    }
}
