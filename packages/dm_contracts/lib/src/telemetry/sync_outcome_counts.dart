import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_outcome_counts.freezed.dart';
part 'sync_outcome_counts.g.dart';

/// Package sync outcomes.
@freezed
abstract class SyncOutcomeCounts with _$SyncOutcomeCounts {
  /// Creates a [SyncOutcomeCounts].
  const factory({
    /// Succeeded.
    required int ok,

    /// Succeeded with a warning.
    required int warn,

    /// Failed.
    required int fail,
  }) = _SyncOutcomeCounts;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$SyncOutcomeCountsFromJson(json);
}
