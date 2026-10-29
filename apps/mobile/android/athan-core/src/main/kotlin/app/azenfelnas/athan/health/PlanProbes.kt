package app.azenfelnas.athan.health

import app.azenfelnas.athan.plan.EntryKind
import app.azenfelnas.athan.plan.SchedulePlan

/**
 * Probes answered by the persisted plan alone: present, horizon not ending (the Android `HORIZON_WARNING` lead
 * of 48 h, D80) and every Athan sound present on disk ([soundPresent], REQ-ALM-023 audio).
 */
internal class PlanProbes(
    private val soundPresent: (String) -> Boolean,
) {
    fun of(
        plan: SchedulePlan?,
        nowUtcMs: Long,
    ): List<ProbeResult> {
        if (plan == null) {
            return listOf(
                ProbeResult(ProbeName.PLAN_PRESENT, false),
                ProbeResult(ProbeName.PLAN_HORIZON, null, NO_PLAN),
                ProbeResult(ProbeName.SOUND_ASSET, null, NO_PLAN),
            )
        }
        val sounds =
            plan.entries
                .filter { it.kind == EntryKind.ATHAN }
                .map { it.soundId }
                .distinct()
        val missing = sounds.count { !soundPresent(it) }
        return listOf(
            ProbeResult(ProbeName.PLAN_PRESENT, true),
            ProbeResult(ProbeName.PLAN_HORIZON, plan.horizonEndUtcMs - nowUtcMs > HORIZON_WARNING_LEAD_MS),
            ProbeResult(ProbeName.SOUND_ASSET, missing == 0, if (missing == 0) null else "$missing missing"),
        )
    }

    internal companion object {
        /** Android `HORIZON_WARNING` lead before `horizonEndUtcMs` (§7.7, D80). */
        const val HORIZON_WARNING_LEAD_MS: Long = 48L * 60 * 60 * 1000

        private const val NO_PLAN: String = "no plan"
    }
}
