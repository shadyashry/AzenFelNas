import 'dart:typed_data';

import 'package:daily_muslim/features/schedule/domain/runtime_data.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';

/// Reads the active `tzdata`, `tz_polygons`, `country_polygons` and
/// `prayer_profiles` packages into [RuntimeData] (§7.4, §15 D77).
///
/// Each payload is re-hashed by [LoadPackagePayload] (REQ-DIST-003) and
/// parsed by its own reader. A type with no active package is `PKG_STORAGE`
/// (the bundled seeds of REQ-PKG-003 should have provided it); a profile set
/// holding a profile not allowed on [_channel] is `PROFILE_INVALID`
/// (Appendix E), so a release build never calculates with draft data.
final class LoadRuntimeData {
  /// Loads through the catalog and payload loader for [_channel].
  const new({
    required this._catalog,
    required this._load,
    required this._channel,
  });

  final ReadPackageCatalog _catalog;
  final LoadPackagePayload _load;
  final ReleaseChannel _channel;

  /// The runtime data, or the first failure.
  Future<Result<RuntimeData, Failure>> call() async {
    final tzdata = await _payload(PackageType.tzdata);
    final zones = await _payload(PackageType.tzPolygons);
    final countries = await _payload(PackageType.countryPolygons);
    final profiles = await _payload(PackageType.prayerProfiles);
    switch ((tzdata, zones, countries, profiles)) {
      case (
        Ok(value: (final tzVersion, final tzBytes)),
        Ok(value: (_, final zoneBytes)),
        Ok(value: (_, final countryBytes)),
        Ok(value: (_, final profileBytes)),
      ):
        return _parse(
          tzVersion,
          tzBytes,
          zoneBytes,
          countryBytes,
          profileBytes,
        );
      case (Err(:final failure), _, _, _) ||
          (_, Err(:final failure), _, _) ||
          (_, _, Err(:final failure), _) ||
          (_, _, _, Err(:final failure)):
        return Err(failure);
    }
  }

  Result<RuntimeData, Failure> _parse(
    String tzVersion,
    Uint8List tzBytes,
    Uint8List zoneBytes,
    Uint8List countryBytes,
    Uint8List profileBytes,
  ) {
    const readIndex = ReadPolygonIndex();
    final tzdb = const ReadTzfDatabase()(
      tzBytes,
      version: tzVersion.split('.').first,
    );
    final zones = readIndex(zoneBytes, dataset: PolygonDataset.tz);
    final countries = readIndex(countryBytes, dataset: PolygonDataset.country);
    final profiles = const ParseProfileSetPayload()(
      profileBytes,
    ).flatMap((set) => const CheckProfileChannel()(set, _channel));
    return switch ((tzdb, zones, countries, profiles)) {
      (
        Ok(value: final tzdb),
        Ok(value: final zones),
        Ok(value: final countries),
        Ok(value: final profiles),
      ) =>
        Ok(
          RuntimeData(
            tzdb: tzdb,
            zones: zones,
            countries: countries,
            profiles: profiles,
          ),
        ),
      (Err(:final failure), _, _, _) => Err(failure),
      (_, Err(:final failure), _, _) => Err(failure),
      (_, _, Err(:final failure), _) => Err(failure),
      (_, _, _, Err(:final failure)) => Err(failure),
    };
  }

  Future<Result<(String, Uint8List), Failure>> _payload(
    PackageType type,
  ) async {
    final active = await _catalog.active(type);
    if (active == null) {
      return Err(PackageFailure.storage('no active ${type.wire} package'));
    }
    final files = await _catalog.files(type);
    for (final file in files) {
      if (file.version == active.version && file.sha256 == active.sha256) {
        return (await _load(file)).map(
          (bytes) => (active.version, Uint8List.fromList(bytes)),
        );
      }
    }
    return Err(PackageFailure.storage('no stored file for $active'));
  }
}
