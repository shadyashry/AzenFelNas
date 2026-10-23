package app.dailymuslim.athan.bridge

import android.content.Context
import app.dailymuslim.athan.health.AndroidProbes
import app.dailymuslim.athan.health.EvaluateHealth
import app.dailymuslim.athan.health.PlanProbes
import app.dailymuslim.athan.notify.AlertNotifications
import app.dailymuslim.athan.notify.ChannelRegistry
import app.dailymuslim.athan.plan.EventsStore
import app.dailymuslim.athan.plan.PlanDirectory
import app.dailymuslim.athan.plan.PlanStore
import app.dailymuslim.athan.playback.AthanAudio
import app.dailymuslim.athan.receive.ChoosePresentation
import app.dailymuslim.athan.receive.Receipts
import app.dailymuslim.athan.schedule.AndroidAlarmPort
import app.dailymuslim.athan.schedule.ApplyPlan
import app.dailymuslim.athan.schedule.ArmingWindow
import app.dailymuslim.athan.schedule.RearmFromPlan
import app.dailymuslim.athan.schedule.UtcClock
import app.dailymuslim.athan.selftest.StartAthanTest
import java.io.File

/**
 * Composition root of `athan-core` (DESIGN.md §17.1): receivers, the playback service and the bridge are created
 * by the OS without arguments, so each builds this graph from its [Context]. All state is on disk in
 * device-protected storage, so a graph built before the first unlock sees the same plan (REQ-ALM-022).
 */
internal class AthanGraph(
    context: Context,
) {
    private val appContext: Context = context.applicationContext ?: context
    private val protectedFiles: File = appContext.createDeviceProtectedStorageContext().filesDir

    val clock: UtcClock = UtcClock { System.currentTimeMillis() }
    val planStore: PlanStore = PlanStore(PlanDirectory.of(appContext))
    val events: EventsStore = EventsStore(PlanDirectory.of(appContext)) { clock.nowUtcMs() }
    val receipts: Receipts = Receipts(events)
    val alarms: AndroidAlarmPort = AndroidAlarmPort(appContext)
    val audio: AthanAudio = AthanAudio(File(protectedFiles, "athan"))
    val channels: ChannelRegistry = ChannelRegistry(appContext)
    val notifications: AlertNotifications = AlertNotifications(appContext, channels)
    val presentation: ChoosePresentation = ChoosePresentation()

    val rearm: RearmFromPlan = RearmFromPlan(planStore::read, ArmingWindow(), alarms, alarms, clock, events)
    val applyPlan: ApplyPlan = ApplyPlan(planStore, rearm, alarms)
    val startTest: StartAthanTest = StartAthanTest(alarms, alarms, clock, events)
    val probes: AndroidProbes = AndroidProbes(appContext, alarms, channels, PlanProbes(audio::isPresent))
    val evaluateHealth: EvaluateHealth = EvaluateHealth()
}
