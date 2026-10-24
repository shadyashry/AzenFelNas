import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnostic_package.freezed.dart';
part 'diagnostic_package.g.dart';

/// One active package in `packages.json`.
@freezed
abstract class DiagnosticPackage with _$DiagnosticPackage {
  /// Creates a [DiagnosticPackage].
  const factory({
    /// Package type wire name.
    required String type,

    /// Package version.
    required String version,

    /// Snapshot sequence it was activated from.
    required int sequence,
  }) = _DiagnosticPackage;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$DiagnosticPackageFromJson(json);
}
