/// The kind of an adjustment applied after an event's rule (§6.2).
enum AdjustmentKind {
  /// A profile per-event minute offset (§6.4 ¶8).
  perEventOffset,

  /// A Ramadan rule replaced the event's rule (§6.4 ¶6).
  ramadanRuleReplacement,

  /// A high-latitude method produced the time (§6.4 ¶7).
  highLatitudeFallback,

  /// Per-event rounding, applied last (§6.4 ¶9).
  rounding,
}
