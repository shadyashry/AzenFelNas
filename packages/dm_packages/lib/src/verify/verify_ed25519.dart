/// Port: checks one Ed25519 signature (REQ-DIST-004). Consumer-defined for
/// `VerifyMetadataChain`.
///
/// Contract, shared by every implementation and checked by the contract
/// tests (REQ-TEST-004): completes with `true` exactly when `signature` (64
/// bytes) is a valid Ed25519 signature of `message` by `publicKey` (32 raw
/// bytes); any other input, including wrong lengths, completes with
/// `false`. Never throws. Deterministic.
abstract interface class VerifyEd25519 {
  /// Whether [signature] verifies.
  Future<bool> call({
    required List<int> message,
    required List<int> signature,
    required List<int> publicKey,
  });
}
