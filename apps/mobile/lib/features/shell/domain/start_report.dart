import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';

/// What the start-up work did (§7.4): the seeds imported and the garbage
/// collected.
final class StartReport {
  /// The report.
  const new({required this.seeds, required this.garbage});

  /// The bundled seeds imported on this start.
  final SeedImportReport seeds;

  /// The number of package files deleted, or why collection failed.
  final Result<int, PackageFailure> garbage;
}
