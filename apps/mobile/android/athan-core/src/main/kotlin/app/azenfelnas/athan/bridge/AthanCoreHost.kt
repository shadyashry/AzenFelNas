package app.azenfelnas.athan.bridge

import android.content.Context
import app.azenfelnas.athan.plan.EventLogEntry
import app.azenfelnas.athan.plan.wireJson
import app.azenfelnas.athan.schedule.ArmResult

/**
 * The public face of `athan-core` for the app module's pigeon host (DESIGN.md §7.8, §15 D83): plain types only, so
 * every model stays `internal`. Calls block on I/O; the caller runs them off the main thread.
 */
public class AthanCoreHost(
    context: Context,
) {
    private val bridge: AthanBridge = AthanBridge(AthanGraph(context))

    /** Persists and arms a `schedule_plan.v1` document; the outcome is a `PLAN_APPLIED` event. */
    public fun reconcile(schedulePlanJson: String) {
        bridge.reconcile(schedulePlanJson)
    }

    /** Disarms entries of plans older than [generation]. */
    public fun cancelGenerationsBelow(generation: Long) {
        bridge.cancelGenerationsBelow(generation)
    }

    /** Evaluates every probe now. */
    public fun health(): HostHealth =
        bridge.health().let { report ->
            HostHealth(
                state = report.state.label,
                reasons = report.reasons.map { it.label },
                probes = report.probes.map { HostProbe(it.name.label, it.positive, it.detail) },
                evaluatedAtUtcMs = report.evaluatedAtUtcMs,
                platformPath = report.platformPath,
            )
        }

    /** Arms the Athan Test (REQ-ALM-040); false when the platform refused. */
    public fun startTest(
        testId: String,
        fireInSeconds: Int,
        soundId: String,
    ): Boolean = bridge.startTest(testId, fireInSeconds, soundId) is ArmResult.Armed

    /** Drains `events.jsonl` as `event_log.v1` JSON documents (REQ-ALM-041). */
    public fun drainEvents(): List<String> =
        bridge.drainEvents().map { wireJson.encodeToString(EventLogEntry.serializer(), it) }

    /** Persists a `snapshot.v1` document and redraws the widgets; false when it was refused. */
    public fun writeSnapshot(snapshotJson: String): Boolean = bridge.writeSnapshot(snapshotJson)
}

/** `AthanHealthReport` of §7.8 with labels in place of enums. */
public data class HostHealth(
    val state: String,
    val reasons: List<String>,
    val probes: List<HostProbe>,
    val evaluatedAtUtcMs: Long,
    val platformPath: String,
)

/** `ProbeResult` of §7.8; [positive] is null when the platform cannot tell. */
public data class HostProbe(
    val name: String,
    val positive: Boolean?,
    val detail: String?,
)
