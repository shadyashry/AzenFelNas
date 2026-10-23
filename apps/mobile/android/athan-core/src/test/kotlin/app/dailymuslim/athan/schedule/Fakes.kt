package app.dailymuslim.athan.schedule

import app.dailymuslim.athan.plan.SchedulePlan
import app.dailymuslim.athan.plan.fixture
import app.dailymuslim.athan.plan.wireJson

/** In-memory [AlarmPort]: the armed alarms by alarm id; ids in [refuse] are refused like a revoked permission. */
internal class FakeAlarmPort(
    private val refuse: Set<String> = emptySet(),
) : AlarmPort {
    val armed: MutableMap<String, ArmedAlarm> = linkedMapOf()

    override fun arm(alarm: ArmedAlarm): ArmResult {
        if (alarm.trigger.alarmId in refuse) return ArmResult.Refused("SecurityException")
        armed[alarm.trigger.alarmId] = alarm
        return ArmResult.Armed
    }

    override fun disarm(trigger: AlarmTrigger) {
        armed.remove(trigger.alarmId)
    }
}

/** A clock fixed at [nowUtcMs]. */
internal class FixedClock(
    var nowUtcMs: Long,
) : UtcClock {
    override fun nowUtcMs(): Long = nowUtcMs
}

/** The built Cairo plan of S20: 299 entries over 30 days (`built_android.json`). */
internal val builtPlanJson: String by lazy { fixture("schedule_plan", "valid", "built_android.json").readText() }

internal val builtPlan: SchedulePlan by lazy { wireJson.decodeFromString(SchedulePlan.serializer(), builtPlanJson) }

/** [builtPlan] as JSON with [generation] and only the entries [keep] accepts. */
internal fun planJson(
    generation: Long = builtPlan.generation,
    keep: (Int) -> Boolean = { true },
): String =
    wireJson.encodeToString(
        SchedulePlan.serializer(),
        builtPlan.copy(generation = generation, entries = builtPlan.entries.filterIndexed { i, _ -> keep(i) }),
    )
