import 'package:dm_packages/src/tuf/tuf_signature.dart';
import 'package:dm_packages/src/tuf/tuf_signed.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tuf_metadata.freezed.dart';
part 'tuf_metadata.g.dart';

/// Wire form of `tuf_metadata.v1` (Appendix C): a signed envelope. Signature
/// verification and sequence checks arrive in S14 (REQ-PKG-001, REQ-PKG-005).
@freezed
abstract class TufMetadata with _$TufMetadata {
  /// Creates a [TufMetadata].
  const factory({
    /// The signed role document.
    required TufSigned signed,

    /// Signatures over JCS(`signed`).
    required List<TufSignature> signatures,
  }) = _TufMetadata;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$TufMetadataFromJson(json);
}
