import 'package:dm_packages/src/client/active_package.dart';
import 'package:dm_packages/src/client/package_file.dart';
import 'package:dm_packages/src/client/package_type.dart';

/// Reads the package catalog (§7.3 `active_packages`, `package_files`).
///
/// Contract: reads never fail; an empty store answers null or empty lists.
/// Lists are ordered by type wire name, then version (byte order).
abstract interface class ReadPackageCatalog {
  /// The active version of [type]; null before its first activation.
  Future<ActivePackage?> active(PackageType type);

  /// Every active package.
  Future<List<ActivePackage>> activeAll();

  /// Every stored file of [type], in any state.
  Future<List<PackageFile>> files(PackageType type);

  /// Every `garbage` file whose state was set at or before [utcMs].
  Future<List<PackageFile>> garbageBefore(int utcMs);
}
