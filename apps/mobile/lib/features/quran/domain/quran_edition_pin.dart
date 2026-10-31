import 'package:daily_muslim/features/quran/domain/mushaf_layout.dart';

/// The one Quran package this build accepts (§15 D107): its CDN path, the
/// SHA-256 and size of its `manifest.json`, and sizes measured on the built
/// package. The manifest lists every other file by SHA-256, so pinning it
/// pins the whole package.
abstract final class QuranEditionPin {
  /// Package id on the CDN.
  static const packageId = 'hafs-madinah-1441';

  /// Package build.
  static const version = '1441.2';

  /// Page layout identity; annotations are stored against it.
  static const layoutId = 'kfgqpc-hafs-1441-604';

  /// SHA-256 of `manifest.json`.
  static const manifestSha256 =
      'cb75e58345f573c39b2f810e508b336d4a1637df41e78e46b5ef23c694cb1964';

  /// Size of `manifest.json` in bytes.
  static const manifestBytes = 93131;

  /// Sum of the package files the manifest lists, in bytes (measured).
  static const downloadBytes = 115336977;

  /// Size of the search index the app builds after the download (measured
  /// on the built package with this build's folding).
  static const int searchIndexBytes = 1593344;

  /// Free space the download asks for: the package, its index and a
  /// margin. Files are renamed into place, never copied, so no second copy
  /// is needed.
  static const int requiredFreeBytes =
      downloadBytes + manifestBytes + searchIndexBytes + 16 * 1024 * 1024;

  /// The page order.
  static const layout = MushafLayout(604);

  /// Path of the package under the CDN channel directory.
  static const cdnPath = 'quran/$packageId/$version/';
}
