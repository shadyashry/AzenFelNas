package app.dailymuslim.athan.receive

import app.dailymuslim.athan.notify.ChannelKind
import app.dailymuslim.athan.notify.render
import app.dailymuslim.athan.plan.EntryKind
import app.dailymuslim.athan.plan.SchedulePlan
import app.dailymuslim.athan.plan.SchedulePlanEntry
import app.dailymuslim.athan.schedule.AlarmTrigger
import app.dailymuslim.athan.schedule.DeliveryMode

/** Rendered text of one alert. */
internal data class AlertText(
    val title: String,
    val body: String,
)

/** What a fired alarm does. */
internal sealed interface Presentation {
    /** Start the `mediaPlayback` foreground service (REQ-ALM-023); on refusal fall back to [fallback]. */
    data class Playback(
        val alarmId: String,
        val soundId: String,
        val text: AlertText?,
        val snoozeEntryId: String?,
        val vibrate: Boolean,
        val fallback: Notify,
    ) : Presentation

    /** Post a high-importance notification on the channel of ([kind], [soundId]) (D79 fallback). */
    data class Notify(
        val alarmId: String,
        val kind: ChannelKind,
        val soundId: String,
        val text: AlertText?,
    ) : Presentation

    /** The entry is no longer in the persisted plan (a removed entry or an older generation): stay silent. */
    data class Drop(
        val alarmId: String,
    ) : Presentation
}

/**
 * Decides how a fired alarm presents (DESIGN.md §8.1, D81). Full Athan audio needs an ATHAN entry, the
 * `fullAthanAndroid` policy and the exact `setAlarmClock` delivery, whose background-start exemption lets the
 * playback service start; everything else is a notification. With `respectDnd` and Do Not Disturb on, the
 * notification lets the system's DND rules decide. A [Presentation.Notify] with null text uses the layer's own
 * strings (Athan Test).
 */
internal class ChoosePresentation {
    fun of(
        trigger: AlarmTrigger,
        mode: DeliveryMode,
        plan: SchedulePlan?,
        dndActive: Boolean,
    ): Presentation =
        when (trigger) {
            is AlarmTrigger.Test -> {
                val notify = Presentation.Notify(trigger.alarmId, ChannelKind.ATHAN, trigger.soundId, null)
                if (mode == DeliveryMode.ALARM_CLOCK) {
                    Presentation.Playback(trigger.alarmId, trigger.soundId, null, null, vibrate = true, notify)
                } else {
                    notify
                }
            }

            is AlarmTrigger.PlanEntry -> {
                ofEntry(trigger.alarmId, trigger.entryId, mode, plan, dndActive, snoozable = true)
            }

            is AlarmTrigger.Snooze -> {
                ofEntry(trigger.alarmId, trigger.entryId, mode, plan, dndActive, snoozable = false)
            }
        }

    @Suppress("LongParameterList") // One decision over the fired alarm's facts; a holder type would only rename them.
    private fun ofEntry(
        alarmId: String,
        entryId: String,
        mode: DeliveryMode,
        plan: SchedulePlan?,
        dndActive: Boolean,
        snoozable: Boolean,
    ): Presentation {
        val entry = plan?.entries?.firstOrNull { it.id == entryId } ?: return Presentation.Drop(alarmId)
        val text = AlertText(entry.title.render(plan.policy.locale), entry.body.render(plan.policy.locale))
        val notify = Presentation.Notify(alarmId, channelKindOf(entry), entry.soundId, text)
        val playback =
            entry.kind == EntryKind.ATHAN &&
                plan.policy.fullAthanAndroid &&
                mode == DeliveryMode.ALARM_CLOCK &&
                !(plan.policy.respectDnd && dndActive)
        return if (playback) {
            Presentation.Playback(
                alarmId = alarmId,
                soundId = entry.soundId,
                text = text,
                snoozeEntryId = if (snoozable && plan.policy.snoozeMinutes > 0) entryId else null,
                vibrate = plan.policy.vibrate,
                fallback = notify,
            )
        } else {
            notify
        }
    }

    private fun channelKindOf(entry: SchedulePlanEntry): ChannelKind =
        when (entry.kind) {
            EntryKind.ATHAN -> ChannelKind.ATHAN
            EntryKind.PRE_REMINDER -> ChannelKind.PRE_REMINDER
            EntryKind.IMSAK -> ChannelKind.IMSAK
            EntryKind.HORIZON_WARNING -> ChannelKind.HORIZON_WARNING
        }
}
