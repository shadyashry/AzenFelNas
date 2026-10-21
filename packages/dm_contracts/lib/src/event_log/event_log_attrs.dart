import 'package:dm_contracts/src/event_log/failure_code_converter.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_log_attrs.freezed.dart';
part 'event_log_attrs.g.dart';

/// Closed allow-list of event attributes: no coordinate key exists (REQ-
/// PRIV-001).
@freezed
abstract class EventLogAttrs with _$EventLogAttrs {
  /// Creates a [EventLogAttrs].
  const factory({
    /// Failure code.
    @FailureCodeConverter() FailureCode? code,

    /// Plan generation.
    int? generation,

    /// Plan entry id.
    String? entryId,

    /// Package type.
    String? packageType,

    /// Version.
    String? version,

    /// State name.
    String? state,

    /// Reason code.
    String? reason,

    /// Duration in ms.
    int? durationMs,

    /// Count.
    int? count,

    /// IANA zone.
    String? zoneId,

    /// ISO 3166-1 alpha-2.
    String? countryCode,
  }) = _EventLogAttrs;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$EventLogAttrsFromJson(json);
}
