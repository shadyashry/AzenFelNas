import 'package:crypto/crypto.dart';

/// The lowercase hex SHA-256 of a payload (REQ-DIST-003). A port so the app
/// can hash multi-megabyte payloads off its UI isolate (§15 D96); this
/// package stays pure Dart and hashes in place by default.
abstract interface class HashPayload {
  /// The digest of [bytes].
  Future<String> call(List<int> bytes);
}

/// [HashPayload] on the calling isolate.
final class Sha256Payload implements HashPayload {
  /// The hasher.
  const new();

  @override
  Future<String> call(List<int> bytes) async =>
      sha256.convert(bytes).toString();
}
