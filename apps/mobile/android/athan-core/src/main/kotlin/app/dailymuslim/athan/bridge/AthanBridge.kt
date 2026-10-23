package app.dailymuslim.athan.bridge

import app.dailymuslim.athan.health.HealthReport
import app.dailymuslim.athan.plan.EventLogEntry
import app.dailymuslim.athan.schedule.AlarmTrigger
import app.dailymuslim.athan.schedule.ArmResult
import app.dailymuslim.athan.schedule.PathMode
import app.dailymuslim.athan.schedule.ReconcileOutcome

/**
 * The operations of `AthanSchedulerApi` (DESIGN.md §7.8) over the [AthanGraph]. The pigeon host that exposes them
 * to Dart is generated with the contract in S23 (D81); until then the app module has no caller.
 */
internal class AthanBridge(
    private val graph: AthanGraph,
) {
    /** Persists [schedulePlanJson] and arms its window; idempotent by entry id + generation. */
    fun reconcile(schedulePlanJson: String): ReconcileOutcome = graph.applyPlan(schedulePlanJson)

    /** Disarms every entry of the persisted plan when its generation is below [generation]. */
    fun cancelGenerationsBelow(generation: Long) {
        val plan = graph.planStore.read() ?: return
        if (plan.generation >= generation) return
        plan.entries.forEach {
            graph.alarms.disarm(AlarmTrigger.PlanEntry(it.id))
            graph.alarms.disarm(AlarmTrigger.Snooze(it.id))
        }
    }

    /** Evaluates the Athan Health probes now (§8.3). */
    fun health(): HealthReport {
        val now = graph.clock.nowUtcMs()
        val path = if (graph.alarms.canScheduleExact()) PathMode.EXACT else PathMode.INEXACT
        return graph.evaluateHealth(graph.probes.all(graph.planStore.read(), now), now, path.label)
    }

    /** Arms the Athan Test (REQ-ALM-040). */
    fun startTest(
        testId: String,
        fireInSeconds: Int,
        soundId: String,
    ): ArmResult = graph.startTest(testId, fireInSeconds, soundId)

    /** Receipts and system events since the last drain (REQ-ALM-041); Dart drains on every start. */
    fun drainEvents(): List<EventLogEntry> = graph.events.drain()
}
