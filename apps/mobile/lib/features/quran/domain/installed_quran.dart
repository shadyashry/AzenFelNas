import 'package:daily_muslim/features/quran/domain/quran_manifest.dart';
import 'package:meta/meta.dart';

/// A verified, active Quran package on this device.
@immutable
final class InstalledQuran {
  /// The package in [directory] described by [manifest], taking
  /// [installedBytes] on disk (package files and the local search index).
  const new({
    required this.directory,
    required this.manifest,
    required this.manifestSha256,
    required this.installedBytes,
  });

  /// Absolute path of the package directory.
  final String directory;

  /// Its pinned manifest.
  final QuranManifest manifest;

  /// SHA-256 of its manifest; differs from the build's pin when this build
  /// expects a newer package.
  final String manifestSha256;

  /// Bytes on disk, measured.
  final int installedBytes;

  /// Absolute path of [page]'s image.
  String pagePath(int page) => '$directory/${manifest.pageImage.pathOf(page)}';

  @override
  bool operator ==(Object other) =>
      other is InstalledQuran &&
      other.directory == directory &&
      other.manifest == manifest &&
      other.installedBytes == installedBytes;

  @override
  int get hashCode => Object.hash(directory, manifest, installedBytes);
}
