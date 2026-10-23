/// Whether AlarmKit delivery has device evidence. ADR-013/ADR-025: until the S19 device run reports GO, AlarmKit
/// never reports `READY`; the GO commit flips this constant with the receipts that justify it.
enum AlarmKitEvidence {
    static let deliveryProven = false
}

/// The Athan Health state machine of DESIGN.md §8.3 with Android's ordering (D81): a blocking probe that is
/// `false` ⇒ `NOT_READY`, else a degrading one ⇒ `LIMITED`, else any gating probe that cannot tell ⇒ `UNKNOWN`;
/// `READY` needs every gating probe `true`. It adds the `deliveryVerified` probe itself, `false` on the
/// notification path, so no probe source can make that path `READY` (REQ-ALM-033).
struct EvaluateHealth: Sendable {
    func callAsFunction(_ probes: [ProbeResult], path: DeliveryPath, evaluatedAtUtcMs: Int64) -> HealthReport {
        let delivered = ProbeResult(
            .deliveryVerified,
            path == .alarmKit && AlarmKitEvidence.deliveryProven,
            detail: path == .notification ? Self.unverifiable : nil
        )
        let all = probes.filter { $0.name != .deliveryVerified } + [delivered]
        let gating = all.filter { $0.name.severity(on: path) != .informational }
        let state: HealthState =
            if gating.contains(where: { $0.name.severity(on: path) == .blocking && $0.positive == false }) {
                .notReady
            } else if gating.contains(where: { $0.positive == false }) {
                .limited
            } else if gating.contains(where: { $0.positive == nil }) {
                .unknown
            } else {
                .ready
            }
        var reasons: [HealthReason] = []
        for probe in all where probe.positive == false {
            if let reason = probe.name.reason, !reasons.contains(reason) { reasons.append(reason) }
        }
        return HealthReport(
            state: state, reasons: reasons, probes: all, evaluatedAtUtcMs: evaluatedAtUtcMs, platformPath: path.label
        )
    }

    /// `detail` of the notification path's `deliveryVerified`: iOS gives no delivery receipt for it (ADR-013).
    static let unverifiable = "notificationPath"
}
