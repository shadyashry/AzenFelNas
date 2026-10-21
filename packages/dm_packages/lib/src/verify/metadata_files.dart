import 'package:meta/meta.dart';

/// The four metadata files of one channel, exactly as downloaded. Hashes
/// and signatures are checked against these bytes, never a re-encoding.
@immutable
final class MetadataFiles {
  /// Wraps the four files.
  const new({
    required this.root,
    required this.timestamp,
    required this.snapshot,
    required this.targets,
  });

  /// `root.json`.
  final List<int> root;

  /// `timestamp.json`.
  final List<int> timestamp;

  /// `snapshot.json`.
  final List<int> snapshot;

  /// `targets.json`.
  final List<int> targets;
}
