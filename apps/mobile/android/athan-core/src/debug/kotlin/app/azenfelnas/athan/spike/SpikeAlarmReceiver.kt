package app.azenfelnas.athan.spike

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import app.azenfelnas.athan.codes.EventCode
import app.azenfelnas.athan.plan.EventAttrs
import app.azenfelnas.athan.plan.EventLevel

/**
 * The alarm fired. Exact path: start the `mediaPlayback` foreground service from the exact-alarm exemption, the
 * start path S19 validates (DESIGN.md §8.1, REQ-ALM-023). Inexact path: post the alarm-stream notification.
 */
public class SpikeAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(
        context: Context,
        intent: Intent,
    ) {
        val entryId = intent.getStringExtra(SpikeLabels.EXTRA_ENTRY_ID) ?: return
        val triggerUtcMs = intent.getLongExtra(SpikeLabels.EXTRA_TRIGGER_MS, 0L)
        val log = SpikeEventLog(context)
        log.append(EventCode.ALARM_PRESENTED, receipt(entryId, SpikeLabels.RECEIVER, triggerUtcMs))
        if (intent.getStringExtra(SpikeLabels.EXTRA_PATH) == SpikeLabels.ANDROID_INEXACT) {
            SpikeNotifications(context).postFallback(entryId)
            log.append(EventCode.ALARM_PRESENTED, receipt(entryId, SpikeLabels.NOTIFICATION_POSTED, triggerUtcMs))
            return
        }
        val service =
            Intent(context, SpikePlaybackService::class.java)
                .putExtra(SpikeLabels.EXTRA_ENTRY_ID, entryId)
                .putExtra(SpikeLabels.EXTRA_TRIGGER_MS, triggerUtcMs)
        try {
            context.startForegroundService(service)
        } catch (e: IllegalStateException) {
            // ForegroundServiceStartNotAllowedException (API 31+) extends IllegalStateException; matched by name so
            // the class is never resolved on API 26–30.
            val denied = e.javaClass.simpleName == "ForegroundServiceStartNotAllowedException"
            log.append(
                EventCode.ALARM_PRESENTED,
                receipt(entryId, if (denied) SpikeLabels.FGS_DENIED else e.javaClass.simpleName, triggerUtcMs),
                EventLevel.ERROR,
            )
            SpikeNotifications(context).postFallback(entryId)
        }
    }

    internal companion object {
        fun receipt(
            entryId: String,
            stage: String,
            triggerUtcMs: Long,
        ): EventAttrs =
            EventAttrs(
                entryId = entryId,
                reason = stage,
                durationMs = (System.currentTimeMillis() - triggerUtcMs).coerceAtLeast(0L),
            )
    }
}
