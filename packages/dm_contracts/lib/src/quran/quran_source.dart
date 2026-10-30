import 'package:dm_contracts/src/quran/quran_source_role.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'quran_source.freezed.dart';
part 'quran_source.g.dart';

/// One pinned source of the Quran package and its licence.
@freezed
abstract class QuranSource with _$QuranSource {
  /// Creates a [QuranSource].
  const factory({
    /// What the source supplies.
    required QuranSourceRole role,

    /// Where it was downloaded from (`https://`).
    required String url,

    /// Lowercase hex SHA-256 of the downloaded bytes.
    required String sha256,

    /// The source's own version.
    required String version,

    /// The licence or usage terms it is used under.
    required String license,
  }) = _QuranSource;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$QuranSourceFromJson(json);
}
