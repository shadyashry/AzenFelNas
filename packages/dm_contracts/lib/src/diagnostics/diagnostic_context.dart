import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnostic_context.freezed.dart';
part 'diagnostic_context.g.dart';

/// Location context kind (§7.5).
enum DiagnosticContextKind {
  /// Follows the device.
  current,

  /// Pinned by the user.
  pinned,

  /// Typed or searched by the user.
  manual,
}

/// `context.json`: the active context at whole hundredths of a degree, so a
/// finer coordinate cannot be written (REQ-PRIV-005).
@freezed
abstract class DiagnosticContext with _$DiagnosticContext {
  /// Creates a [DiagnosticContext].
  const factory({
    /// Kind.
    required DiagnosticContextKind kind,

    /// Source wire name.
    required String source,

    /// Latitude in units of 0.01°.
    required int latE2,

    /// Longitude in units of 0.01°.
    required int lonE2,

    /// IANA zone.
    required String zoneId,

    /// ISO 3166-1 alpha-2, or null when unresolved.
    @JsonKey(includeIfNull: true) required String? countryCode,
  }) = _DiagnosticContext;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$DiagnosticContextFromJson(json);
}
