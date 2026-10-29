package app.azenfelnas.athan.plan

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Wire form of `schedule_plan.v1` (DESIGN.md §7.7, Appendix B): the only input of native scheduling (ADR-002).
 * Reading, reconciliation and the N / N−1 schema gate arrive in S21.
 */
@Serializable
internal data class SchedulePlan(
    val schemaVersion: Int,
    val generation: Long,
    val contextId: String,
    val zoneId: String,
    val tzdbVersion: String,
    val generatedAtUtcMs: Long,
    val horizonEndUtcMs: Long,
    val entries: List<SchedulePlanEntry>,
    val policy: SchedulePlanPolicy,
)

/** One scheduled alarm or notification; [event] is null exactly for [EntryKind.HORIZON_WARNING]. */
@Serializable
internal data class SchedulePlanEntry(
    val id: String,
    val day: String,
    val event: PrayerEvent? = null,
    val kind: EntryKind,
    /** Absolute fire instant = displayedUtcMs (REQ-ALM-001). */
    val fireAtUtcMs: Long,
    val displayLocal: String,
    val title: LocalizedText,
    val body: LocalizedText,
    val soundId: String,
    val priority: Int,
)

/** Delivery policy of a plan. */
@Serializable
internal data class SchedulePlanPolicy(
    val locale: PlanLocale,
    val respectDnd: Boolean,
    val vibrate: Boolean,
    val fullAthanAndroid: Boolean,
    val iosClipSeconds: Int,
    /** ∈ {0, 5, 10, 15, 30} (REQ-ALM-042). */
    val preReminderMinutes: Int,
    /** Always 5 (REQ-ALM-042). */
    val snoozeMinutes: Int,
)

/** Text in both shipped locales; native renders `policy.locale`, falling back to [en]. */
@Serializable
internal data class LocalizedText(
    val ar: String,
    val en: String,
)

/** Prayer event wire names. */
@Serializable
internal enum class PrayerEvent { IMSAK, FAJR, SUNRISE, DHUHR, ASR, MAGHRIB, ISHA }

/** Kind of a plan entry. */
@Serializable
internal enum class EntryKind { ATHAN, PRE_REMINDER, IMSAK, HORIZON_WARNING }

/** Locale of pre-rendered text. */
@Serializable
internal enum class PlanLocale {
    @SerialName("ar")
    AR,

    @SerialName("en")
    EN,
}
