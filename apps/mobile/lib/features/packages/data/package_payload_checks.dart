import 'dart:typed_data';

import 'package:daily_muslim/features/contexts/data/json_gazetteer_payload_decoder.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';

/// [CheckPayload] with each type's own reader: the payload must decode
/// exactly as the runtime will read it (§7.4 "schema"). A type without a
/// reader in this build is `PKG_INCOMPATIBLE`; `AppCompat` keeps such types
/// out of downloads in the first place.
final class PackagePayloadChecks implements CheckPayload {
  /// The checks.
  const new();

  @override
  Result<void, PackageFailure> call(
    PackageType type,
    String version,
    int schemaVersion,
    List<int> payload,
  ) {
    final bytes = Uint8List.fromList(payload);
    final refusal = switch (type) {
      PackageType.gazetteer => switch (const JsonGazetteerPayloadDecoder()
          .decode(payload)) {
        Ok() => null,
        Err(:final failure) => '$failure',
      },
      PackageType.tzdata => switch (const ReadTzfDatabase()(
        bytes,
        version: version.split('.').first,
      )) {
        Ok() => null,
        Err(:final failure) => '$failure',
      },
      PackageType.tzPolygons => _polygons(bytes, PolygonDataset.tz),
      PackageType.countryPolygons => _polygons(bytes, PolygonDataset.country),
      PackageType.prayerProfiles ||
      PackageType.hijri ||
      PackageType.athanAudioManifest => 'no ${type.wire} reader in this build',
    };
    return refusal == null
        ? const Result.ok(null)
        : Result.err(PackageFailure.incompatible('${type.wire}: $refusal'));
  }

  static String? _polygons(Uint8List bytes, PolygonDataset dataset) =>
      switch (const ReadPolygonIndex()(bytes, dataset: dataset)) {
        Ok() => null,
        Err(:final failure) => '$failure',
      };
}
