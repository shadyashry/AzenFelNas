package app.dailymuslim.athan.plan

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/** Wire form of `snapshot.v1` (DESIGN.md Appendix I): 48 h of displayed times; widgets never recalculate. */
@Serializable
internal data class Snapshot(
    val schemaVersion: Int,
    val contextId: String,
    val zoneId: String,
    val tzdbVersion: String,
    val generatedAtUtcMs: Long,
    val locale: PlanLocale,
    val items: List<SnapshotItem>,
    val skyTimeline: List<SkySegment>,
    val health: SnapshotHealth,
)

/** One displayed time. */
@Serializable
internal data class SnapshotItem(
    val day: String,
    val event: PrayerEvent,
    val displayedUtcMs: Long,
    val displayLocal: String,
    val confidence: SnapshotConfidence,
    val dayOffset: Int,
)

/** Confidence label; [detail] is null exactly for [ConfidenceKind.CALCULATED] (REQ-UX-001). */
@Serializable
internal data class SnapshotConfidence(
    val kind: ConfidenceKind,
    val detail: String? = null,
)

/** Confidence label kinds. */
@Serializable
internal enum class ConfidenceKind { CALCULATED, AUTHORITY_ALIGNED, VERIFIED, ESTIMATED, OBSERVED, UNKNOWN }

/** Start of a sky phase. */
@Serializable
internal data class SkySegment(
    val fromUtcMs: Long,
    val phase: SkyPhase,
)

/** Sky phases of Appendix G. */
@Serializable
internal enum class SkyPhase {
    @SerialName("night")
    NIGHT,

    @SerialName("astronomicalDawn")
    ASTRONOMICAL_DAWN,

    @SerialName("nauticalDawn")
    NAUTICAL_DAWN,

    @SerialName("civilDawn")
    CIVIL_DAWN,

    @SerialName("goldenMorning")
    GOLDEN_MORNING,

    @SerialName("day")
    DAY,

    @SerialName("goldenEvening")
    GOLDEN_EVENING,

    @SerialName("civilDusk")
    CIVIL_DUSK,

    @SerialName("nauticalDusk")
    NAUTICAL_DUSK,

    @SerialName("astronomicalDusk")
    ASTRONOMICAL_DUSK,
}

/** Athan Health summary. */
@Serializable
internal data class SnapshotHealth(
    val state: HealthState,
    val reasonsCount: Int,
)

/** Athan Health states (§8.3). */
@Serializable
internal enum class HealthState { READY, LIMITED, NOT_READY, UNKNOWN }
