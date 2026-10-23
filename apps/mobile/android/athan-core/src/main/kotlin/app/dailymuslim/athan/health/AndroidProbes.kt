package app.dailymuslim.athan.health

import android.Manifest
import android.app.ActivityManager
import android.app.ApplicationExitInfo
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.PowerManager
import app.dailymuslim.athan.notify.ChannelKind
import app.dailymuslim.athan.notify.ChannelRegistry
import app.dailymuslim.athan.notify.ChannelSpec
import app.dailymuslim.athan.plan.EntryKind
import app.dailymuslim.athan.plan.SchedulePlan
import app.dailymuslim.athan.schedule.ExactAlarmGate

/**
 * The Android probes of DESIGN.md §8.1. Each answers from a platform API; a probe the OS version cannot answer is
 * `positive = null` (Unknown beats invented, §0.2 rule 10). Details carry no identifier (REQ-PRIV-001).
 */
internal class AndroidProbes(
    private val context: Context,
    private val exactGate: ExactAlarmGate,
    private val channels: ChannelRegistry,
    private val planProbes: PlanProbes,
) {
    private val notifications: NotificationManager = context.getSystemService(NotificationManager::class.java)
    private val activities: ActivityManager = context.getSystemService(ActivityManager::class.java)
    private val power: PowerManager = context.getSystemService(PowerManager::class.java)

    fun all(
        plan: SchedulePlan?,
        nowUtcMs: Long,
    ): List<ProbeResult> =
        listOf(
            notificationsEnabled(),
            ProbeResult(ProbeName.EXACT_ALARMS, exactGate.canScheduleExact()),
            athanChannelImportance(plan),
            backgroundUnrestricted(),
            ProbeResult(
                ProbeName.IGNORING_BATTERY_OPTIMIZATIONS,
                power.isIgnoringBatteryOptimizations(context.packageName),
            ),
            dndAllowsAlarms(),
            noPreviousForceStop(),
        ) + planProbes.of(plan, nowUtcMs)

    /** REQ-ALM-026: `POST_NOTIFICATIONS` on API 33+, and the app-level switch everywhere. */
    private fun notificationsEnabled(): ProbeResult {
        val granted =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
                context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
        return ProbeResult(ProbeName.NOTIFICATIONS_ENABLED, granted && notifications.areNotificationsEnabled())
    }

    /** The Athan fallback channel of the plan's sound must be `IMPORTANCE_HIGH` or more once it exists. */
    private fun athanChannelImportance(plan: SchedulePlan?): ProbeResult {
        val soundId = plan?.entries?.firstOrNull { it.kind == EntryKind.ATHAN }?.soundId
        val importance = soundId?.let { channels.importanceOf(ChannelSpec(ChannelKind.ATHAN, it)) }
        return when {
            soundId == null -> ProbeResult(ProbeName.CHANNEL_IMPORTANCE, null, "no athan entry")
            importance == null -> ProbeResult(ProbeName.CHANNEL_IMPORTANCE, true, "created on first alert")
            else -> ProbeResult(ProbeName.CHANNEL_IMPORTANCE, importance >= NotificationManager.IMPORTANCE_HIGH)
        }
    }

    /** Do Not Disturb lets alarms through (alarm-stream playback is governed by the alarms category). */
    private fun dndAllowsAlarms(): ProbeResult {
        val allowed =
            when (notifications.currentInterruptionFilter) {
                NotificationManager.INTERRUPTION_FILTER_ALL, NotificationManager.INTERRUPTION_FILTER_ALARMS -> true
                NotificationManager.INTERRUPTION_FILTER_NONE -> false
                NotificationManager.INTERRUPTION_FILTER_PRIORITY -> priorityAllowsAlarms()
                else -> null
            }
        return ProbeResult(ProbeName.DND_ALLOWS_ALARMS, allowed)
    }

    /** The alarms category of the priority policy exists from API 28. */
    private fun priorityAllowsAlarms(): Boolean? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val categories = notifications.notificationPolicy.priorityCategories
            (categories and NotificationManager.Policy.PRIORITY_CATEGORY_ALARMS) != 0
        } else {
            null
        }

    /** Background restriction ("Restricted" battery use) exists from API 28; before it nothing restricts. */
    private fun backgroundUnrestricted(): ProbeResult =
        ProbeResult(
            ProbeName.BACKGROUND_UNRESTRICTED,
            Build.VERSION.SDK_INT < Build.VERSION_CODES.P || !activities.isBackgroundRestricted,
        )

    /** REQ-ALM-025: the last exit was a user force-stop, which cancels every alarm until the app opens again. */
    private fun noPreviousForceStop(): ProbeResult {
        if (Build.VERSION.SDK_INT <
            Build.VERSION_CODES.R
        ) {
            return ProbeResult(ProbeName.NO_PREVIOUS_FORCE_STOP, null, "api < 30")
        }
        val last = activities.getHistoricalProcessExitReasons(context.packageName, 0, 1).firstOrNull()
        return ProbeResult(ProbeName.NO_PREVIOUS_FORCE_STOP, last?.reason != ApplicationExitInfo.REASON_USER_REQUESTED)
    }
}
