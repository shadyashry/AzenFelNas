/// Outcome of a reconciliation (DESIGN.md §17.4), the same variants as Android's (D81).
enum ReconcileOutcome: Equatable, Sendable {
    /// Every request of the window of `generation` is held by the platform.
    case applied(generation: Int, armed: Int, path: DeliveryPath)
    /// The platform refused some requests; `refusedIds` are their entry ids.
    case partial(generation: Int, armed: Int, refusedIds: [String])
    /// There is no readable plan, so nothing is armed (Health: no plan ⇒ NOT_READY).
    case noPlan
    /// The offered plan is older than the persisted one, which stays armed (REQ-ALM-002).
    case stale(current: Int, offered: Int)
    /// Nothing was applied, for `code`; `detail` never holds document content.
    case failed(code: FailureCode, detail: String?)
}

/// Why the requests are reconciled; `label` is written to `attrs.reason` of `PLAN_APPLIED` and is the §7.8
/// `SystemEventKind` wire name for system events (REQ-ALM-041). iOS has no boot or package-replaced callback:
/// the app reconciles on launch and on these.
enum ReconcileCause: String, Sendable, CaseIterable {
    case timeChanged
    case timezoneChanged
    case permissionChanged
    case planApplied
    /// The app came to the foreground (`appDidBecomeActive`); also how a reboot or an update is noticed.
    case appActive

    var label: String { rawValue }
}
