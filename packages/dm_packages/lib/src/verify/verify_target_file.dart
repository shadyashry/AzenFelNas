import 'package:crypto/crypto.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/tuf/tuf_target.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// Checks a downloaded package against its verified target entry: exact
/// length and SHA-256 (REQ-DIST-003). Pure.
final class VerifyTargetFile {
  /// The use case.
  const new();

  /// [target] when [bytes] are its package, otherwise `PKG_HASH_MISMATCH`.
  Result<TufTarget, PackageFailure> call(
    String name,
    TufTarget target,
    List<int> bytes,
  ) {
    if (bytes.length != target.length ||
        sha256.convert(bytes).toString() != target.sha256) {
      return Result.err(
        PackageFailure.hashMismatch('$name does not match its target entry'),
      );
    }
    return Result.ok(target);
  }
}
