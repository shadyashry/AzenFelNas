/// TUF-lite package client: verify, stage, activate and roll back signed data
/// packages (DESIGN.md §7.4, ADR-009).
///
/// Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the
/// platform. Holds the `tuf_metadata.v1` wire model since S02 and, since
/// S09, the minimal TUF-lite verifier (`VerifyMetadataChain`,
/// `VerifyTargetFile`) that proves what gsctl signs verifies in Dart; the
/// package client (stage, activate, roll back) arrives in S14.
library;

export 'package:dm_packages/src/tuf/payload_format_code.dart';
export 'package:dm_packages/src/tuf/target_priority_code.dart';
export 'package:dm_packages/src/tuf/tuf_change_note.dart';
export 'package:dm_packages/src/tuf/tuf_compat.dart';
export 'package:dm_packages/src/tuf/tuf_key.dart';
export 'package:dm_packages/src/tuf/tuf_key_scheme.dart';
export 'package:dm_packages/src/tuf/tuf_meta_ref.dart';
export 'package:dm_packages/src/tuf/tuf_metadata.dart';
export 'package:dm_packages/src/tuf/tuf_role.dart';
export 'package:dm_packages/src/tuf/tuf_roles.dart';
export 'package:dm_packages/src/tuf/tuf_signature.dart';
export 'package:dm_packages/src/tuf/tuf_signed.dart';
export 'package:dm_packages/src/tuf/tuf_snapshot_meta.dart';
export 'package:dm_packages/src/tuf/tuf_target.dart';
export 'package:dm_packages/src/tuf/tuf_target_custom.dart';
export 'package:dm_packages/src/tuf/tuf_timestamp_meta.dart';
export 'package:dm_packages/src/verify/cryptography_ed25519.dart';
export 'package:dm_packages/src/verify/freshness_warning.dart';
export 'package:dm_packages/src/verify/metadata_files.dart';
export 'package:dm_packages/src/verify/metadata_role.dart';
export 'package:dm_packages/src/verify/package_failure.dart';
export 'package:dm_packages/src/verify/trusted_root.dart';
export 'package:dm_packages/src/verify/trusted_sequences.dart';
export 'package:dm_packages/src/verify/verified_metadata.dart';
export 'package:dm_packages/src/verify/verify_ed25519.dart';
export 'package:dm_packages/src/verify/verify_metadata_chain.dart';
export 'package:dm_packages/src/verify/verify_target_file.dart';
