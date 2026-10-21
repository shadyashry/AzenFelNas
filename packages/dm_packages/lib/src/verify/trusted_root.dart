import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dm_packages/src/verify/hex.dart';
import 'package:meta/meta.dart';

/// The root keys a client already trusts (Appendix C): the keys embedded in
/// the app for the first root, or the previous root's root role for a
/// rotation. `root.json` must carry [threshold] valid signatures by them.
@immutable
final class TrustedRoot {
  /// Trusts [publicKeysById]: keyId → lowercase hex of the raw 32-byte
  /// Ed25519 key. Throws [ArgumentError] unless every keyId is the
  /// lowercase hex SHA-256 of its key's raw bytes (§15 D17) and
  /// `1 ≤ threshold ≤ publicKeysById.length`.
  new({
    required Map<String, String> publicKeysById,
    required this.threshold,
  }) : publicKeys = Map.unmodifiable({
         for (final MapEntry(key: id, value: public) in publicKeysById.entries)
           id: _checkedKey(id, public),
       }) {
    if (threshold < 1 || threshold > publicKeys.length) {
      throw ArgumentError.value(threshold, 'threshold', 'out of range');
    }
  }

  /// Reads the `root-keys.json` form (`{scheme, threshold, keys: [{keyId,
  /// public}]}`, tools/gsctl/keys/dev). Throws [FormatException] for another
  /// shape and [ArgumentError] as the constructor does.
  factory fromRootKeysJson(String json) => switch (jsonDecode(json)) {
    {
      'scheme': 'ed25519',
      'threshold': final int threshold,
      'keys': final List<Object?> keys,
    } =>
      TrustedRoot(
        publicKeysById: Map.fromEntries([
          for (final key in keys)
            switch (key) {
              {'keyId': final String id, 'public': final String public} =>
                MapEntry(id, public),
              _ => throw FormatException('root key entry: $key'),
            },
        ]),
        threshold: threshold,
      ),
    _ => throw const FormatException('not a root-keys.json document'),
  };

  /// keyId → raw 32-byte public key.
  final Map<String, List<int>> publicKeys;

  /// How many of [publicKeys] must sign `root.json`.
  final int threshold;

  static List<int> _checkedKey(String id, String publicHex) {
    final raw = hexBytes(publicHex);
    if (raw == null || raw.length != 32) {
      throw ArgumentError.value(publicHex, 'public', 'not 32 bytes of hex');
    }
    if (sha256.convert(raw).toString() != id) {
      throw ArgumentError.value(id, 'keyId', 'not the SHA-256 of its key');
    }
    return List.unmodifiable(raw);
  }
}
