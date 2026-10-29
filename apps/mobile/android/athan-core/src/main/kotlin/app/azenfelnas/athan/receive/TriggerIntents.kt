package app.azenfelnas.athan.receive

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import app.azenfelnas.athan.schedule.AlarmTrigger
import app.azenfelnas.athan.schedule.DeliveryMode
import app.azenfelnas.athan.schedule.RequestCode

/** Every `PendingIntent` of this layer is immutable and replaces its predecessor (REQ-ALM-021). */
internal const val PENDING_FLAGS: Int = PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT

/**
 * The explicit intent of an alarm for [AlarmReceiver]. Extras carry only ids and the delivery mode; the text and
 * sound are read from the persisted plan when it fires (§0.2 rule 5), except for an Athan Test.
 */
internal object TriggerIntents {
    private const val EXTRA_TYPE = "app.azenfelnas.athan.TYPE"
    private const val EXTRA_ID = "app.azenfelnas.athan.ID"
    private const val EXTRA_SOUND = "app.azenfelnas.athan.SOUND"
    private const val EXTRA_MODE = "app.azenfelnas.athan.MODE"
    private const val TYPE_ENTRY = "entry"
    private const val TYPE_SNOOZE = "snooze"
    private const val TYPE_TEST = "test"

    /** The broadcast `PendingIntent` that fires [trigger] delivered by [mode]. */
    fun fire(
        context: Context,
        trigger: AlarmTrigger,
        mode: DeliveryMode,
    ): PendingIntent =
        PendingIntent.getBroadcast(
            context,
            RequestCode.of(trigger.alarmId),
            intent(context, trigger).putExtra(EXTRA_MODE, mode.name),
            PENDING_FLAGS,
        )

    /** The same `PendingIntent` identity as [fire], for cancelling (extras do not take part in identity). */
    fun cancel(
        context: Context,
        trigger: AlarmTrigger,
    ): PendingIntent =
        PendingIntent.getBroadcast(context, RequestCode.of(trigger.alarmId), intent(context, trigger), PENDING_FLAGS)

    private fun intent(
        context: Context,
        trigger: AlarmTrigger,
    ): Intent {
        val base = Intent(context, AlarmReceiver::class.java)
        return when (trigger) {
            is AlarmTrigger.PlanEntry -> {
                base.putExtra(EXTRA_TYPE, TYPE_ENTRY).putExtra(EXTRA_ID, trigger.entryId)
            }

            is AlarmTrigger.Snooze -> {
                base.putExtra(EXTRA_TYPE, TYPE_SNOOZE).putExtra(EXTRA_ID, trigger.entryId)
            }

            is AlarmTrigger.Test -> {
                base
                    .putExtra(EXTRA_TYPE, TYPE_TEST)
                    .putExtra(EXTRA_ID, trigger.testId)
                    .putExtra(EXTRA_SOUND, trigger.soundId)
            }
        }
    }

    /** The trigger of a fired intent, or null for an intent this layer did not create. */
    fun triggerOf(intent: Intent): AlarmTrigger? {
        val id = intent.getStringExtra(EXTRA_ID) ?: return null
        return when (intent.getStringExtra(EXTRA_TYPE)) {
            TYPE_ENTRY -> AlarmTrigger.PlanEntry(id)
            TYPE_SNOOZE -> AlarmTrigger.Snooze(id)
            TYPE_TEST -> intent.getStringExtra(EXTRA_SOUND)?.let { AlarmTrigger.Test(id, it) }
            else -> null
        }
    }

    /** The delivery mode of a fired intent; an unknown value is treated as inexact (no FGS start). */
    fun modeOf(intent: Intent): DeliveryMode =
        DeliveryMode.entries.firstOrNull { it.name == intent.getStringExtra(EXTRA_MODE) } ?: DeliveryMode.INEXACT_IDLE
}
