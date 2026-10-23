package app.dailymuslim.athan.receive

import android.app.AlarmManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import app.dailymuslim.athan.bridge.AthanGraph
import app.dailymuslim.athan.schedule.ReconcileCause
import kotlin.concurrent.thread

/**
 * Re-arms from the persisted plan on a system event (REQ-ALM-002) without Dart; the `PLAN_APPLIED` line it writes
 * names the event, which Dart drains as a `SystemEvent` (REQ-ALM-041). Work runs off the main thread under
 * `goAsync` (§17.3). Every subclass is `exported=false` (REQ-ALM-021); the system still delivers these
 * protected broadcasts to it.
 */
public abstract class ReconcilingReceiver : BroadcastReceiver() {
    /** The cause of [action], or null for an action this receiver does not handle. */
    internal abstract fun causeOf(action: String?): ReconcileCause?

    final override fun onReceive(
        context: Context,
        intent: Intent,
    ) {
        val cause = causeOf(intent.action) ?: return
        val graph = AthanGraph(context)
        val pending = goAsync()
        thread(name = "athan-reconcile") {
            try {
                graph.rearm(cause)
            } finally {
                pending.finish()
            }
        }
    }
}

/** `LOCKED_BOOT_COMPLETED` (before the first unlock, REQ-ALM-022) and `BOOT_COMPLETED`; `directBootAware`. */
public class BootReceiver : ReconcilingReceiver() {
    override fun causeOf(action: String?): ReconcileCause? =
        when (action) {
            Intent.ACTION_LOCKED_BOOT_COMPLETED -> ReconcileCause.LOCKED_BOOT
            Intent.ACTION_BOOT_COMPLETED -> ReconcileCause.BOOT
            else -> null
        }
}

/** `TIME_SET` and `TIMEZONE_CHANGED`: instants are absolute, but the window and receipts follow (REQ-TIME-001). */
public class TimeChangeReceiver : ReconcilingReceiver() {
    override fun causeOf(action: String?): ReconcileCause? =
        when (action) {
            Intent.ACTION_TIME_CHANGED -> ReconcileCause.TIME_CHANGED
            Intent.ACTION_TIMEZONE_CHANGED -> ReconcileCause.TIMEZONE_CHANGED
            else -> null
        }
}

/** `MY_PACKAGE_REPLACED`: an update cancels nothing on its own, but alarms are re-armed defensively. */
public class PackageReplacedReceiver : ReconcilingReceiver() {
    override fun causeOf(action: String?): ReconcileCause? =
        if (action == Intent.ACTION_MY_PACKAGE_REPLACED) ReconcileCause.PACKAGE_REPLACED else null
}

/** `SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED` (API 31+): exact alarms granted again ⇒ re-arm exact. */
public class ExactAlarmPermissionReceiver : ReconcilingReceiver() {
    override fun causeOf(action: String?): ReconcileCause? =
        if (action == AlarmManager.ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED) {
            ReconcileCause.PERMISSION_CHANGED
        } else {
            null
        }
}
