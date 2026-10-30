import 'package:meta/meta.dart';

/// One file of the Quran package as its manifest lists it.
@immutable
final class QuranManifestFile {
  /// The file at [path] of [bytes] bytes with [sha256].
  const new({required this.path, required this.bytes, required this.sha256});

  /// Path inside the package (lowercase, no `..`).
  final String path;

  /// Size in bytes.
  final int bytes;

  /// Lowercase hex SHA-256.
  final String sha256;

  @override
  bool operator ==(Object other) =>
      other is QuranManifestFile &&
      other.path == path &&
      other.bytes == bytes &&
      other.sha256 == sha256;

  @override
  int get hashCode => Object.hash(path, bytes, sha256);
}
