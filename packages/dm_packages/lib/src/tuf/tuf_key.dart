import 'package:dm_packages/src/tuf/tuf_key_scheme.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tuf_key.freezed.dart';
part 'tuf_key.g.dart';

/// A public key.
@freezed
abstract class TufKey with _$TufKey {
  /// Creates a [TufKey].
  const factory({
    /// Scheme.
    required TufKeyScheme scheme,

    /// Lowercase hex raw public key.
    required String public,
  }) = _TufKey;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$TufKeyFromJson(json);
}
