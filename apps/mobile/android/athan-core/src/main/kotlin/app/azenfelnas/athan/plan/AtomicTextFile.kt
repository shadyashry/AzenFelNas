package app.azenfelnas.athan.plan

import java.io.File
import java.io.FileOutputStream
import java.nio.file.Files
import java.nio.file.StandardCopyOption

/**
 * A UTF-8 text file replaced through `<name>.tmp`, fsync and an atomic rename (DESIGN.md §8.1), so a reader
 * sees the previous or the new content and never a torn write.
 */
internal class AtomicTextFile(
    private val file: File,
) {
    /** The content, or null when the file does not exist. */
    fun read(): String? = if (file.isFile) file.readText(Charsets.UTF_8) else null

    /** Replaces the content with [text]. */
    fun write(text: String) {
        val directory = checkNotNull(file.absoluteFile.parentFile) { "no parent directory for $file" }
        directory.mkdirs()
        val tmp = File(directory, file.name + ".tmp")
        FileOutputStream(tmp).use { out ->
            out.write(text.toByteArray(Charsets.UTF_8))
            out.fd.sync()
        }
        Files.move(tmp.toPath(), file.toPath(), StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING)
    }
}
