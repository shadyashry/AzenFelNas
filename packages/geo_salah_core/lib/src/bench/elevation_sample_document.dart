import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/bench/elevation_datum_code.dart';
import 'package:geo_salah_core/src/bench/elevation_source_code.dart';

part 'elevation_sample_document.freezed.dart';
part 'elevation_sample_document.g.dart';

/// Wire form of `ElevationSample` (§6.2) in `bench_request.v1`.
@freezed
abstract class ElevationSampleDocument with _$ElevationSampleDocument {
  /// Creates an [ElevationSampleDocument].
  const factory({
    /// Height in metres above [datum].
    required double valueM,

    /// Vertical datum.
    required ElevationDatumCode datum,

    /// How the value was obtained.
    required ElevationSourceCode source,

    /// When the value was observed, UTC epoch milliseconds.
    required int observedUtcMs,

    /// Vertical accuracy in metres.
    double? verticalAccuracyM,

    /// Dataset version.
    String? datasetVersion,
  }) = _ElevationSampleDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$ElevationSampleDocumentFromJson(json);
}
