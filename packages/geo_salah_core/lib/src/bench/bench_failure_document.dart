import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/bench/bench_failure_detail_document.dart';

part 'bench_failure_document.freezed.dart';
part 'bench_failure_document.g.dart';

/// The bench's answer to a request that yields a typed failure,
/// `bench_failure.v1` (§15 D29).
@freezed
abstract class BenchFailureDocument with _$BenchFailureDocument {
  /// Creates a [BenchFailureDocument].
  const factory({
    /// Schema version; 1.
    required int schemaVersion,

    /// The failure.
    required BenchFailureDetailDocument failure,
  }) = _BenchFailureDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$BenchFailureDocumentFromJson(json);
}
