package app.dailymuslim.athan.health

/** `HealthState` of DESIGN.md §7.8; [label] is the pigeon/Dart enum name. */
internal enum class HealthState(
    val label: String,
) {
    READY("ready"),
    LIMITED("limited"),
    NOT_READY("notReady"),
    UNKNOWN("unknown"),
}

/** `HealthReason` of DESIGN.md §7.8; [label] is the pigeon/Dart enum name. */
internal enum class HealthReason(
    val label: String,
) {
    NEEDS_NOTIFICATION_PERMISSION("needsNotificationPermission"),
    NEEDS_EXACT_ALARM_PERMISSION("needsExactAlarmPermission"),
    MUTED_CHANNEL("mutedChannel"),
    BATTERY_RESTRICTED("batteryRestricted"),
    STALE_PLAN("stalePlan"),
    HORIZON_ENDING("horizonEnding"),
    NO_SOUND_ASSET("noSoundAsset"),
    INEXACT_FALLBACK("inexactFallback"),
    FORCE_STOPPED_PREVIOUSLY("forceStoppedPreviously"),
}

/** How a failing probe moves the state (§8.3, D81). */
internal enum class Severity {
    /** `false` ⇒ `NOT_READY`. */
    BLOCKING,

    /** `false` ⇒ `LIMITED`. */
    DEGRADING,

    /** `false` adds its reason but never changes the state. */
    ADVISORY,

    /** Shown as evidence only. */
    INFORMATIONAL,
}

/** The Android probes of DESIGN.md §8.1 with their effect; [label] is `ProbeResult.name`. */
internal enum class ProbeName(
    val label: String,
    val severity: Severity,
    val reason: HealthReason?,
) {
    NOTIFICATIONS_ENABLED("areNotificationsEnabled", Severity.BLOCKING, HealthReason.NEEDS_NOTIFICATION_PERMISSION),
    PLAN_PRESENT("planPresent", Severity.BLOCKING, HealthReason.STALE_PLAN),
    SOUND_ASSET("soundAssetPresence", Severity.BLOCKING, HealthReason.NO_SOUND_ASSET),
    EXACT_ALARMS("canScheduleExactAlarms", Severity.DEGRADING, HealthReason.INEXACT_FALLBACK),
    CHANNEL_IMPORTANCE("channelImportance", Severity.DEGRADING, HealthReason.MUTED_CHANNEL),
    BACKGROUND_UNRESTRICTED("backgroundUnrestricted", Severity.DEGRADING, HealthReason.BATTERY_RESTRICTED),
    PLAN_HORIZON("planHorizon", Severity.DEGRADING, HealthReason.HORIZON_ENDING),
    NO_PREVIOUS_FORCE_STOP("previousForceStop", Severity.ADVISORY, HealthReason.FORCE_STOPPED_PREVIOUSLY),
    IGNORING_BATTERY_OPTIMIZATIONS("isIgnoringBatteryOptimizations", Severity.INFORMATIONAL, null),
    DND_ALLOWS_ALARMS("dndAlarmPolicy", Severity.INFORMATIONAL, null),
}

/** One probe; [positive] is null when the platform cannot tell (§7.8). [detail] never holds an identifier. */
internal data class ProbeResult(
    val name: ProbeName,
    val positive: Boolean?,
    val detail: String? = null,
)

/** `AthanHealthReport` of §7.8. */
internal data class HealthReport(
    val state: HealthState,
    val reasons: List<HealthReason>,
    val probes: List<ProbeResult>,
    val evaluatedAtUtcMs: Long,
    val platformPath: String,
)
