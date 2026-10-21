import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/bench/bench_observer_document.dart';
import 'package:geo_salah_core/src/trace/trace_hijri_inputs_document.dart';

part 'bench_request_document.freezed.dart';
part 'bench_request_document.g.dart';

/// One stdin line of the engine bench, `bench_request.v1` (§15 D29).
@freezed
abstract class BenchRequestDocument with _$BenchRequestDocument {
  /// Creates a [BenchRequestDocument].
  const factory({
    /// Schema version; 1.
    required int schemaVersion,

    /// The observer.
    required BenchObserverDocument observer,

    /// Prayer profile id.
    required String profileId,

    /// Prayer day, `YYYY-MM-DD` in the observer's zone.
    required String day,

    /// Hijri state of the day; echoed as the trace's `inputs.hijri`.
    required TraceHijriInputsDocument hijri,
  }) = _BenchRequestDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$BenchRequestDocumentFromJson(json);
}
