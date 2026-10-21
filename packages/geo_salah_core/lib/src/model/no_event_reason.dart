/// Why an event has no time on a prayer day (§6.2, REQ-DOM-002).
enum NoEventReason {
  /// The Sun stays above the event's target altitude all half-day (midnight
  /// sun).
  polarDay('POLAR_DAY'),

  /// The Sun stays below the event's target altitude all half-day (polar
  /// night).
  polarNight('POLAR_NIGHT'),

  /// The twilight altitude is never reached.
  twilightAbsent('TWILIGHT_ABSENT'),

  /// The Asr shadow condition cannot occur.
  asrUndefined('ASR_UNDEFINED'),

  /// Every high-latitude method in the profile's chain failed.
  chainExhausted('CHAIN_EXHAUSTED');

  new(this.code);

  /// The stable code of the reason, carried by `ConfidenceLabel.unknown`
  /// (§6.2 mapping) and the trace's `NO_EVENT` origin.
  final String code;
}
