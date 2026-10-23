package app.dailymuslim.athan.spike

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import app.dailymuslim.athan.codes.EventCode

/**
 * Re-arms future spike entries after a reboot, before the first unlock when `LOCKED_BOOT_COMPLETED` arrives
 * (REQ-ALM-022). The schedule is read back from the device-protected event log.
 */
public class SpikeBootReceiver : BroadcastReceiver() {
    override fun onReceive(
        context: Context,
        intent: Intent,
    ) {
        if (intent.action != Intent.ACTION_LOCKED_BOOT_COMPLETED &&
            intent.action != Intent.ACTION_BOOT_COMPLETED
        ) {
            return
        }
        val now = System.currentTimeMillis()
        val events = SpikeEventLog(context).readAll()
        val delivered = events.filter { it.code == EventCode.ALARM_PRESENTED }.mapNotNull { it.attrs.entryId }.toSet()
        val scheduler = SpikeScheduler(context)
        events
            .filter { it.code == EventCode.ALARM_SCHEDULED }
            .forEach { scheduled ->
                val entryId = scheduled.attrs.entryId ?: return@forEach
                val trigger = scheduled.utcMs + (scheduled.attrs.durationMs ?: return@forEach)
                if (trigger > now && entryId !in delivered) scheduler.schedule(entryId, trigger, scenario = null)
            }
    }
}
