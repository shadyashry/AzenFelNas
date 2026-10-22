import 'package:daily_muslim/features/contexts/application/import_gazetteer.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';

/// [ApplyPackage] for this build: a `gazetteer` payload fills the
/// `gazetteer` table through [ImportGazetteer] (§7.3); the other types are
/// read from their active file at run time and need no step.
final class ImportingApplyPackage implements ApplyPackage {
  /// Applies gazetteer payloads with [_importGazetteer].
  const new(this._importGazetteer);

  final ImportGazetteer _importGazetteer;

  @override
  Future<Result<void, PackageFailure>> call(
    PackageType type,
    String version,
    List<int> payload,
  ) async => switch (type) {
    PackageType.gazetteer => switch (await _importGazetteer(payload)) {
      Ok() => const Result.ok(null),
      Err(:final failure) => Result.err(
        PackageFailure.storage('gazetteer: ${failure.detail}'),
      ),
    },
    PackageType.prayerProfiles ||
    PackageType.tzdata ||
    PackageType.tzPolygons ||
    PackageType.countryPolygons ||
    PackageType.hijri ||
    PackageType.athanAudioManifest => const Result.ok(null),
  };
}
