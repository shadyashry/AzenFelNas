import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// Unpacks a `.dmpkg` (gzip of one payload file, §9.1, §15 D60). Pure set
/// rule: the gzip codec is an adapter (`dart:io` in the app, §15 D63).
/// Contract: anything that is not one gzip member, or that inflates beyond
/// `maxBytes`, is `PKG_HASH_MISMATCH` — the hash matched, so the target
/// itself is bad.
abstract interface class InflatePayload {
  /// The payload inside [dmpkg].
  Result<List<int>, PackageFailure> call(
    List<int> dmpkg, {
    required int maxBytes,
  });
}
