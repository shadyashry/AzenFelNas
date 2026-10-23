import Foundation

/// The composition root of AthanKit (DESIGN.md §17.1 D): the only place that picks adapters. The live graph is
/// `AthanGraph.live()` on iOS; tests build one from fakes with `init`.
struct AthanGraph: Sendable {
    let planStore: PlanStore
    let events: EventsStore
    let clock: any UtcClock
    let gate: any DeliveryPathGate
    let platformProbes: any PlatformProbes
    let planProbes: PlanProbes
    let evaluateHealth: EvaluateHealth
    let rearm: RearmFromPlan
    let applyPlan: ApplyPlan
    let cancelBelow: CancelGenerationsBelow
    let startTest: StartAthanTest

    init(
        directory: URL,
        alarms: any AlarmKitPort,
        notifications: any NotificationPort,
        gate: any DeliveryPathGate,
        platformProbes: any PlatformProbes,
        sounds: any SoundCatalog,
        copy: NativeCopy,
        clock: any UtcClock,
        newId: @escaping @Sendable () -> UUID = { UUID() }
    ) {
        let store = PlanStore(directory: directory)
        let events = EventsStore(directory: directory, clock: clock)
        let rearm = RearmFromPlan(
            readPlan: { store.read() },
            window: DeliveryWindow(sounds: sounds),
            alarms: alarms,
            notifications: notifications,
            gate: gate,
            clock: clock,
            events: events
        )
        planStore = store
        self.events = events
        self.clock = clock
        self.gate = gate
        self.platformProbes = platformProbes
        planProbes = PlanProbes(sounds: sounds)
        evaluateHealth = EvaluateHealth()
        self.rearm = rearm
        applyPlan = ApplyPlan(store: store, rearm: rearm)
        cancelBelow = CancelGenerationsBelow(store: store, alarms: alarms, notifications: notifications)
        startTest = StartAthanTest(
            alarms: alarms, notifications: notifications, gate: gate, sounds: sounds, copy: copy, clock: clock,
            events: events, newId: newId
        )
    }
}
