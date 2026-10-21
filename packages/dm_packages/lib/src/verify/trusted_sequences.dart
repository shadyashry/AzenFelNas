import 'package:meta/meta.dart';

/// The sequences a client already trusts, per role. 0 means nothing is
/// trusted yet and bounds nothing. New metadata must exceed each
/// (REQ-PKG-005).
@immutable
final class TrustedSequences {
  /// The trusted sequences; each is 0 or more.
  const new({this.timestamp = 0, this.snapshot = 0, this.targets = 0})
    : assert(
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

  @override
  bool operator ==(Object other) =>
      other is TrustedSequences &&
      other.timestamp == timestamp &&
      other.snapshot == snapshot &&
      other.targets == targets;

  @override
  int get hashCode =>
      Object.hash(TrustedSequences, timestamp, snapshot, targets);

  @override
  String toString() =>
      'TrustedSequences(timestamp: $timestamp, snapshot: $snapshot, '
      'targets: $targets)';
}
