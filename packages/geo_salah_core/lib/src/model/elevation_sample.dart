import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/model/elevation_datum.dart';
import 'package:geo_salah_core/src/model/elevation_source.dart';

part 'elevation_sample.freezed.dart';

/// An observer's elevation (§6.2). Recorded in provenance only: no
/// calculation reads it (ADR-003).
@freezed
abstract class ElevationSample with _$ElevationSample {
  /// Creates an [ElevationSample].
  const factory({
    /// Height in metres above [datum].
    required double valueM,

    /// Vertical datum of [valueM].
    required ElevationDatum datum,

    /// How the value was obtained.
    required ElevationSource source,

    /// When the value was observed, UTC epoch milliseconds.
    required int observedUtcMs,

    /// One-sigma vertical accuracy in metres, when known.
    double? verticalAccuracyM,

    /// Version of the dataset the value came from, when any.
    String? datasetVersion,
  }) = _ElevationSample;
}
