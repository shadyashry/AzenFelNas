/// TUF-lite package client: verify, stage, activate and roll back signed data
/// packages (DESIGN.md §7.4, ADR-009).
///
/// Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the
/// platform. Holds the `tuf_metadata.v1` wire model since S02 and, since
/// S09, the TUF-lite verifier (`VerifyMetadataChain`, `VerifyTargetFile`)
/// and, since S14, the package client: sync policy, staging, activation,
/// rollback, bundled seed import and garbage collection behind narrow ports.
library;

export 'package:dm_packages/src/client/activate_staged.dart';
export 'package:dm_packages/src/client/active_package.dart';
export 'package:dm_packages/src/client/app_compat.dart';
export 'package:dm_packages/src/client/bundled_seed.dart';
export 'package:dm_packages/src/client/channel_trust.dart';
export 'package:dm_packages/src/client/check_compatibility.dart';
export 'package:dm_packages/src/client/collect_package_garbage.dart';
export 'package:dm_packages/src/client/fetched_file.dart';
export 'package:dm_packages/src/client/import_bundled_seeds.dart';
export 'package:dm_packages/src/client/load_package_payload.dart';
export 'package:dm_packages/src/client/network_kind.dart';
export 'package:dm_packages/src/client/package_event.dart';
export 'package:dm_packages/src/client/package_file.dart';
export 'package:dm_packages/src/client/package_file_state.dart';
export 'package:dm_packages/src/client/package_source.dart';
export 'package:dm_packages/src/client/package_type.dart';
export 'package:dm_packages/src/client/ports/apply_package.dart';
export 'package:dm_packages/src/client/ports/check_payload.dart';
export 'package:dm_packages/src/client/ports/fetch_channel.dart';
export 'package:dm_packages/src/client/ports/inflate_payload.dart';
export 'package:dm_packages/src/client/ports/package_trust_store.dart';
export 'package:dm_packages/src/client/ports/read_bundled_seeds.dart';
export 'package:dm_packages/src/client/ports/read_network_kind.dart';
export 'package:dm_packages/src/client/ports/read_package_catalog.dart';
export 'package:dm_packages/src/client/ports/record_package_event.dart';
export 'package:dm_packages/src/client/ports/store_package_blobs.dart';
export 'package:dm_packages/src/client/ports/write_package_catalog.dart';
export 'package:dm_packages/src/client/roll_back_package.dart';
export 'package:dm_packages/src/client/seed_import_report.dart';
export 'package:dm_packages/src/client/select_targets.dart';
export 'package:dm_packages/src/client/stage_target.dart';
export 'package:dm_packages/src/client/staged_package.dart';
export 'package:dm_packages/src/client/sync_outcome.dart';
export 'package:dm_packages/src/client/sync_packages.dart';
export 'package:dm_packages/src/client/sync_policy.dart';
export 'package:dm_packages/src/client/sync_report.dart';
export 'package:dm_packages/src/client/target_choice.dart';
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
