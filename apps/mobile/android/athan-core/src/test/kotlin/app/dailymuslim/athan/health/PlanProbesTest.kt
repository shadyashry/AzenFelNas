package app.dailymuslim.athan.health

import app.dailymuslim.athan.schedule.builtPlan
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

internal class PlanProbesTest {
    private fun positives(probes: List<ProbeResult>): Map<ProbeName, Boolean?> =
        probes.associate { it.name to it.positive }

    @Test
    fun `REQ-ALM-010 the horizon probe fails inside the 48 h warning lead`() {
        val probes = PlanProbes { true }
        val end = builtPlan.horizonEndUtcMs

        assertEquals(true, positives(probes.of(builtPlan, builtPlan.generatedAtUtcMs))[ProbeName.PLAN_HORIZON])
        assertEquals(
            false,
            positives(probes.of(builtPlan, end - PlanProbes.HORIZON_WARNING_LEAD_MS))[ProbeName.PLAN_HORIZON],
        )
    }

    @Test
    fun `REQ-ALM-023 a missing Athan sound fails the sound probe`() {
        val probes = PlanProbes { it != "athan_makkah_v1" }

        assertEquals(false, positives(probes.of(builtPlan, 0L))[ProbeName.SOUND_ASSET])
    }

    @Test
    fun `REQ-ALM-003 no plan is NOT_READY and the plan-derived probes cannot tell`() {
        val probes = PlanProbes { true }.of(null, 0L)

        assertEquals(
            mapOf(ProbeName.PLAN_PRESENT to false, ProbeName.PLAN_HORIZON to null, ProbeName.SOUND_ASSET to null),
            positives(probes),
        )
        assertEquals(HealthState.NOT_READY, EvaluateHealth()(probes, 0L, "androidExact").state)
    }
}
