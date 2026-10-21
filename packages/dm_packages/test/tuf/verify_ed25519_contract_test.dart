import 'package:dm_packages/dm_packages.dart';
import 'package:test/test.dart';

List<int> _hex(String hex) => [
  for (var i = 0; i < hex.length; i += 2)
    int.parse(hex.substring(i, i + 2), radix: 16),
];

// RFC 8032 §7.1, TEST 2: a one-byte message.
const String _rfc8032Test2Public =
    '3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c';
final List<int> _public = _hex(_rfc8032Test2Public);
final List<int> _message = _hex('72');
final List<int> _signature = _hex(
  '92a009a9f0d4cab8720e820b5f642540a2b27b5416503f8fb3762223ebdb69da'
  '085ac1e43e15996e458f3613d0f11d8c387b2eaeb4302aeeb00d291612bb0c00',
);

/// The [VerifyEd25519] contract (REQ-TEST-004), run against every
/// implementation.
void verifyEd25519Contract(String name, VerifyEd25519 Function() create) {
  group('$name honours the VerifyEd25519 contract (REQ-TEST-004)', () {
    test('accepts the RFC 8032 test vector', () async {
      expect(
        await create()(
          message: _message,
          signature: _signature,
          publicKey: _public,
        ),
        isTrue,
      );
    });

    test('rejects a changed message, signature or key', () async {
      final verify = create();
      expect(
        await verify(
          message: [0x73],
          signature: _signature,
          publicKey: _public,
        ),
        isFalse,
      );
      expect(
        await verify(
          message: _message,
          signature: [..._signature]..[10] ^= 1,
          publicKey: _public,
        ),
        isFalse,
      );
      expect(
        await verify(
          message: _message,
          signature: _signature,
          publicKey: [..._public]..[0] ^= 1,
        ),
        isFalse,
      );
    });

    test('answers false, never throws, for wrong lengths or keys', () async {
      final verify = create();
      expect(
        await verify(
          message: _message,
          signature: _signature.sublist(1),
          publicKey: _public,
        ),
        isFalse,
      );
      expect(
        await verify(
          message: _message,
          signature: _signature,
          publicKey: _public.sublist(1),
        ),
        isFalse,
      );
      expect(
        await verify(
          message: _message,
          signature: _signature,
          publicKey: List.filled(32, 0xff),
        ),
        isFalse,
      );
    });
  });
}

void main() {
  verifyEd25519Contract('CryptographyEd25519', CryptographyEd25519.new);

  group('TrustedRoot (§15 D17)', () {
    test('rejects a keyId that is not the SHA-256 of its key', () {
      expect(
        () => TrustedRoot(
          publicKeysById: {
            '00' * 32: _rfc8032Test2Public,
          },
          threshold: 1,
        ),
        throwsArgumentError,
      );
    });

    test('rejects a threshold above the key count', () {
      expect(
        () => TrustedRoot(publicKeysById: const {}, threshold: 1),
        throwsArgumentError,
      );
    });
  });
}
