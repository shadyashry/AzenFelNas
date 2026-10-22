import 'package:dm_packages/src/verify/trusted_sequences.dart';
import 'package:meta/meta.dart';

/// What the client keeps between syncs for one channel: the last verified
/// `root.json` (the anchor for the next rotation), the trusted sequences
/// (REQ-PKG-005) and when it last synced and last verified (REQ-PKG-002,
/// REQ-PKG-004).
@immutable
final class ChannelTrust {
  /// The stored state.
  const new({
    required this.sequences,
    required this.lastSyncUtcMs,
    this.rootJson,
    this.lastVerifiedUtcMs,
  });

  /// A first install: the embedded root, nothing trusted, never synced.
  static const ChannelTrust initial = ChannelTrust(
    sequences: TrustedSequences.none,
    lastSyncUtcMs: 0,
  );

  /// The last verified `root.json` bytes; null until the first sync, when
  /// the root keys embedded in the app are the anchor.
  final List<int>? rootJson;

  /// The trusted sequences and file hashes.
  final TrustedSequences sequences;

  /// The start of the last sync attempt, UTC epoch milliseconds; 0 for
  /// never. Bounds the 6 h interval (REQ-PKG-004).
  final int lastSyncUtcMs;

  /// The last metadata verification that carried no freshness warning, UTC
  /// epoch milliseconds; null for never. Drives "data last verified N days
  /// ago" (US-17).
  final int? lastVerifiedUtcMs;
}
