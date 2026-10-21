import 'package:dm_contracts/src/snapshot/sky_phase_code.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sky_segment.freezed.dart';
part 'sky_segment.g.dart';

/// Start of a sky phase.
@freezed
abstract class SkySegment with _$SkySegment {
  /// Creates a [SkySegment].
  const factory({
    /// Phase start.
    required int fromUtcMs,

    /// Phase.
    required SkyPhaseCode phase,
  }) = _SkySegment;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$SkySegmentFromJson(json);
}
