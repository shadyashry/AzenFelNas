import 'package:json_annotation/json_annotation.dart';

/// Signature scheme of a key; only Ed25519 (Appendix C).
@JsonEnum()
enum TufKeyScheme {
  /// Ed25519.
  ed25519,
}
