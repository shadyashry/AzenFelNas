import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_profiles/src/document/elevation_policy_code.dart';

part 'horizon_document.freezed.dart';
part 'horizon_document.g.dart';

/// Horizon settings of a profile.
@freezed
abstract class HorizonDocument with _$HorizonDocument {
  /// Creates a [HorizonDocument].
  const factory({
    /// Elevation policy.
    required ElevationPolicyCode elevationPolicy,
  }) = _HorizonDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$HorizonDocumentFromJson(json);
}
