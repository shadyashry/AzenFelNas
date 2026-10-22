import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/active_package.dart';
import 'package:dm_packages/src/client/package_file.dart';
import 'package:dm_packages/src/client/package_type.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// Changes the package catalog. Every method is one transaction: on a
/// failure nothing changed and the last-known-good stays active
/// (REQ-PKG-001). Failures are `PKG_STORAGE`, or as documented.
abstract interface class WritePackageCatalog {
  /// Stores [file] (upsert by type and version).
  Future<Result<void, PackageFailure>> record(PackageFile file);

  /// Makes [next] the active version of its type, with [file] (state
  /// `active`). The version active before becomes `previous` and is named
  /// in `next.previousVersion` by the caller; an older `previous` becomes
  /// `garbage`. Refuses with `PKG_SEQUENCE_REGRESSION` when `next.sequence`
  /// is below the active one (downgrade-safe pointer, §7.3).
  Future<Result<void, PackageFailure>> activate(
    ActivePackage next,
    PackageFile file,
  );

  /// Makes the `previous` version of [type] active again, under the active
  /// sequence, and the active one `garbage`, at [utcMs]. Returns the new
  /// pointer. `PKG_STORAGE` when there is no previous version.
  Future<Result<ActivePackage, PackageFailure>> rollBack(
    PackageType type,
    int utcMs,
  );

  /// Removes the row of [file]; removing a missing row succeeds.
  Future<Result<void, PackageFailure>> forget(PackageFile file);
}
