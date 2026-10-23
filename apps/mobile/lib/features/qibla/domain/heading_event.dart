import 'package:meta/meta.dart';

/// One message from the device compass (`HeadingApi`, §7.8).
sealed class HeadingEvent {
  const new();
}

/// A compass sample.
@immutable
final class HeadingReading extends HeadingEvent {
  /// Creates a [HeadingReading].
  const new({required this.trueHeadingDeg, required this.accuracyDeg});

  /// Device heading, degrees clockwise from **true** north, `[0, 360)`
  /// (iOS `CLHeading.trueHeading`; Android rotation vector + the OS
  /// `GeomagneticField` declination); `null` while true north is not known.
  final double? trueHeadingDeg;

  /// Estimated error, degrees; `null` when the platform does not know.
  final double? accuracyDeg;

  @override
  bool operator ==(Object other) =>
      other is HeadingReading &&
      other.trueHeadingDeg == trueHeadingDeg &&
      other.accuracyDeg == accuracyDeg;

  @override
  int get hashCode => Object.hash(trueHeadingDeg, accuracyDeg);
}

/// The device has no usable compass (no sensor, or the platform refused).
@immutable
final class HeadingUnavailable extends HeadingEvent {
  const new();

  @override
  bool operator ==(Object other) => other is HeadingUnavailable;

  @override
  int get hashCode => (HeadingUnavailable).hashCode;
}
