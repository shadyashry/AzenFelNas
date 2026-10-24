import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnostic_device.freezed.dart';
part 'diagnostic_device.g.dart';

/// Operating system family.
enum DiagnosticOs {
  /// Android.
  android,

  /// iOS.
  ios,

  /// Linux (tests and desktop builds).
  linux,

  /// macOS.
  macos,

  /// Windows.
  windows,

  /// Fuchsia.
  fuchsia,
}

/// `device.json`: no identifier, only what support needs to reproduce.
@freezed
abstract class DiagnosticDevice with _$DiagnosticDevice {
  /// Creates a [DiagnosticDevice].
  const factory({
    /// Device model; null until a source exists (§15 D84).
    @JsonKey(includeIfNull: true) required String? model,

    /// OS family.
    required DiagnosticOs os,

    /// App version.
    required String appVersion,
  }) = _DiagnosticDevice;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$DiagnosticDeviceFromJson(json);
}
