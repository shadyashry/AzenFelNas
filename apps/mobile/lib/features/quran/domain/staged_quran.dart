import 'package:daily_muslim/features/quran/domain/quran_manifest.dart';
import 'package:meta/meta.dart';

/// A download in progress: its directory, its pinned manifest, the files
/// already verified and the bytes of partly downloaded files.
@immutable
final class StagedQuran {
  /// The staging state.
  const new({
    required this.directory,
    required this.manifest,
    required this.verified,
    required this.partialBytes,
  });

  /// Absolute path of the staging directory.
  final String directory;

  /// The pinned manifest.
  final QuranManifest manifest;

  /// Paths whose size and SHA-256 were checked.
  final Set<String> verified;

  /// Path → bytes already in its `.part` file.
  final Map<String, int> partialBytes;

  /// Bytes on disk towards the package (verified files and partial ones).
  int get doneBytes =>
      manifest.files
          .where((f) => verified.contains(f.path))
          .fold<int>(0, (sum, f) => sum + f.bytes) +
      partialBytes.values.fold<int>(0, (sum, n) => sum + n);

  /// Bytes in the package.
  int get totalBytes => manifest.files.fold<int>(0, (sum, f) => sum + f.bytes);
}
