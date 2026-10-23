package app.dailymuslim.athan.schedule

import app.dailymuslim.athan.codes.EventCode
import app.dailymuslim.athan.codes.FailureCode
import app.dailymuslim.athan.plan.EventsStore
import app.dailymuslim.athan.plan.PlanStore
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.io.TempDir
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.EnumSource
import java.io.File

internal class ReconcileTest {
    @TempDir
    lateinit var dir: File

    private val clock = FixedClock(builtPlan.generatedAtUtcMs)

    private inner class Subject(
        refuse: Set<String> = emptySet(),
        exact: Boolean = true,
    ) {
        val alarms = FakeAlarmPort(refuse)
        val store = PlanStore(dir)
        val events = EventsStore(dir) { clock.nowUtcMs }
        val rearm = RearmFromPlan(store::read, ArmingWindow(capacity = 400), alarms, { exact }, clock, events)
        val apply = ApplyPlan(store, rearm, alarms)
    }

    @ParameterizedTest
    @EnumSource(ReconcileCause::class)
    fun `REQ-ALM-002 every system event re-arms from the persisted plan alone`(cause: ReconcileCause) {
        PlanStore(dir).write(builtPlanJson)
        val subject = Subject()

        val outcome = subject.rearm(cause)

        assertEquals(ReconcileOutcome.Applied(1, builtPlan.entries.size, PathMode.EXACT), outcome)
        assertEquals(builtPlan.entries.map { it.id }.toSet(), subject.alarms.armed.keys)
        val line = subject.events.drain().single()
        assertEquals(EventCode.PLAN_APPLIED, line.code)
        assertEquals(cause.label, line.attrs.reason)
    }

    @Test
    fun `REQ-ALM-027 without exact alarms the outcome reports the inexact path`() {
        PlanStore(dir).write(builtPlanJson)

        val outcome = Subject(exact = false).rearm(ReconcileCause.BOOT)

        assertEquals(PathMode.INEXACT, (outcome as ReconcileOutcome.Applied).mode)
    }

    @Test
    fun `REQ-ALM-002 a missing plan arms nothing and is recorded`() {
        val subject = Subject()

        assertEquals(ReconcileOutcome.NoPlan, subject.rearm(ReconcileCause.LOCKED_BOOT))
        assertTrue(subject.alarms.armed.isEmpty())
        assertEquals(
            RearmFromPlan.NO_PLAN,
            subject.events
                .drain()
                .single()
                .attrs.state,
        )
    }

    @Test
    fun `REQ-ALM-002 refused alarms make the outcome partial and each is logged`() {
        PlanStore(dir).write(builtPlanJson)
        val refused = builtPlan.entries.first().id
        val subject = Subject(refuse = setOf(refused))

        val outcome = subject.rearm(ReconcileCause.BOOT)

        assertEquals(ReconcileOutcome.Partial(1, builtPlan.entries.size - 1, listOf(refused)), outcome)
        val failure = subject.events.drain().single { it.code == EventCode.ALARM_SCHEDULED }
        assertEquals(FailureCode.ALARM_SCHEDULE_FAILED, failure.attrs.code)
        assertEquals(refused, failure.attrs.entryId)
    }

    @Test
    fun `REQ-ALM-002 applying a plan disarms the entries it no longer contains`() {
        val subject = Subject()
        subject.apply(planJson(generation = 1))
        val dropped = builtPlan.entries.take(3).map { it.id }

        val outcome = subject.apply(planJson(generation = 2) { it >= 3 })

        assertEquals(ReconcileOutcome.Applied(2, builtPlan.entries.size - 3, PathMode.EXACT), outcome)
        dropped.forEach { assertFalse(it in subject.alarms.armed) }
    }

    @Test
    fun `REQ-ALM-002 applying the same plan twice is idempotent`() {
        val subject = Subject()
        subject.apply(builtPlanJson)
        val first = subject.alarms.armed.toMap()

        subject.apply(builtPlanJson)

        assertEquals(first, subject.alarms.armed)
    }

    @Test
    fun `REQ-ALM-002 an older generation changes nothing`() {
        val subject = Subject()
        subject.apply(planJson(generation = 5) { it >= 3 })
        val armed = subject.alarms.armed.toMap()

        val outcome = subject.apply(planJson(generation = 4))

        assertEquals(ReconcileOutcome.Stale(current = 5, offered = 4), outcome)
        assertEquals(armed, subject.alarms.armed)
    }

    @Test
    fun `REQ-ALM-002 a document that is not a plan fails with PLAN_SCHEMA_UNSUPPORTED`() {
        val subject = Subject()

        val outcome = subject.apply("""{"schemaVersion": 1}""")

        assertEquals(ReconcileOutcome.Failed(FailureCode.PLAN_SCHEMA_UNSUPPORTED), outcome)
        assertTrue(subject.alarms.armed.isEmpty())
        assertEquals(
            FailureCode.PLAN_SCHEMA_UNSUPPORTED,
            subject.events
                .drain()
                .single()
                .attrs.code,
        )
    }
}
