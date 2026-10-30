import 'package:dm_contracts/dm_contracts.dart';
import 'package:meta/meta.dart';

/// A verified, active Quran package on this device.
@immutable
final class InstalledQuran {
  /// The package in [directory] described by [manifest], taking
  /// [installedBytes] on disk (package files and the local search index).
  const new({
    required this.directory,
    required this.manifest,
    required this.installedBytes,
  });

  /// Absolute path of the package directory.
  final String directory;

  /// Its pinned manifest.
  final QuranPackageManifest manifest;

  /// Bytes on disk, measured.
  final int installedBytes;

  /// Absolute path of [page]'s image.
  String pagePath(int page) =>
      '$directory/${manifest.pageImage.pathPattern.replaceFirst('{page:03}', page.toString().padLeft(3, '0'))}';

  @override
  bool operator ==(Object other) =>
      other is InstalledQuran &&
      other.directory == directory &&
      other.manifest == manifest &&
      other.installedBytes == installedBytes;

  @override
  int get hashCode => Object.hash(directory, manifest, installedBytes);
}
