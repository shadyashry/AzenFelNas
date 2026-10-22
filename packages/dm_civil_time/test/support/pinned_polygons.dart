import 'dart:convert';
import 'dart:io';

import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// A polygon package built by the data pipeline and committed under
/// `data/<package>/<source version>/` (§15 D70). Tests run from the package
/// directory.
final class PinnedPolygons {
  const new _(this.dataset, this.directory);

  /// The single pinned build of [dataset]; fails unless there is one.
  factory load(PolygonDataset dataset) {
    final versions = Directory('data/${packageOf(dataset)}')
        .listSync()
        .whereType<Directory>()
        .toList();
    if (versions.length != 1) {
      throw StateError('expected one ${packageOf(dataset)}, got $versions');
    }
    return PinnedPolygons._(dataset, versions.single);
  }

  /// `tz_polygons` or `country_polygons`.
  static String packageOf(PolygonDataset dataset) => switch (dataset) {
    PolygonDataset.tz => 'tz_polygons',
    PolygonDataset.country => 'country_polygons',
  };

  /// Which package.
  final PolygonDataset dataset;

  /// `data/<package>/<version>`.
  final Directory directory;

  /// The payload read by [ReadPolygonIndex]; fails the test when invalid.
  PolygonIndex get index => switch (const ReadPolygonIndex()(
    File('${directory.path}/${packageOf(dataset)}.bin').readAsBytesSync(),
    dataset: dataset,
  )) {
    Ok(:final value) => value,
    Err(:final failure) => throw StateError('pinned polygons: $failure'),
  };

  /// The decoded `lookup_oracle.json` (schema `polygon_lookup_oracle.v1`).
  Map<String, Object?> get oracle => switch (jsonDecode(
    File('${directory.path}/lookup_oracle.json').readAsStringSync(),
  )) {
    final Map<String, Object?> json => json,
    _ => throw const FormatException('oracle is not an object'),
  };
}
