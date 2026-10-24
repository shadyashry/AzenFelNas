@testable import AthanKit
import Foundation
import Testing

/// A fixed instant.
struct FixedClock: UtcClock {
    let now: Int64
    func nowUtcMs() -> Int64 {
        now
    }
}

/// A fixed delivery path.
struct FixedGate: DeliveryPathGate {
    let path: DeliveryPath
    func current() async -> DeliveryPath {
        path
    }
}

/// In-memory `NotificationPort` with the documented contract (replace by id, ignore unknown removals).
actor FakeNotifications: NotificationPort {
    private(set) var pending: [String: NotificationRequest] = [:]
    private(set) var intervals: [String: TimeInterval] = [:]
    private(set) var adds = 0
    var refuse: Set<String> = []

    func pendingIds() async -> [String] {
        pending.keys.sorted()
    }

    func add(_ request: NotificationRequest, nowUtcMs: Int64) async -> ArmResult {
        adds += 1
        guard !refuse.contains(request.id),
              let seconds = TriggerInterval.seconds(fireAtUtcMs: request.fireAtUtcMs, nowUtcMs: nowUtcMs)
        else { return .refused(reason: "refused") }
        pending[request.id] = request
        intervals[request.id] = seconds
        return .armed
    }

    func remove(ids: [String]) async {
        for id in ids {
            pending[id] = nil
            intervals[id] = nil
        }
    }

    func refuse(_ ids: Set<String>) {
        refuse = ids
    }

    func seed(_ request: NotificationRequest) {
        pending[request.id] = request
    }
}

/// In-memory `AlarmKitPort` with the documented contract (an id already scheduled is refused).
actor FakeAlarmKit: AlarmKitPort {
    private(set) var alarms: [UUID: AlarmRequest] = [:]
    private(set) var schedules = 0

    func scheduledIds() async -> Set<UUID> {
        Set(alarms.keys)
    }

    func schedule(_ alarm: AlarmRequest) async -> ArmResult {
        schedules += 1
        guard alarms[alarm.id] == nil else { return .refused(reason: "duplicate") }
        alarms[alarm.id] = alarm
        return .armed
    }

    func cancel(id: UUID) async {
        alarms[id] = nil
    }
}

/// Sounds installed by id.
struct FakeSounds: SoundCatalog {
    let installed: Set<String>
    func sound(for soundId: String) -> AlertSound {
        installed.contains(soundId) ? .clip(fileName: AthanClipCatalog.fileName(of: soundId)) : .systemDefault
    }

    func isInstalled(_ soundId: String) -> Bool {
        installed.contains(soundId)
    }
}

/// Fixed platform probes.
struct FakeProbes: PlatformProbes {
    let results: [ProbeResult]
    func probes(on _: DeliveryPath) async -> [ProbeResult] {
        results
    }
}

func temporaryDirectory() -> URL {
    FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
}

/// The Linux-built iOS plan fixture (64 entries, Cairo).
func iosPlanData(generation: Int = 1) throws -> Data {
    let text = try String(contentsOf: fixtureURL("schedule_plan", "valid", "built_ios.json"), encoding: .utf8)
    return Data(text.replacingOccurrences(of: "\"generation\": 1,", with: "\"generation\": \(generation),").utf8)
}

/// The fixture as the JSON string the bridge receives.
func iosPlanJSON(generation: Int = 1) throws -> String {
    try #require(String(bytes: iosPlanData(generation: generation), encoding: .utf8))
}

/// `plan` as the JSON string the bridge receives.
func planJSON(_ plan: SchedulePlan) throws -> String {
    try #require(String(bytes: JSONEncoder().encode(plan), encoding: .utf8))
}

func iosPlan() throws -> SchedulePlan {
    try JSONDecoder().decode(SchedulePlan.self, from: iosPlanData())
}

let testCopy = NativeCopy(testTitle: "Test", testBody: "Heard?", stop: "Stop")

/// A graph over fakes in a fresh directory.
struct Rig {
    let directory = temporaryDirectory()
    let notifications = FakeNotifications()
    let alarms = FakeAlarmKit()
    let widgets = CountingReloader()
    let graph: AthanGraph

    init(path: DeliveryPath, now: Int64, installed: Set<String> = ["athan_makkah_v1"], probes: [ProbeResult] = []) {
        graph = AthanGraph(
            directory: directory,
            alarms: alarms,
            notifications: notifications,
            gate: FixedGate(path: path),
            platformProbes: FakeProbes(results: probes),
            sounds: FakeSounds(installed: installed),
            copy: testCopy,
            clock: FixedClock(now: now),
            widgets: widgets,
        )
    }

    var bridge: AthanBridge {
        AthanBridge(graph: graph)
    }
}

/// Counts WidgetKit reload requests.
final class CountingReloader: WidgetReloader, @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0

    /// Reloads requested so far.
    var reloads: Int {
        lock.withLock { count }
    }

    func reloadAll() {
        lock.withLock { count += 1 }
    }
}
