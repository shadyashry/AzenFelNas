/// What the platform should hold for one plan at one instant.
struct DeliveryRequests: Equatable, Sendable {
    let alarms: [AlarmRequest]
    let notifications: [NotificationRequest]
}

/// The requests of a plan (ADR-013, D82): entries in the future only; on `.alarmKit` Athan entries become alarms
/// and the rest notifications, on `.notification` everything is a notification. Each kind is cut to
/// `budget − testSlots` (REQ-ALM-032): `HORIZON_WARNING` first (always kept, D80), then by priority, earliest
/// instant and id, so the farthest days of the lowest priority are dropped first. Dart's `FitSlotBudget` already
/// fits the plan; this cut guards the OS limit whatever the plan holds.
struct DeliveryWindow: Sendable {
    /// iOS keeps at most 64 pending notification requests per app (ADR-013, D79); the AlarmKit window uses the
    /// same budget until the S19 device run says otherwise.
    static let budget = 64
    /// Slots held back for the Athan Test.
    static let testSlots = 1

    private let sounds: any SoundCatalog

    init(sounds: any SoundCatalog) {
        self.sounds = sounds
    }

    func requests(for plan: SchedulePlan, nowUtcMs: Int64, path: DeliveryPath) -> DeliveryRequests {
        let future = plan.entries.filter { $0.fireAtUtcMs > nowUtcMs }
        let asAlarms = path == .alarmKit ? future.filter { $0.kind == .athan } : []
        let asNotifications = path == .alarmKit ? future.filter { $0.kind != .athan } : future
        let locale = plan.policy.locale
        return DeliveryRequests(
            alarms: Self.fit(asAlarms).compactMap { entry in
                PlanIds.alarmId(of: entry.id).map {
                    AlarmRequest(
                        id: $0,
                        entryId: entry.id,
                        fireAtUtcMs: entry.fireAtUtcMs,
                        title: entry.title.text(in: locale),
                        sound: sounds.sound(for: entry.soundId),
                    )
                }
            },
            notifications: Self.fit(asNotifications).map { entry in
                NotificationRequest(
                    id: entry.id,
                    fireAtUtcMs: entry.fireAtUtcMs,
                    title: entry.title.text(in: locale),
                    body: entry.body.text(in: locale),
                    sound: sounds.sound(for: entry.soundId),
                    timeSensitive: entry.kind.isTimeSensitive,
                )
            },
        )
    }

    /// At most `budget − testSlots` entries in the D80 order.
    static func fit(_ entries: [SchedulePlanEntry]) -> [SchedulePlanEntry] {
        let ordered = entries.sorted { lhs, rhs in
            let left = (lhs.kind == .horizonWarning ? 0 : 1, lhs.priority, lhs.fireAtUtcMs, lhs.id)
            let right = (rhs.kind == .horizonWarning ? 0 : 1, rhs.priority, rhs.fireAtUtcMs, rhs.id)
            return left < right
        }
        return Array(ordered.prefix(budget - testSlots))
    }
}

extension LocalizedText {
    /// The text in `locale`; both locales are required by the schema, so there is no fallback to make.
    func text(in locale: PlanLocale) -> String {
        switch locale {
        case .ar: ar
        case .en: en
        }
    }
}

extension EntryKind {
    /// Athan, Imsak and pre-reminders break through notification summaries; the horizon warning does not.
    var isTimeSensitive: Bool {
        switch self {
        case .athan, .imsak, .preReminder: true
        case .horizonWarning: false
        }
    }
}
