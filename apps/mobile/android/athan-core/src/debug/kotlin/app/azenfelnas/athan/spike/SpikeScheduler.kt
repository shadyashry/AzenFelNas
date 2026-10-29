package app.azenfelnas.athan.spike

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import app.azenfelnas.athan.codes.EventCode
import app.azenfelnas.athan.plan.EventAttrs

/**
 * Schedules one spike entry: `setAlarmClock` when exact alarms are allowed (ADR-012, REQ-ALM-020), otherwise
 * `setAndAllowWhileIdle` (REQ-ALM-027). Request codes derive from the entry id (REQ-ALM-021).
 */
internal class SpikeScheduler(
    private val context: Context,
) {
    private val alarms: AlarmManager = context.getSystemService(AlarmManager::class.java)

    fun canScheduleExact(): Boolean = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarms.canScheduleExactAlarms()

    /** Schedules [entryId] at [triggerUtcMs]; logs `ALARM_SCHEDULED` when [scenario] is given (not on reboot). */
    fun schedule(
        entryId: String,
        triggerUtcMs: Long,
        scenario: String?,
    ) {
        val exact = canScheduleExact()
        val path = if (exact) SpikeLabels.ANDROID_EXACT else SpikeLabels.ANDROID_INEXACT
        val fire =
            PendingIntent.getBroadcast(
                context,
                requestCode(entryId),
                fireIntent(entryId, triggerUtcMs, path),
                FLAGS,
            )
        if (exact) {
            val show =
                context.packageManager.getLaunchIntentForPackage(context.packageName)?.let {
                    PendingIntent.getActivity(context, requestCode(entryId), it, FLAGS)
                }
            alarms.setAlarmClock(AlarmManager.AlarmClockInfo(triggerUtcMs, show), fire)
        } else {
            alarms.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerUtcMs, fire)
        }
        if (scenario != null) {
            SpikeEventLog(context).append(
                EventCode.ALARM_SCHEDULED,
                EventAttrs(
                    entryId = entryId,
                    state = scenario,
                    reason = path,
                    durationMs = triggerUtcMs - System.currentTimeMillis(),
                ),
            )
        }
    }

    private fun fireIntent(
        entryId: String,
        triggerUtcMs: Long,
        path: String,
    ): Intent =
        Intent(context, SpikeAlarmReceiver::class.java)
            .putExtra(SpikeLabels.EXTRA_ENTRY_ID, entryId)
            .putExtra(SpikeLabels.EXTRA_TRIGGER_MS, triggerUtcMs)
            .putExtra(SpikeLabels.EXTRA_PATH, path)

    companion object {
        private const val ID_TAIL_HEX: Int = 8
        private const val HEX: Int = 16

        const val FLAGS: Int = PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT

        /** The low 31 bits of the entry id (16 hex digits). */
        fun requestCode(entryId: String): Int =
            (entryId.takeLast(ID_TAIL_HEX).toLong(HEX) and Int.MAX_VALUE.toLong()).toInt()
    }
}
