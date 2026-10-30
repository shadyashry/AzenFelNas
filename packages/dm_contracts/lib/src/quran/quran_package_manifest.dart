import 'package:dm_contracts/src/quran/quran_edition.dart';
import 'package:dm_contracts/src/quran/quran_package_file.dart';
import 'package:dm_contracts/src/quran/quran_page_image.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'quran_package_manifest.freezed.dart';
part 'quran_package_manifest.g.dart';

/// Wire form of `quran_package.v1` (§9.5, §15 D106): the offline Quran
/// package's `manifest.json`.
@freezed
abstract class QuranPackageManifest with _$QuranPackageManifest {
  /// Creates a [QuranPackageManifest].
  const factory({
    /// Always 1.
    required int schemaVersion,

    /// e.g. `hafs-madinah-1441`.
    required String packageId,

    /// Package build, e.g. `1441.1`.
    required String version,

    /// Page layout identity; annotations are stored against it.
    required String layoutId,

    /// The edition and its sources.
    required QuranEdition edition,

    /// Page image geometry.
    required QuranPageImage pageImage,

    /// Every file with its size and SHA-256.
    required List<QuranPackageFile> files,
  }) = _QuranPackageManifest;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$QuranPackageManifestFromJson(json);
}
