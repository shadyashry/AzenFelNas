package app.azenfelnas.athan.playback

import app.azenfelnas.athan.plan.wireJson
import kotlinx.serialization.Serializable
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import java.nio.file.Files
import java.nio.file.StandardCopyOption
import java.security.MessageDigest

/** The members of an `athan_audio_manifest.v1` sound the installer needs. */
@Serializable
internal data class BundledSound(
    val soundId: String,
    val file: String,
    val sha256: String,
)

/** An `athan_audio_manifest.v1` document, reduced to its sounds. */
@Serializable
internal data class BundledManifest(
    val sounds: List<BundledSound>,
)

/**
 * Copies the app's bundled Athan sounds into [AthanAudio]'s device-protected directory (DESIGN.md §8.1, §15 D94),
 * so the playback service finds `<soundId>.m4a` before the first unlock. A sound already there with the manifest's
 * sha256 is kept; any other is replaced through `<name>.tmp`, fsync and an atomic rename, and only a copy whose
 * sha256 matches the manifest is kept. Idempotent: run it on every app start.
 */
internal class BundledAudioInstaller(
    private val audio: AthanAudio,
) {
    /**
     * Installs the sounds of [manifestJson], reading each bundled file through [open] by its manifest `file` path
     * (null when it is not bundled). Returns the ids now present with the manifest's content; never throws for a
     * malformed manifest, a missing file or a checksum mismatch.
     */
    fun install(
        manifestJson: String,
        open: (String) -> InputStream?,
    ): List<String> {
        val manifest =
            runCatching { wireJson.decodeFromString(BundledManifest.serializer(), manifestJson) }.getOrNull()
                ?: return emptyList()
        return manifest.sounds.filter { install(it, open) }.map { it.soundId }
    }

    /**
     * Installs a downloaded voice (§15 D111): copies [source] to `<soundId>.m4a` when its sha256 is [sha256], the
     * same way as a bundled sound. False for an unsafe id, a missing source or a checksum mismatch; never throws for
     * those.
     */
    fun installFile(
        soundId: String,
        source: File,
        sha256: String,
    ): Boolean =
        SHA256.matches(sha256) &&
            install(BundledSound(soundId, source.name, sha256)) { if (source.isFile) source.inputStream() else null }

    /** Deletes the copy of [soundId]; true when none is left. */
    fun remove(soundId: String): Boolean =
        SOUND_ID.matches(soundId) && audio.fileOf(soundId).let { !it.exists() || it.delete() }

    private fun install(
        sound: BundledSound,
        open: (String) -> InputStream?,
    ): Boolean {
        if (!SOUND_ID.matches(sound.soundId)) return false
        val target = audio.fileOf(sound.soundId)
        return (target.isFile && sha256Of(target) == sound.sha256) || copy(sound, target, open)
    }

    /** Copies [sound] from the bundle to [target] when the copy matches the manifest sha256. */
    private fun copy(
        sound: BundledSound,
        target: File,
        open: (String) -> InputStream?,
    ): Boolean {
        val source = open(sound.file) ?: return false
        val directory = checkNotNull(target.absoluteFile.parentFile) { "no parent directory for $target" }
        directory.mkdirs()
        val tmp = File(directory, target.name + ".tmp")
        source.use { input ->
            FileOutputStream(tmp).use { out ->
                input.copyTo(out)
                out.fd.sync()
            }
        }
        val valid = sha256Of(tmp) == sound.sha256
        if (valid) {
            Files.move(
                tmp.toPath(),
                target.toPath(),
                StandardCopyOption.ATOMIC_MOVE,
                StandardCopyOption.REPLACE_EXISTING,
            )
        } else {
            tmp.delete()
        }
        return valid
    }

    private companion object {
        /** The manifest's `soundId` pattern; it also keeps the file name inside the directory. */
        val SOUND_ID: Regex = Regex("^[a-z0-9_]+$")

        /** A lowercase hex SHA-256. */
        val SHA256: Regex = Regex("^[a-f0-9]{64}$")

        fun sha256Of(file: File): String {
            val digest = MessageDigest.getInstance("SHA-256")
            file.inputStream().use { input ->
                val buffer = ByteArray(BUFFER_BYTES)
                while (true) {
                    val read = input.read(buffer)
                    if (read < 0) break
                    digest.update(buffer, 0, read)
                }
            }
            return digest.digest().joinToString("") { "%02x".format(it) }
        }

        const val BUFFER_BYTES: Int = 64 * 1024
    }
}
