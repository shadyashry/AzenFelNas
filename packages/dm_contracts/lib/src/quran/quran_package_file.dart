import 'package:freezed_annotation/freezed_annotation.dart';

part 'quran_package_file.freezed.dart';
part 'quran_package_file.g.dart';

/// One file of the Quran package.
@freezed
abstract class QuranPackageFile with _$QuranPackageFile {
  /// Creates a [QuranPackageFile].
  const factory({
    /// Path relative to the package directory (lowercase, no `..`).
    required String path,

    /// Size in bytes.
    required int bytes,

    /// Lowercase hex SHA-256.
    required String sha256,
  }) = _QuranPackageFile;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$QuranPackageFileFromJson(json);
}
