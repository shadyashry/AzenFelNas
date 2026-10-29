package app.azenfelnas.athan.plan

import java.io.File

/** Outcome of [PlanStore.write]. */
internal sealed interface PlanWriteOutcome {
    /** The plan of [generation] is now the persisted one. */
    data class Written(
        val generation: Long,
    ) : PlanWriteOutcome

    /** An older generation was offered; the persisted plan of [current] stays. */
    data class Stale(
        val current: Long,
        val offered: Long,
    ) : PlanWriteOutcome

    /** The document is not a `schedule_plan.v1` plan; nothing changed. */
    data class Rejected(
        val reason: String,
    ) : PlanWriteOutcome
}

/**
 * The persisted `SchedulePlan` (ADR-002, DESIGN.md §8.1): `<directory>/plan.json`, in device-protected storage
 * so receivers can re-arm before the first unlock (REQ-ALM-022). Native code reads nothing else (§0.2 rule 5).
 *
 * Contract: [write] validates the document and never replaces a plan with an older generation; the same
 * generation is written again (reconcile is idempotent, §7.8). [read] returns null for a missing or
 * unreadable file and never throws.
 */
internal class PlanStore(
    directory: File,
) {
    private val file = AtomicTextFile(File(directory, PLAN_FILE))

    /** Persists [planJson] when it is a plan at least as new as the stored one. */
    @Synchronized
    fun write(planJson: String): PlanWriteOutcome {
        val outcome =
            when (val decoded = decodeWire(SchedulePlan.serializer(), planJson)) {
                is WireDecode.Malformed -> {
                    PlanWriteOutcome.Rejected(
                        "not a schedule_plan.v1 document: ${decoded.reason}",
                    )
                }

                is WireDecode.Decoded -> {
                    admit(decoded.value)
                }
            }
        if (outcome is PlanWriteOutcome.Written) file.write(planJson)
        return outcome
    }

    /** The persisted plan, or null. */
    fun read(): SchedulePlan? = file.read()?.let { decodeWire(SchedulePlan.serializer(), it).valueOrNull() }

    private fun admit(plan: SchedulePlan): PlanWriteOutcome {
        val current = read()
        return when {
            plan.schemaVersion != SCHEMA_VERSION -> {
                PlanWriteOutcome.Rejected("schemaVersion ${plan.schemaVersion}")
            }

            current != null && plan.generation < current.generation -> {
                PlanWriteOutcome.Stale(current = current.generation, offered = plan.generation)
            }

            else -> {
                PlanWriteOutcome.Written(plan.generation)
            }
        }
    }

    internal companion object {
        /** File name inside the plan directory (§8.1). */
        const val PLAN_FILE: String = "plan.json"

        /** The schema version this reader accepts. */
        const val SCHEMA_VERSION: Int = 1
    }
}
