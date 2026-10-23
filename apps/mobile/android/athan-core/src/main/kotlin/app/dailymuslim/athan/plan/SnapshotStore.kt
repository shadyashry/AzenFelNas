package app.dailymuslim.athan.plan

import java.io.File

/** Outcome of [SnapshotStore.write]. */
internal sealed interface SnapshotWriteOutcome {
    /** The snapshot is now the persisted one. */
    data object Written : SnapshotWriteOutcome

    /** The document is not a `snapshot.v1` snapshot; nothing changed. */
    data class Rejected(
        val reason: String,
    ) : SnapshotWriteOutcome
}

/**
 * The persisted widget `Snapshot` (DESIGN.md §7.7, Appendix I): `<directory>/snapshot.json`, written beside the
 * plan; widgets read it and never recalculate.
 *
 * Contract: [write] validates the document before an atomic replace; [read] returns null for a missing or
 * unreadable file and never throws.
 */
internal class SnapshotStore(
    directory: File,
) {
    private val file = AtomicTextFile(File(directory, SNAPSHOT_FILE))

    /** Persists [snapshotJson] when it is a `snapshot.v1` document. */
    @Synchronized
    fun write(snapshotJson: String): SnapshotWriteOutcome {
        val outcome =
            when (val decoded = decodeWire(Snapshot.serializer(), snapshotJson)) {
                is WireDecode.Malformed -> {
                    SnapshotWriteOutcome.Rejected("not a snapshot.v1 document: ${decoded.reason}")
                }

                is WireDecode.Decoded -> {
                    if (decoded.value.schemaVersion == PlanStore.SCHEMA_VERSION) {
                        SnapshotWriteOutcome.Written
                    } else {
                        SnapshotWriteOutcome.Rejected("schemaVersion ${decoded.value.schemaVersion}")
                    }
                }
            }
        if (outcome is SnapshotWriteOutcome.Written) file.write(snapshotJson)
        return outcome
    }

    /** The persisted snapshot, or null. */
    fun read(): Snapshot? = file.read()?.let { decodeWire(Snapshot.serializer(), it).valueOrNull() }

    internal companion object {
        /** File name inside the plan directory. */
        const val SNAPSHOT_FILE: String = "snapshot.json"
    }
}
