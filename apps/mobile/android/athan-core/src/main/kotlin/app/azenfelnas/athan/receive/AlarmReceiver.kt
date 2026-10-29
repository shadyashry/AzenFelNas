package app.azenfelnas.athan.receive

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import app.azenfelnas.athan.bridge.AthanGraph
import app.azenfelnas.athan.plan.EventLevel
import app.azenfelnas.athan.playback.AthanForegroundService
import app.azenfelnas.athan.schedule.AlarmTrigger
import app.azenfelnas.athan.schedule.DeliveryMode
import app.azenfelnas.athan.schedule.ReconcileCause
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
        val dndActive = dndActive(context)
        // Plan read, presentation and re-arming (file I/O plus up to ArmingWindow.DEFAULT_CAPACITY binder calls)
        // run off the main thread (§17.3).
        val pending = goAsync()
        thread(name = "athan-fire") {
            try {
                val graph = AthanGraph(context)
                present(context, graph, trigger, mode, dndActive)
                graph.rearm(ReconcileCause.ALARM_FIRED)
            } finally {
                pending.finish()
            }
        }
    }

    private fun present(
        context: Context,
        graph: AthanGraph,
        trigger: AlarmTrigger,
        mode: DeliveryMode,
        dndActive: Boolean,
    ) {
        graph.receipts.presented(trigger.alarmId, ReceiptStage.RECEIVER)
        when (val presentation = graph.presentation.of(trigger, mode, graph.planStore.read(), dndActive)) {
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
    }

    private fun dndActive(context: Context): Boolean =
        context.getSystemService(NotificationManager::class.java).currentInterruptionFilter >
            NotificationManager.INTERRUPTION_FILTER_ALL
}
