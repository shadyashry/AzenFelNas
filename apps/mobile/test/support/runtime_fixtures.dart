import 'dart:io';

import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/context_place.dart';
import 'package:daily_muslim/features/contexts/domain/context_source.dart';
import 'package:daily_muslim/features/contexts/domain/location_context.dart';
import 'package:daily_muslim/features/contexts/domain/location_fix.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:daily_muslim/features/schedule/domain/runtime_data.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';

T _ok<T, F>(Result<T, F> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => throw StateError('$failure'),
};

RuntimeData? _cached;

/// The bundled seed packages read straight from `assets/packages/` (tests
/// run from `apps/mobile`), parsed once per test file.
RuntimeData bundledRuntimeData() => _cached ??= RuntimeData(
  tzdb: _ok(
    const ReadTzfDatabase()(
      File('assets/packages/tzdata/2026e/tzdata.tzf').readAsBytesSync(),
      version: '2026e',
    ),
  ),
  zones: _ok(
    const ReadPolygonIndex()(
      File(
        'assets/packages/tz_polygons/2026e/tz_polygons.bin',
      ).readAsBytesSync(),
      dataset: PolygonDataset.tz,
    ),
  ),
  countries: _ok(
    const ReadPolygonIndex()(
      File(
        'assets/packages/country_polygons/5.1.2/country_polygons.bin',
      ).readAsBytesSync(),
      dataset: PolygonDataset.country,
    ),
  ),
  profiles: _ok(
    const ParseProfileSetPayload()(
      File(
        'assets/packages/prayer_profiles/2026.10.1/profiles.json',
      ).readAsBytesSync(),
    ),
  ),
);

/// A manual context at ([latitudeDeg], [longitudeDeg]) in [zoneId].
ResolvedContext manualContext({
  required double latitudeDeg,
  required double longitudeDeg,
  required String zoneId,
  required String? country,
  String label = 'Test place',
}) => ResolvedContext(
  context: LocationContext(
    id: 1,
    kind: ContextKind.manual,
    place: ContextPlace(
      point: GeoPointE6.fromDegrees(latitudeDeg, longitudeDeg),
      horizontalAccuracyM: null,
      zoneId: zoneId,
      country: country,
      label: label,
    ),
    source: ContextSource.gazetteer,
    createdUtcMs: 0,
    lastUsedUtcMs: 0,
  ),
  flags: const {},
  stale: false,
);

/// Cairo city centre as a manual context.
ResolvedContext cairo() => manualContext(
  latitudeDeg: 30.0444,
  longitudeDeg: 31.2357,
  zoneId: 'Africa/Cairo',
  country: 'EG',
  label: 'Cairo',
);

/// A fresh approximate fix in Cairo at [fixUtcMs].
LocationFix cairoFix({required int fixUtcMs}) => LocationFix(
  point: GeoPointE6(30044420, 31235712),
  horizontalAccuracyM: 1200,
  fixUtcMs: fixUtcMs,
  isMock: false,
);
