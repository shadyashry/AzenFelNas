import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/package_type.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// Checks a payload against its type's schema before activation (§7.4:
/// "verify sha256 + schema + compat"). Contract: a payload the type's reader
/// refuses is `PKG_INCOMPATIBLE`; checking has no side effect.
abstract interface class CheckPayload {
  /// Whether [payload] is a valid [type] [version] payload of
  /// [schemaVersion].
  Result<void, PackageFailure> call(
    PackageType type,
    String version,
    int schemaVersion,
    List<int> payload,
  );
}
