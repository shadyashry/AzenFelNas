package app.dailymuslim

import app.dailymuslim.athan.bridge.AthanCoreHost
import app.dailymuslim.pigeon.AthanHealthReport
import app.dailymuslim.pigeon.AthanSchedulerApi
import app.dailymuslim.pigeon.HealthReason
import app.dailymuslim.pigeon.HealthState
import app.dailymuslim.pigeon.ProbeResult
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.withContext

/**
 * The pigeon `AthanSchedulerApi` host over `athan-core` (DESIGN.md §7.8, §15 D83). It only maps types and moves
 * work to [io]; every decision stays in `athan-core`. Unknown labels map to `unknown`/are dropped, never to `ready`.
 */
internal class AthanSchedulerHost(
    private val core: AthanCoreHost,
    private val io: CoroutineDispatcher,
) : AthanSchedulerApi {
    override suspend fun reconcile(schedulePlanJson: String) {
        withContext(io) { core.reconcile(schedulePlanJson) }
    }

    override suspend fun cancelGenerationsBelow(generation: Long) {
        withContext(io) { core.cancelGenerationsBelow(generation) }
    }

    override suspend fun health(): AthanHealthReport =
        withContext(io) {
            val health = core.health()
            AthanHealthReport(
                state = HealthState.entries.firstOrNull { it.label() == health.state } ?: HealthState.UNKNOWN,
                reasons = health.reasons.mapNotNull { label -> HealthReason.entries.firstOrNull { it.label() == label } },
                probes = health.probes.map { ProbeResult(it.name, it.positive, it.detail) },
                evaluatedAtUtcMs = health.evaluatedAtUtcMs,
                platformPath = health.platformPath,
            )
        }

    override suspend fun startTest(
        testId: String,
        fireInSeconds: Long,
        soundId: String,
    ): Boolean = withContext(io) { core.startTest(testId, fireInSeconds.toInt(), soundId) }

    override suspend fun drainEvents(): List<String> = withContext(io) { core.drainEvents() }

    override suspend fun writeSnapshot(snapshotJson: String): Boolean =
        withContext(io) { core.writeSnapshot(snapshotJson) }
}

/** The Dart enum name of a pigeon enum constant (`NOT_READY` → `notReady`), as the Kotlin labels are written. */
private fun Enum<*>.label(): String =
    name.lowercase().split('_').mapIndexed { i, part -> if (i == 0) part else part.replaceFirstChar { it.uppercase() } }
        .joinToString("")
