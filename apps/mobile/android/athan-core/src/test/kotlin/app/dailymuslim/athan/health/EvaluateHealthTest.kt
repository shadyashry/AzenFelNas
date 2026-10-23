package app.dailymuslim.athan.health

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

internal class EvaluateHealthTest {
    private val evaluate = EvaluateHealth()

    private fun allPositive(): List<ProbeResult> = ProbeName.entries.map { ProbeResult(it, true) }

    private fun with(
        name: ProbeName,
        positive: Boolean?,
    ): List<ProbeResult> = allPositive().map { if (it.name == name) ProbeResult(name, positive) else it }

    private fun stateOf(probes: List<ProbeResult>): HealthState = evaluate(probes, 0L, "androidExact").state

    @Test
    fun `REQ-ALM-003 READY requires every gating probe to be positive`() {
        val report = evaluate(allPositive(), 7L, "androidExact")

        assertEquals(HealthReport(HealthState.READY, emptyList(), allPositive(), 7L, "androidExact"), report)
    }

    @Test
    fun `REQ-ALM-003 a probe that cannot tell never yields READY`() {
        ProbeName.entries
            .filter { it.severity == Severity.BLOCKING || it.severity == Severity.DEGRADING }
            .forEach { assertEquals(HealthState.UNKNOWN, stateOf(with(it, null)), it.label) }
        assertEquals(HealthState.UNKNOWN, stateOf(emptyList()))
    }

    @Test
    fun `REQ-ALM-027 inexact fallback is LIMITED(inexactFallback)`() {
        val report = evaluate(with(ProbeName.EXACT_ALARMS, false), 0L, "androidInexact")

        assertEquals(HealthState.LIMITED, report.state)
        assertEquals(listOf(HealthReason.INEXACT_FALLBACK), report.reasons)
    }

    @Test
    fun `REQ-ALM-026 notifications off is NOT_READY(needsNotificationPermission) and beats LIMITED`() {
        val probes =
            with(ProbeName.NOTIFICATIONS_ENABLED, false).map {
                if (it.name ==
                    ProbeName.EXACT_ALARMS
                ) {
                    ProbeResult(it.name, false)
                } else {
                    it
                }
            }

        val report = evaluate(probes, 0L, "androidInexact")

        assertEquals(HealthState.NOT_READY, report.state)
        assertEquals(listOf(HealthReason.NEEDS_NOTIFICATION_PERMISSION, HealthReason.INEXACT_FALLBACK), report.reasons)
    }

    @Test
    fun `REQ-ALM-025 a previous force-stop is surfaced without changing the state`() {
        val report = evaluate(with(ProbeName.NO_PREVIOUS_FORCE_STOP, false), 0L, "androidExact")

        assertEquals(HealthState.READY, report.state)
        assertEquals(listOf(HealthReason.FORCE_STOPPED_PREVIOUSLY), report.reasons)
    }

    @Test
    fun `REQ-ALM-003 informational probes never change the state`() {
        val probes =
            with(ProbeName.IGNORING_BATTERY_OPTIMIZATIONS, false).map {
                if (it.name ==
                    ProbeName.DND_ALLOWS_ALARMS
                ) {
                    ProbeResult(it.name, null)
                } else {
                    it
                }
            }

        assertEquals(HealthState.READY, stateOf(probes))
    }
}
