package app.dailymuslim.athan.schedule

import app.dailymuslim.athan.codes.EventCode
import app.dailymuslim.athan.codes.FailureCode
import app.dailymuslim.athan.plan.EventAttrs
import app.dailymuslim.athan.plan.EventLevel
import app.dailymuslim.athan.plan.EventsStore
import app.dailymuslim.athan.plan.SchedulePlan

/** Outcome of a reconciliation (DESIGN.md §17.3). */
internal sealed interface ReconcileOutcome {
    /** Every alarm of the window of [generation] is armed. */
    data class Applied(
        val generation: Long,
        val armed: Int,
        val mode: PathMode,
    ) : ReconcileOutcome

    /** Some alarms were refused by the platform; [refusedIds] are their alarm ids. */
    data class Partial(
        val generation: Long,
        val armed: Int,
        val refusedIds: List<String>,
    ) : ReconcileOutcome

    /** There is no readable plan, so nothing is armed (Health: no plan ⇒ NOT_READY). */
    data object NoPlan : ReconcileOutcome

    /** The offered plan is older than the persisted one, which stays armed (REQ-ALM-002). */
    data class Stale(
        val current: Long,
        val offered: Long,
    ) : ReconcileOutcome

    /** Nothing was applied, for [code]; [detail] is an exception class name, never document content. */
    data class Failed(
        val code: FailureCode,
        val detail: String? = null,
    ) : ReconcileOutcome
}

/** Platform path of the armed Athan alarms (§7.8 `platformPath`). */
internal enum class PathMode(
    val label: String,
) {
    EXACT("androidExact"),
    INEXACT("androidInexact"),
}

/**
 * Arms the alarm window of the persisted plan (REQ-ALM-002): runs on every system event and after every fire,
 * reads only the `SchedulePlan` (§0.2 rule 5) and needs no Dart isolate. Re-arming is idempotent because the
 * request code derives from the entry id (REQ-ALM-021).
 */
internal class RearmFromPlan(
    private val readPlan: () -> SchedulePlan?,
    private val window: ArmingWindow,
    private val alarms: AlarmPort,
    private val exactGate: ExactAlarmGate,
    private val clock: UtcClock,
    private val events: EventsStore,
) {
    operator fun invoke(cause: ReconcileCause): ReconcileOutcome {
        val plan = readPlan()
        val outcome = if (plan == null) ReconcileOutcome.NoPlan else arm(plan)
        record(cause, plan?.generation, outcome)
        return outcome
    }

    private fun arm(plan: SchedulePlan): ReconcileOutcome {
        val exact = exactGate.canScheduleExact()
        val wanted = window.alarms(plan, clock.nowUtcMs(), exact)
        val refused = wanted.filter { alarms.arm(it) is ArmResult.Refused }.map { it.trigger.alarmId }
        val armed = wanted.size - refused.size
        return if (refused.isEmpty()) {
            ReconcileOutcome.Applied(plan.generation, armed, if (exact) PathMode.EXACT else PathMode.INEXACT)
        } else {
            ReconcileOutcome.Partial(plan.generation, armed, refused)
        }
    }

    /** Appends the event of [outcome] (also used by [ApplyPlan]). */
    fun record(
        cause: ReconcileCause,
        generation: Long?,
        outcome: ReconcileOutcome,
    ) {
        when (outcome) {
            is ReconcileOutcome.Applied -> {
                events.append(
                    EventCode.PLAN_APPLIED,
                    EventAttrs(
                        generation = generation,
                        count = outcome.armed.toLong(),
                        reason = cause.label,
                        state = outcome.mode.label,
                    ),
                )
            }

            is ReconcileOutcome.Partial -> {
                events.append(
                    EventCode.PLAN_APPLIED,
                    EventAttrs(generation = generation, count = outcome.armed.toLong(), reason = cause.label),
                    EventLevel.WARN,
                )
                outcome.refusedIds.forEach { id ->
                    events.append(
                        EventCode.ALARM_SCHEDULED,
                        EventAttrs(code = FailureCode.ALARM_SCHEDULE_FAILED, generation = generation, entryId = id),
                        EventLevel.ERROR,
                    )
                }
            }

            ReconcileOutcome.NoPlan -> {
                events.append(
                    EventCode.PLAN_APPLIED,
                    EventAttrs(reason = cause.label, state = NO_PLAN),
                    EventLevel.WARN,
                )
            }

            is ReconcileOutcome.Stale -> {
                events.append(
                    EventCode.PLAN_APPLIED,
                    EventAttrs(generation = outcome.offered, reason = cause.label, state = STALE),
                    EventLevel.WARN,
                )
            }

            is ReconcileOutcome.Failed -> {
                events.append(
                    EventCode.PLAN_APPLIED,
                    EventAttrs(code = outcome.code, reason = cause.label, state = outcome.detail),
                    EventLevel.ERROR,
                )
            }
        }
    }

    internal companion object {
        /** `attrs.state` of a reconciliation without a plan. */
        const val NO_PLAN: String = "noPlan"

        /** `attrs.state` of an offered plan older than the persisted one. */
        const val STALE: String = "stale"
    }
}
