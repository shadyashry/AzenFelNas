import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnostic_health.freezed.dart';
part 'diagnostic_health.g.dart';

/// The delivery path the native layer reported (§8.3).
enum DiagnosticDeliveryPath {
  /// Android exact alarm.
  androidExact,

  /// Android inexact fallback.
  androidInexact,

  /// iOS AlarmKit.
  iosAlarmKit,

  /// iOS notifications.
  iosNotification,

  /// No native layer answered.
  unavailable,
}

/// Athan Health state (§8.3) in its camelCase bundle form.
enum DiagnosticHealthState {
  /// Ready.
  ready,

  /// Limited.
  limited,

  /// Not ready.
  notReady,

  /// Unknown.
  unknown,
}

/// `health.json`: the native report and the state Dart derived from it.
@freezed
abstract class DiagnosticHealth with _$DiagnosticHealth {
  /// Creates a [DiagnosticHealth].
  const factory({
    /// Delivery path.
    required DiagnosticDeliveryPath path,

    /// Derived state.
    required DiagnosticHealthState state,

    /// Reason names, in display order.
    required List<String> reasons,

    /// Probes in native order.
    required List<DiagnosticProbe> probes,

    /// UTC epoch ms of the native evaluation.
    required int evaluatedAtUtcMs,
  }) = _DiagnosticHealth;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$DiagnosticHealthFromJson(json);
}

/// One native probe.
@freezed
abstract class DiagnosticProbe with _$DiagnosticProbe {
  /// Creates a [DiagnosticProbe].
  const factory({
    /// Probe name.
    required String name,

    /// The outcome; null when the platform could not tell.
    @JsonKey(includeIfNull: true) required bool? positive,
  }) = _DiagnosticProbe;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$DiagnosticProbeFromJson(json);
}
