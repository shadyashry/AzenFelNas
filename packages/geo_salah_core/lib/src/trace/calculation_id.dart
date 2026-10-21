import 'dart:convert';

import 'package:crypto/crypto.dart';

/// The Calculation ID of a prayer day (§6.4 ¶11, P1): `GS-` + RFC 4648
/// base32 (upper case, no padding) of the first 10 bytes of
/// `sha256(inputsHash|engineVersion|deltaTModel|tzdbVersion)`, 16
/// characters after the prefix.
///
/// The four parts are joined with `|` and hashed as UTF-8. Equal parts give
/// equal IDs (REQ-DOM-004); any engine, ΔT-model or TZDB change gives a new
/// one. Pure and deterministic.
abstract final class CalculationId {
  static const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  /// The Calculation ID of the four provenance parts.
  static String of({
    required String inputsHash,
    required String engineVersion,
    required String deltaTModel,
    required String tzdbVersion,
  }) {
    final digest = sha256.convert(
      utf8.encode('$inputsHash|$engineVersion|$deltaTModel|$tzdbVersion'),
    );
    return 'GS-${base32(digest.bytes.sublist(0, 10))}';
  }

  /// RFC 4648 §6 base32 of [bytes], upper case, without padding.
  static String base32(List<int> bytes) {
    final out = StringBuffer();
    var buffer = 0;
    var bits = 0;
    for (final byte in bytes) {
      buffer = (buffer << 8) | (byte & 0xFF);
      bits += 8;
      while (bits >= 5) {
        bits -= 5;
        out.write(_alphabet[(buffer >> bits) & 0x1F]);
      }
      buffer &= (1 << bits) - 1;
    }
    if (bits > 0) out.write(_alphabet[(buffer << (5 - bits)) & 0x1F]);
    return out.toString();
  }
}
