package app.dailymuslim.athan.receive

import app.dailymuslim.athan.notify.ChannelKind
import app.dailymuslim.athan.plan.EntryKind
import app.dailymuslim.athan.plan.PlanLocale
import app.dailymuslim.athan.schedule.AlarmTrigger
import app.dailymuslim.athan.schedule.DeliveryMode
import app.dailymuslim.athan.schedule.builtPlan
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test

internal class ChoosePresentationTest {
    private val choose = ChoosePresentation()
    private val athan = builtPlan.entries.first { it.kind == EntryKind.ATHAN }
    private val reminder = builtPlan.entries.first { it.kind == EntryKind.PRE_REMINDER }

    @Test
    fun `REQ-ALM-023 an exact ATHAN entry plays the full Athan through the playback service`() {
        val presentation =
            choose.of(
                AlarmTrigger.PlanEntry(athan.id),
                DeliveryMode.ALARM_CLOCK,
                builtPlan,
                dndActive = false,
            )

        val playback = presentation as Presentation.Playback
        assertEquals(athan.soundId, playback.soundId)
        assertEquals(AlertText(athan.title.ar, athan.body.ar), playback.text)
        assertEquals(athan.id, playback.snoozeEntryId)
        assertEquals(ChannelKind.ATHAN, playback.fallback.kind)
    }

    @Test
    fun `REQ-ALM-027 an inexact ATHAN alarm posts the alarm-stream notification instead`() {
        val presentation =
            choose.of(
                AlarmTrigger.PlanEntry(athan.id),
                DeliveryMode.INEXACT_IDLE,
                builtPlan,
                dndActive = false,
            )

        assertEquals(ChannelKind.ATHAN, (presentation as Presentation.Notify).kind)
    }

    @Test
    fun `REQ-ALM-023 full Athan off or respected Do Not Disturb post a notification`() {
        val noFull = builtPlan.copy(policy = builtPlan.policy.copy(fullAthanAndroid = false))
        val respectDnd = builtPlan.copy(policy = builtPlan.policy.copy(respectDnd = true))
        val trigger = AlarmTrigger.PlanEntry(athan.id)

        assertTrue(choose.of(trigger, DeliveryMode.ALARM_CLOCK, noFull, dndActive = false) is Presentation.Notify)
        assertTrue(choose.of(trigger, DeliveryMode.ALARM_CLOCK, respectDnd, dndActive = true) is Presentation.Notify)
        assertTrue(choose.of(trigger, DeliveryMode.ALARM_CLOCK, respectDnd, dndActive = false) is Presentation.Playback)
    }

    @Test
    fun `REQ-ALM-042 a snoozed Athan offers no second snooze`() {
        val presentation =
            choose.of(
                AlarmTrigger.Snooze(athan.id),
                DeliveryMode.ALARM_CLOCK,
                builtPlan,
                dndActive = false,
            )

        assertNull((presentation as Presentation.Playback).snoozeEntryId)
    }

    @Test
    fun `REQ-ALM-001 non-Athan entries notify on their own channel kind with pre-rendered text`() {
        val en = builtPlan.copy(policy = builtPlan.policy.copy(locale = PlanLocale.EN))

        val presentation =
            choose.of(
                AlarmTrigger.PlanEntry(reminder.id),
                DeliveryMode.EXACT_IDLE,
                en,
                dndActive = false,
            )

        assertEquals(
            Presentation.Notify(
                reminder.id,
                ChannelKind.PRE_REMINDER,
                reminder.soundId,
                AlertText(reminder.title.en, reminder.body.en),
            ),
            presentation,
        )
    }

    @Test
    fun `REQ-ALM-002 an entry missing from the persisted plan is dropped`() {
        val gone = builtPlan.copy(entries = builtPlan.entries.filter { it.id != athan.id })

        assertEquals(
            Presentation.Drop(athan.id),
            choose.of(AlarmTrigger.PlanEntry(athan.id), DeliveryMode.ALARM_CLOCK, gone, dndActive = false),
        )
        assertEquals(
            Presentation.Drop(athan.id),
            choose.of(AlarmTrigger.PlanEntry(athan.id), DeliveryMode.ALARM_CLOCK, null, false),
        )
    }

    @Test
    fun `REQ-ALM-040 the Athan Test uses the real playback path`() {
        val test = AlarmTrigger.Test("t1", "athan_makkah_v1")

        assertTrue(choose.of(test, DeliveryMode.ALARM_CLOCK, null, dndActive = false) is Presentation.Playback)
        assertTrue(choose.of(test, DeliveryMode.INEXACT_IDLE, null, dndActive = false) is Presentation.Notify)
    }
}
