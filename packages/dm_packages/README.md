# dm_packages

TUF-lite package client: verify, stage, activate and roll back signed data packages (DESIGN.md §7.4, ADR-009).

Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the platform.

- Since S02: the `tuf_metadata.v1` wire model (`lib/src/tuf/`).
- Since S09: the minimal verifier (`lib/src/verify/`, §15 D63).
  - `VerifyMetadataChain` checks root against the trusted root keys, then timestamp → snapshot → targets: Ed25519 over JCS (`dm_core_types` `CanonicalJson`), Appendix C thresholds, hash pins and strictly increasing sequences. An expired role is a `FreshnessWarning`, not a failure.
  - `VerifyTargetFile` checks a package's length and SHA-256.
  - Failures are `PackageFailure`s with Appendix J `PKG_*` codes. Signatures go through the `VerifyEd25519` port; its adapter is `package:cryptography` (`CryptographyEd25519`).
  - `test/tuf/go_round_trip_test.dart` verifies what `gsctl` signed with the dev keys (`tools/gsctl/testdata/roundtrip`).
- In S14: the package client: download, root rotation chains, staging, activation, rollback and sync policy.
