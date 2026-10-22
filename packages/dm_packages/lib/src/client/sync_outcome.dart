/// How a sync ended; [wire] is the `SYNC_RESULT` `reason`.
enum SyncOutcome {
  /// The last attempt was less than 6 h ago (REQ-PKG-004); nothing fetched.
  skippedInterval('skipped_interval'),

  /// No network; nothing fetched.
  offline('offline'),

  /// The timestamp carries no new sequence; nothing to do.
  upToDate('up_to_date'),

  /// Metadata verified; every chosen target was tried.
  completed('completed'),

  /// The metadata could not be fetched, verified or stored; the
  /// last-known-good stays active (REQ-PKG-001).
  failed('failed');

  new(this.wire);

  /// The event-log name.
  final String wire;
}
