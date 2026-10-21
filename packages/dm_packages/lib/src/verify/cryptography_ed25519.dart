import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:dm_packages/src/verify/verify_ed25519.dart';

/// [VerifyEd25519] with `package:cryptography`'s pure-Dart Ed25519 (§9.1).
final class CryptographyEd25519 implements VerifyEd25519 {
  /// The adapter.
  const new();

  static const int _publicKeyBytes = 32;
  static const int _signatureBytes = 64;

  @override
  Future<bool> call({
    required List<int> message,
    required List<int> signature,
    required List<int> publicKey,
  }) async {
    if (signature.length != _signatureBytes ||
        publicKey.length != _publicKeyBytes) {
      return false;
    }
    return await DartEd25519().verify(
      message,
      signature: Signature(
        signature,
        publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519),
      ),
    );
  }
}
