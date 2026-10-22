import 'package:meta/meta.dart';

/// The sequences a client already trusts, per role, and the SHA-256 of the
/// files that carried them. 0 means
/// nothing is trusted yet and bounds nothing.
///
/// New metadata must exceed each sequence (REQ-PKG-005). The one exception
/// is an unchanged file: a file whose sequence equals the trusted one and
/// whose bytes hash to the trusted SHA-256 is the same document again (a
/// `snapshot.json` re-pinned by a newer timestamp, or a whole channel that
/// has not moved). Nothing new is accepted from it (§15 D74).
@immutable
final class TrustedSequences {
  /// The trusted sequences; each is 0 or more.
  const new({
    this.timestamp = 0,
    this.snapshot = 0,
    this.targets = 0,
    this.timestampSha256,
    this.snapshotSha256,
    this.targetsSha256,
  }) : assert(
         timestamp >= 0 && snapshot >= 0 && targets >= 0,
         'sequences are never negative',
       );

  /// Nothing trusted yet: a first install.
  static const TrustedSequences none = TrustedSequences();

  /// The trusted `timestamp.json` sequence.
  final int timestamp;

  /// The trusted `snapshot.json` sequence.
  final int snapshot;

  /// The trusted `targets.json` sequence.
  final int targets;

  /// Lowercase hex SHA-256 of the trusted `timestamp.json`; null when
  /// unknown.
  final String? timestampSha256;

  /// Lowercase hex SHA-256 of the trusted `snapshot.json`; null when unknown.
  final String? snapshotSha256;

  /// Lowercase hex SHA-256 of the trusted `targets.json`; null when unknown.
  final String? targetsSha256;

  @override
  bool operator ==(Object other) =>
      other is TrustedSequences &&
      other.timestamp == timestamp &&
      other.snapshot == snapshot &&
      other.targets == targets &&
      other.timestampSha256 == timestampSha256 &&
      other.snapshotSha256 == snapshotSha256 &&
      other.targetsSha256 == targetsSha256;

  @override
  int get hashCode => Object.hash(
    TrustedSequences,
    timestamp,
    snapshot,
    targets,
    timestampSha256,
    snapshotSha256,
    targetsSha256,
  );

  @override
  String toString() =>
      'TrustedSequences(timestamp: $timestamp, snapshot: $snapshot, '
      'targets: $targets)';
}
