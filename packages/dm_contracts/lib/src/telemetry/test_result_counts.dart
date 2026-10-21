import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_result_counts.freezed.dart';
part 'test_result_counts.g.dart';

/// Athan Test outcomes.
@freezed
abstract class TestResultCounts with _$TestResultCounts {
  /// Creates a [TestResultCounts].
  const factory({
    /// Heard.
    required int heard,

    /// Not heard.
    required int notHeard,

    /// Unknown.
    required int unknown,
  }) = _TestResultCounts;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$TestResultCountsFromJson(json);
}
