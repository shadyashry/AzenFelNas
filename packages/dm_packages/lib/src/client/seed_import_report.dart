import 'package:dm_packages/src/client/active_package.dart';
import 'package:dm_packages/src/client/package_type.dart';
import 'package:dm_packages/src/verify/package_failure.dart';
import 'package:meta/meta.dart';

/// What `ImportBundledSeeds` did.
@immutable
final class SeedImportReport {
  /// The report.
  new({
    required List<ActivePackage> imported,
    required Map<PackageType, PackageFailure> failures,
  }) : imported = List.unmodifiable(imported),
       failures = Map.unmodifiable(failures);

  /// The seeds that became active.
  final List<ActivePackage> imported;

  /// The seeds that could not be imported; the type keeps what it had.
  final Map<PackageType, PackageFailure> failures;
}
