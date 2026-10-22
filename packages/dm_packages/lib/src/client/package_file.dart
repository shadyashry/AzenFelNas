import 'package:dm_packages/src/client/package_file_state.dart';
import 'package:dm_packages/src/client/package_source.dart';
import 'package:dm_packages/src/client/package_type.dart';
import 'package:meta/meta.dart';

/// One stored version of a package (§7.3 `package_files`, plus `source`
/// and `updatedUtcMs`, §15 D74). A downloaded file is the verified `.dmpkg`
/// at [path] in the package blob store; a bundled one names its seed and
/// has no blob.
@immutable
final class PackageFile {
  /// The file of [type] [version].
  const new({
    required this.type,
    required this.version,
    required this.path,
    required this.sha256,
    required this.source,
    required this.state,
    required this.updatedUtcMs,
  });

  /// The package type.
  final PackageType type;

  /// The target version (the part after `/` in the target name).
  final String version;

  /// Blob-store path of a downloaded file (`<type>/<version>/<sha256>.dmpkg`),
  /// or `bundled:<type>/<version>` for a seed.
  final String path;

  /// Lowercase hex SHA-256: of the `.dmpkg` when downloaded, of the payload
  /// when bundled.
  final String sha256;

  /// Where the file came from.
  final PackageSource source;

  /// Where the file is in its life cycle.
  final PackageFileState state;

  /// When [state] was last set, UTC epoch milliseconds.
  final int updatedUtcMs;

  /// This file in [next] state from [utcMs].
  PackageFile withState(PackageFileState next, int utcMs) => PackageFile(
    type: type,
    version: version,
    path: path,
    sha256: sha256,
    source: source,
    state: next,
    updatedUtcMs: utcMs,
  );

  /// The blob-store path of a downloaded file.
  static String downloadedPath(PackageType type, String version, String sha) =>
      '${type.wire}/$version/$sha.dmpkg';

  /// The path recorded for a bundled seed.
  static String bundledPath(PackageType type, String version) =>
      'bundled:${type.wire}/$version';

  @override
  bool operator ==(Object other) =>
      other is PackageFile &&
      other.type == type &&
      other.version == version &&
      other.path == path &&
      other.sha256 == sha256 &&
      other.source == source &&
      other.state == state &&
      other.updatedUtcMs == updatedUtcMs;

  @override
  int get hashCode => Object.hash(
    PackageFile,
    type,
    version,
    path,
    sha256,
    source,
    state,
    updatedUtcMs,
  );

  @override
  String toString() =>
      'PackageFile(${type.wire}/$version, ${source.wire}, ${state.wire})';
}
