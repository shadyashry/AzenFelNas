import 'package:dm_core_types/dm_core_types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/bench/failure_code_converter.dart';

part 'bench_failure_detail_document.freezed.dart';
part 'bench_failure_detail_document.g.dart';

/// The `failure` object of `bench_failure.v1`.
@freezed
abstract class BenchFailureDetailDocument with _$BenchFailureDetailDocument {
  /// Creates a [BenchFailureDetailDocument].
  const factory({
    /// Appendix J code (REQ-ERR-002).
    @FailureCodeConverter() required FailureCode code,

    /// One-line detail; never coordinates (REQ-PRIV-001).
    String? detail,
  }) = _BenchFailureDetailDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$BenchFailureDetailDocumentFromJson(json);
}
