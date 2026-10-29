package app.azenfelnas.athan.bridge

import android.content.Context
import app.azenfelnas.athan.health.AndroidProbes
import app.azenfelnas.athan.health.EvaluateHealth
import app.azenfelnas.athan.health.PlanProbes
import app.azenfelnas.athan.notify.AlertNotifications
import app.azenfelnas.athan.notify.ChannelRegistry
import app.azenfelnas.athan.plan.EventsStore
import app.azenfelnas.athan.plan.PlanDirectory
import app.azenfelnas.athan.plan.PlanStore
import app.azenfelnas.athan.plan.SnapshotStore
import app.azenfelnas.athan.playback.AthanAudio
import app.azenfelnas.athan.receive.ChoosePresentation
import app.azenfelnas.athan.receive.Receipts
import app.azenfelnas.athan.schedule.AndroidAlarmPort
import app.azenfelnas.athan.schedule.ApplyPlan
import app.azenfelnas.athan.schedule.ArmingWindow
import app.azenfelnas.athan.schedule.RearmFromPlan
import app.azenfelnas.athan.schedule.UtcClock
import app.azenfelnas.athan.selftest.StartAthanTest
import app.azenfelnas.athan.widget.AppWidgetRefresh
import app.azenfelnas.athan.widget.RefreshWidgets
import app.azenfelnas.athan.widget.SelectWidgetContent
import app.azenfelnas.athan.widget.WidgetRedrawAlarm
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

    val snapshotStore: SnapshotStore = SnapshotStore(PlanDirectory.of(appContext))
    val selectWidgetContent: SelectWidgetContent = SelectWidgetContent()
    val refreshWidgets: RefreshWidgets = AppWidgetRefresh(appContext)
    val widgetRedraw: WidgetRedrawAlarm = WidgetRedrawAlarm(appContext)
}
