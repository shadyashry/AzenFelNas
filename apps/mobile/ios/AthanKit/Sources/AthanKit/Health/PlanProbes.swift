/// Probes answered by the persisted plan and the sound library: present, horizon not ending (the iOS
/// `HORIZON_WARNING` lead of 24 h, D80) and every Athan sound installed as a clip (REQ-ALM-034).
struct PlanProbes: Sendable {
    /// iOS `HORIZON_WARNING` lead before `horizonEndUtcMs` (§7.7, D80).
    static let horizonWarningLeadMs: Int64 = 24 * 60 * 60 * 1000

    let sounds: any SoundCatalog

    func probes(of plan: SchedulePlan?, nowUtcMs: Int64) -> [ProbeResult] {
        guard let plan else {
            return [
                ProbeResult(.planPresent, false),
                ProbeResult(.planHorizon, nil, detail: Self.noPlan),
                ProbeResult(.soundAssetPresence, nil, detail: Self.noPlan),
            ]
        }
        var seen = Set<String>()
        let athanSounds = plan.entries.filter { $0.kind == .athan }.map(\.soundId).filter { seen.insert($0).inserted }
        let missing = athanSounds.count(where: { !sounds.isInstalled($0) })
        return [
            ProbeResult(.planPresent, true),
            ProbeResult(.planHorizon, plan.horizonEndUtcMs - nowUtcMs > Self.horizonWarningLeadMs),
            ProbeResult(.soundAssetPresence, missing == 0, detail: missing == 0 ? nil : "\(missing) missing"),
        ]
    }

    private static let noPlan = "no plan"
}
