import 'package:dm_packages/src/client/package_source.dart';
import 'package:dm_packages/src/client/package_type.dart';
import 'package:meta/meta.dart';

/// The active version of one package type (§7.3 `active_packages`).
@immutable
final class ActivePackage {
  /// [type] is active at [version].
  const new({
    required this.type,
    required this.version,
    required this.sequence,
    required this.sha256,
    required this.source,
    required this.activatedUtcMs,
    this.previousVersion,
  });

  /// The package type.
  final PackageType type;

  /// The active version.
  final String version;

  /// The `targets.json` sequence the version was activated under; 0 for a
  /// bundled seed. The pointer never moves to a lower one
  /// (downgrade-safe, §7.3).
  final int sequence;

  /// SHA-256 of the active file (see `PackageFile.sha256`).
  final String sha256;

  /// Where it came from.
  final PackageSource source;

  /// When it became active, UTC epoch milliseconds.
  final int activatedUtcMs;

  /// The version it replaced, kept as the rollback target; null when none.
  final String? previousVersion;

  @override
  bool operator ==(Object other) =>
      other is ActivePackage &&
      other.type == type &&
      other.version == version &&
      other.sequence == sequence &&
      other.sha256 == sha256 &&
      other.source == source &&
      other.activatedUtcMs == activatedUtcMs &&
      other.previousVersion == previousVersion;

  @override
  int get hashCode => Object.hash(
    ActivePackage,
    type,
    version,
    sequence,
    sha256,
    source,
    activatedUtcMs,
    previousVersion,
  );

  @override
  String toString() =>
      'ActivePackage(${type.wire}/$version, ${source.wire}, '
      'sequence $sequence, previous $previousVersion)';
}
