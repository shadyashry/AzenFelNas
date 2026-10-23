package app.dailymuslim.athan.receive

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import app.dailymuslim.athan.bridge.AthanGraph
import app.dailymuslim.athan.plan.EventLevel
import app.dailymuslim.athan.playback.AthanForegroundService
import app.dailymuslim.athan.schedule.ReconcileCause
import kotlin.concurrent.thread

/**
 * An alarm fired (DESIGN.md §8.1). Reads the entry from the persisted plan, presents it (full Athan through the
 * playback service, else a notification), writes the receipt and rolls the arming window forward. `exported=false`
 * (REQ-ALM-021) and `directBootAware`, so it works before the first unlock with no Dart isolate (§0.2 rule 5).
 */
public class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(
        context: Context,
        intent: Intent,
    ) {
        val trigger = TriggerIntents.triggerOf(intent) ?: return
        val mode = TriggerIntents.modeOf(intent)
        val graph = AthanGraph(context)
        graph.receipts.presented(trigger.alarmId, ReceiptStage.RECEIVER)
        val plan = graph.planStore.read()
        when (val presentation = graph.presentation.of(trigger, mode, plan, dndActive(context))) {
            is Presentation.Playback -> {
                AthanForegroundService.start(context, graph, presentation)
            }

            is Presentation.Notify -> {
                graph.notifications.post(presentation)
                graph.receipts.presented(trigger.alarmId, ReceiptStage.NOTIFICATION_POSTED)
            }

            is Presentation.Drop -> {
                graph.receipts.presented(trigger.alarmId, ReceiptStage.DROPPED, level = EventLevel.WARN)
            }
        }
        // Re-arming is file I/O plus up to ArmingWindow.DEFAULT_CAPACITY binder calls: off the main thread (§17.3).
        val pending = goAsync()
        thread(name = "athan-rearm") {
            try {
                graph.rearm(ReconcileCause.ALARM_FIRED)
            } finally {
                pending.finish()
            }
        }
    }

    private fun dndActive(context: Context): Boolean =
        context.getSystemService(NotificationManager::class.java).currentInterruptionFilter >
            NotificationManager.INTERRUPTION_FILTER_ALL
}
