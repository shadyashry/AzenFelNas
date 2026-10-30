import 'package:daily_muslim/features/quran/domain/quran_manifest_file.dart';
import 'package:daily_muslim/features/quran/domain/quran_page_geometry.dart';
import 'package:meta/meta.dart';

/// What the app needs of a Quran package's `manifest.json`
/// (`quran_package.v1`, §15 D106); the data layer reads the wire form.
@immutable
final class QuranManifest {
  /// The manifest.
  const new({
    required this.packageId,
    required this.version,
    required this.layoutId,
    required this.printEdition,
    required this.pageCount,
    required this.pageImage,
    required this.files,
  });

  /// e.g. `hafs-madinah-1441`.
  final String packageId;

  /// Package build, e.g. `1441.1`.
  final String version;

  /// Page layout identity; notes are stored against it.
  final String layoutId;

  /// The digital edition, e.g. `1441`.
  final String printEdition;

  /// Pages in the Mushaf.
  final int pageCount;

  /// Page image size and naming.
  final QuranPageGeometry pageImage;

  /// Every file with its size and SHA-256.
  final List<QuranManifestFile> files;
}
