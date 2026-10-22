import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// Stores downloaded `.dmpkg` files by relative path. Contract: `write`
/// replaces atomically (a reader sees the old or the new bytes, never a
/// part); `read` of a missing path and every I/O error is `PKG_STORAGE`;
/// `delete` of a missing path succeeds.
abstract interface class StorePackageBlobs {
  /// Writes [bytes] at [path].
  Future<Result<void, PackageFailure>> write(String path, List<int> bytes);

  /// The bytes at [path].
  Future<Result<List<int>, PackageFailure>> read(String path);

  /// Deletes [path].
  Future<Result<void, PackageFailure>> delete(String path);
}
