package app.dailymuslim.athan.health

/**
 * The Athan Health state machine of DESIGN.md §8.3 (D81): a blocking probe that is `false` ⇒ `NOT_READY`, else a
 * degrading one ⇒ `LIMITED`, else any blocking or degrading probe that cannot tell ⇒ `UNKNOWN`; `READY` needs
 * every such probe `positive == true` (REQ-ALM-003). Reasons list every failing probe that has one.
 */
internal class EvaluateHealth {
    operator fun invoke(
        probes: List<ProbeResult>,
        evaluatedAtUtcMs: Long,
        platformPath: String,
    ): HealthReport {
        val gating = probes.filter { it.name.severity == Severity.BLOCKING || it.name.severity == Severity.DEGRADING }
        val state =
            when {
                gating.any { it.name.severity == Severity.BLOCKING && it.positive == false } -> HealthState.NOT_READY
                gating.any { it.positive == false } -> HealthState.LIMITED
                gating.isEmpty() || gating.any { it.positive == null } -> HealthState.UNKNOWN
                else -> HealthState.READY
            }
        val reasons = probes.filter { it.positive == false }.mapNotNull { it.name.reason }.distinct()
        return HealthReport(state, reasons, probes, evaluatedAtUtcMs, platformPath)
    }
}
