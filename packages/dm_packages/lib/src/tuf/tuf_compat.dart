import 'package:freezed_annotation/freezed_annotation.dart';

part 'tuf_compat.freezed.dart';
part 'tuf_compat.g.dart';

/// Compatibility gate checked before activation (REQ-PKG-006).
@freezed
abstract class TufCompat with _$TufCompat {
  /// Creates a [TufCompat].
  const factory({
    /// Minimum app version.
    required String minApp,

    /// Minimum engine schema.
    required int minEngineSchema,
  }) = _TufCompat;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$TufCompatFromJson(json);
}
