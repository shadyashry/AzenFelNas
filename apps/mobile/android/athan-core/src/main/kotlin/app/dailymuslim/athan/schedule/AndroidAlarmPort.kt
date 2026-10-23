package app.dailymuslim.athan.schedule

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.os.Build
import app.dailymuslim.athan.receive.PENDING_FLAGS
import app.dailymuslim.athan.receive.TriggerIntents

/**
 * [AlarmPort] and [ExactAlarmGate] over `AlarmManager` (ADR-012): `setAlarmClock` (REQ-ALM-020),
 * `setExactAndAllowWhileIdle`, or `setAndAllowWhileIdle` as the inexact fallback (REQ-ALM-027), all on
 * `RTC_WAKEUP` absolute instants (REQ-ALM-001).
 */
internal class AndroidAlarmPort(
    private val context: Context,
) : AlarmPort,
    ExactAlarmGate {
    private val alarms: AlarmManager = context.getSystemService(AlarmManager::class.java)

    override fun canScheduleExact(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarms.canScheduleExactAlarms()

    override fun arm(alarm: ArmedAlarm): ArmResult {
        val fire = TriggerIntents.fire(context, alarm.trigger, alarm.mode)
        return try {
            when (alarm.mode) {
                DeliveryMode.ALARM_CLOCK -> {
                    alarms.setAlarmClock(
                        AlarmManager.AlarmClockInfo(alarm.fireAtUtcMs, showIntent()),
                        fire,
                    )
                }

                DeliveryMode.EXACT_IDLE -> {
                    alarms.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        alarm.fireAtUtcMs,
                        fire,
                    )
                }

                DeliveryMode.INEXACT_IDLE -> {
                    alarms.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        alarm.fireAtUtcMs,
                        fire,
                    )
                }
            }
            ArmResult.Armed
        } catch (e: SecurityException) {
            // Exact alarms revoked between canScheduleExact() and the call; the next reconcile falls back.
            ArmResult.Refused(e.javaClass.simpleName)
        }
    }

    override fun disarm(trigger: AlarmTrigger) {
        val pending = TriggerIntents.cancel(context, trigger)
        alarms.cancel(pending)
        pending.cancel()
    }

    /** Tapping the system's next-alarm indicator opens the app. */
    private fun showIntent(): PendingIntent? =
        context.packageManager.getLaunchIntentForPackage(context.packageName)?.let {
            PendingIntent.getActivity(context, SHOW_REQUEST_CODE, it, PENDING_FLAGS)
        }

    private companion object {
        const val SHOW_REQUEST_CODE: Int = 0
    }
}
