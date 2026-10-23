import Foundation

/// The platform ids of plan entries. Plan entry ids are 16 lowercase hex digits (`PlanEntryId`, D80): a pending
/// notification uses the entry id itself, an AlarmKit alarm the UUID whose two halves are the entry id. Ids of
/// any other shape (the Athan Test, the S19 spike) are never touched by reconciliation.
enum PlanIds {
    /// Whether `id` is the notification id of a plan entry.
    static func isPlanNotification(_ id: String) -> Bool {
        id.count == 16 && id.allSatisfy { $0.isHexDigit && !$0.isUppercase }
    }

    /// The AlarmKit id of entry `entryId`, or nil when it is not a plan entry id.
    static func alarmId(of entryId: String) -> UUID? {
        guard isPlanNotification(entryId) else { return nil }
        let hex = entryId + entryId
        let parts = [hex.prefix(8), hex.dropFirst(8).prefix(4), hex.dropFirst(12).prefix(4),
                     hex.dropFirst(16).prefix(4), hex.dropFirst(20)]
        return UUID(uuidString: parts.joined(separator: "-"))
    }

    /// The entry id of AlarmKit id `id`, or nil when it is not a plan alarm; the first 16 hex digits, as the S19
    /// receipts (D79).
    static func entryId(ofAlarm id: UUID) -> String? {
        let hex = id.uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        let head = String(hex.prefix(16))
        return hex == head + head ? head : nil
    }
}
