import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/package_type.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// The per-type step that runs before the pointer flips, such as filling the
/// `gazetteer` table (§7.3). Contract: on a failure the type's previous data
/// is still in use, and the pointer is not moved; a type without such a step
/// succeeds at once.
abstract interface class ApplyPackage {
  /// Applies [payload], [type] [version].
  Future<Result<void, PackageFailure>> call(
    PackageType type,
    String version,
    List<int> payload,
  );
}
