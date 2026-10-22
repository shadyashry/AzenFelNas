import 'package:dm_packages/src/client/package_type.dart';
import 'package:meta/meta.dart';

/// One package version shipped in the binary under `assets/packages/`
/// (REQ-PKG-003): the payload itself, not a `.dmpkg`.
@immutable
final class BundledSeed {
  /// The seed of [type] [version].
  const new({
    required this.type,
    required this.version,
    required this.schemaVersion,
    required this.sha256,
  });

  /// The package type.
  final PackageType type;

  /// The version, as the CDN would name it.
  final String version;

  /// The payload schema version.
  final int schemaVersion;

  /// Lowercase hex SHA-256 of the payload; checked before import.
  final String sha256;

  @override
  String toString() => 'BundledSeed(${type.wire}/$version)';
}
