package app.azenfelnas.athan.playback

import org.junit.jupiter.api.Assertions.assertArrayEquals
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.io.TempDir
import java.io.ByteArrayInputStream
import java.io.File
import java.io.InputStream
import java.security.MessageDigest

internal class BundledAudioInstallerTest {
    private val athan = "athan bytes".toByteArray()
    private val fajr = "fajr bytes".toByteArray()

    private fun hex(bytes: ByteArray): String =
        MessageDigest.getInstance("SHA-256").digest(bytes).joinToString("") { "%02x".format(it) }

    private fun manifest(vararg sounds: Triple<String, String, String>): String =
        sounds.joinToString(prefix = """{"sounds":[""", postfix = "]}") { (id, file, sha) ->
            """{"soundId":"$id","file":"$file","durationMs":1,"licenceRef":"x","sha256":"$sha"}"""
        }

    private fun bundle(vararg files: Pair<String, ByteArray>): (String) -> InputStream? {
        val map = files.toMap()
        return { path -> map[path]?.let(::ByteArrayInputStream) }
    }

    @Test
    fun `REQ-ALM-022 copies each bundled sound to soundId m4a in the protected directory`(
        @TempDir dir: File,
    ) {
        val audio = AthanAudio(File(dir, "athan"))
        val installed =
            BundledAudioInstaller(audio).install(
                manifest(
                    Triple("rifaat", "athan/rifaat.m4a", hex(athan)),
                    Triple("rifaat_fajr", "athan/rifaat_fajr.m4a", hex(fajr)),
                ),
                bundle("athan/rifaat.m4a" to athan, "athan/rifaat_fajr.m4a" to fajr),
            )

        assertEquals(listOf("rifaat", "rifaat_fajr"), installed)
        assertArrayEquals(athan, audio.fileOf("rifaat").readBytes())
        assertArrayEquals(fajr, audio.fileOf("rifaat_fajr").readBytes())
    }

    @Test
    fun `an installed sound with the manifest checksum is kept without reading the bundle`(
        @TempDir dir: File,
    ) {
        val audio = AthanAudio(File(dir, "athan"))
        val installer = BundledAudioInstaller(audio)
        val doc = manifest(Triple("rifaat", "athan/rifaat.m4a", hex(athan)))
        installer.install(doc, bundle("athan/rifaat.m4a" to athan))
        var reads = 0

        val installed =
            installer.install(doc) {
                reads++
                null
            }

        assertEquals(listOf("rifaat"), installed)
        assertEquals(0, reads)
    }

    @Test
    fun `a damaged installed sound is replaced from the bundle`(
        @TempDir dir: File,
    ) {
        val audio = AthanAudio(File(dir, "athan"))
        File(dir, "athan").mkdirs()
        audio.fileOf("rifaat").writeBytes("torn".toByteArray())

        BundledAudioInstaller(audio).install(
            manifest(Triple("rifaat", "athan/rifaat.m4a", hex(athan))),
            bundle("athan/rifaat.m4a" to athan),
        )

        assertArrayEquals(athan, audio.fileOf("rifaat").readBytes())
    }

    @Test
    fun `a bundled file that does not match its checksum is not installed and leaves no temporary file`(
        @TempDir dir: File,
    ) {
        val audio = AthanAudio(File(dir, "athan"))

        val installed =
            BundledAudioInstaller(audio).install(
                manifest(Triple("rifaat", "athan/rifaat.m4a", hex(fajr))),
                bundle("athan/rifaat.m4a" to athan),
            )

        assertTrue(installed.isEmpty())
        assertFalse(audio.isPresent("rifaat"))
        assertTrue(File(dir, "athan").listFiles().orEmpty().isEmpty())
    }

    @Test
    fun `a missing file, an unsafe soundId and a malformed manifest install nothing and never throw`(
        @TempDir dir: File,
    ) {
        val installer = BundledAudioInstaller(AthanAudio(File(dir, "athan")))

        assertTrue(installer.install(manifest(Triple("rifaat", "athan/rifaat.m4a", hex(athan))), bundle()).isEmpty())
        assertTrue(
            installer
                .install(
                    manifest(Triple("../escape", "athan/rifaat.m4a", hex(athan))),
                    bundle("athan/rifaat.m4a" to athan),
                ).isEmpty(),
        )
        assertTrue(installer.install("not json", bundle()).isEmpty())
    }
}
