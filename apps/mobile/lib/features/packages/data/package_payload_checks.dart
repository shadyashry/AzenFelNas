import 'dart:isolate';
import 'dart:typed_data';

import 'package:daily_muslim/features/contexts/data/json_gazetteer_payload_decoder.dart';
import 'package:daily_muslim/features/packages/domain/run_payload_work.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';

/// [CheckPayload] with each type's own reader: the payload must decode
/// exactly as the runtime will read it (§7.4 "schema"). A type without a
/// reader in this build is `PKG_INCOMPATIBLE`; `AppCompat` keeps such types
/// out of downloads in the first place. Each check runs through
/// [RunPayloadWork], a background isolate by default, so decoding a large
/// payload never freezes the UI (§15 D96).
final class PackagePayloadChecks implements CheckPayload {
  /// The checks over [_run].
  const new({this._run = Isolate.run});

  final RunPayloadWork _run;

  @override
  Future<Result<void, PackageFailure>> call(
    PackageType type,
    String version,
    int schemaVersion,
    List<int> payload,
  ) async {
    final bytes = Uint8List.fromList(payload);
    final refusal = await _run(() => _refusal(type, version, bytes));
    return refusal == null
        ? const Result.ok(null)
        : Result.err(PackageFailure.incompatible('${type.wire}: $refusal'));
  }

  /// Why [bytes] is not a valid [type] [version] payload, or null.
  static String? _refusal(PackageType type, String version, Uint8List bytes) =>
      switch (type) {
        PackageType.gazetteer => switch (JsonGazetteerPayloadDecoder.decodeNow(
          bytes,
        )) {
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
        PackageType.prayerProfiles => switch (const ParseProfileSetPayload()(
          bytes,
        )) {
          Ok() => null,
          Err(:final failure) => failure.detail,
        },
        PackageType.hijri || PackageType.athanAudioManifest =>
          'no ${type.wire} reader in this build',
      };

  static String? _polygons(Uint8List bytes, PolygonDataset dataset) =>
      switch (const ReadPolygonIndex()(bytes, dataset: dataset)) {
        Ok() => null,
        Err(:final failure) => '$failure',
      };
}
