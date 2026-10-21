import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/bench/elevation_sample_document.dart';
import 'package:geo_salah_core/src/bench/observer_source_code.dart';

part 'bench_observer_document.freezed.dart';
part 'bench_observer_document.g.dart';

/// Wire form of `Observer` (§6.2) in `bench_request.v1`.
@freezed
abstract class BenchObserverDocument with _$BenchObserverDocument {
  /// Creates a [BenchObserverDocument].
  const factory({
    /// Latitude, degrees north.
    required double latitudeDeg,

    /// Longitude, degrees east.
    required double longitudeDeg,

    /// IANA zone id.
    required String zoneId,

    /// Where the position came from.
    required ObserverSourceCode source,

    /// Horizontal accuracy in metres.
    double? horizontalAccuracyM,

    /// Elevation (provenance only, ADR-003).
    ElevationSampleDocument? elevation,
  }) = _BenchObserverDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$BenchObserverDocumentFromJson(json);
}
