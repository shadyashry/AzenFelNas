import 'package:freezed_annotation/freezed_annotation.dart';

part 'tuf_signature.freezed.dart';
part 'tuf_signature.g.dart';

/// One signature over the JCS canonical `signed` object (REQ-DIST-004).
@freezed
abstract class TufSignature with _$TufSignature {
  /// Creates a [TufSignature].
  const factory({
    /// Lowercase hex SHA-256 of the signing public key.
    required String keyId,

    /// Base64 Ed25519 signature.
    required String sig,
  }) = _TufSignature;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$TufSignatureFromJson(json);
}
