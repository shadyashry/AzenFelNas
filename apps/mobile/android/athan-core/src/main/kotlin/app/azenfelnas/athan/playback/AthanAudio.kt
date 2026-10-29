package app.azenfelnas.athan.playback

import java.io.File

/**
 * Where Athan audio lives: `<device-protected files>/athan/<soundId>.m4a` (DESIGN.md §8.1), copied there from the
 * bundled `assets/athan/` by the app (S22), so it plays before the first unlock.
 */
internal class AthanAudio(
    private val directory: File,
) {
    /** The file of [soundId]. */
    fun fileOf(soundId: String): File = File(directory, "$soundId.m4a")

    /** Whether [soundId] is on disk. */
    fun isPresent(soundId: String): Boolean = fileOf(soundId).isFile
}
