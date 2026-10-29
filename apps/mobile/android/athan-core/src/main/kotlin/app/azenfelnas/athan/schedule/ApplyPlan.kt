package app.azenfelnas.athan.schedule

import app.azenfelnas.athan.codes.FailureCode
import app.azenfelnas.athan.plan.PlanStore
import app.azenfelnas.athan.plan.PlanWriteOutcome
import java.io.IOException

/**
 * The bridge's `reconcile(schedulePlanJson)` (DESIGN.md §7.8): persists a new plan, cancels the alarms of entries
 * it no longer contains and arms the new window. Idempotent by entry id + generation: the same plan again
 * re-arms the same request codes, and an older generation changes nothing (REQ-ALM-002).
 */
internal class ApplyPlan(
    private val store: PlanStore,
    private val rearm: RearmFromPlan,
    private val alarms: AlarmPort,
) {
    operator fun invoke(planJson: String): ReconcileOutcome {
        val previous = store.read()
        val written =
            try {
                store.write(planJson)
            } catch (e: IOException) {
                // Only the class name is logged: the message may name paths (REQ-PRIV-001).
                return failed(FailureCode.PLAN_WRITE_FAILED, e.javaClass.simpleName)
            }
        return when (written) {
            is PlanWriteOutcome.Rejected -> {
                failed(FailureCode.PLAN_SCHEMA_UNSUPPORTED)
            }

            is PlanWriteOutcome.Stale -> {
                ReconcileOutcome.Stale(written.current, written.offered).also {
                    rearm.record(ReconcileCause.PLAN_APPLIED, written.current, it)
                }
            }

            is PlanWriteOutcome.Written -> {
                val kept =
                    store
                        .read()
                        ?.entries
                        .orEmpty()
                        .map { it.id }
                        .toSet()
                previous?.entries.orEmpty().filter { it.id !in kept }.forEach { entry ->
                    alarms.disarm(AlarmTrigger.PlanEntry(entry.id))
                    alarms.disarm(AlarmTrigger.Snooze(entry.id))
                }
                rearm(ReconcileCause.PLAN_APPLIED)
            }
        }
    }

    private fun failed(
        code: FailureCode,
        detail: String? = null,
    ): ReconcileOutcome =
        ReconcileOutcome.Failed(code, detail).also {
            rearm.record(ReconcileCause.PLAN_APPLIED, null, it)
        }
}
