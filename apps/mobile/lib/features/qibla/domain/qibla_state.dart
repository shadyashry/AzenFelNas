import 'package:geo_salah_core/geo_salah_core.dart';

/// The Qibla UiState (§18.4). Every variant carries the bearing, so the
/// number is always on screen (§15 D78).
sealed class QiblaState {
  const new(this.qibla);

  /// The bearing to the Kaaba from the active place.
  final QiblaResult qibla;
}

/// No compass sample yet.
final class QiblaNoHeading extends QiblaState {
  const new(super.qibla);
}

/// The compass reports poor or unknown accuracy, or no true north yet:
/// calibration guidance. With a heading the dial still turns with the phone
/// (§15 D97): most phones report a coarse accuracy, and a dial that never
/// moves reads as broken.
final class QiblaCalibrating extends QiblaState {
  /// [accuracyDeg] is `null` when unknown; [headingDeg] when the compass
  /// gives true north.
  const new(super.qibla, this.accuracyDeg, {this.headingDeg});

  /// Estimated compass error, degrees, or `null`.
  final double? accuracyDeg;

  /// Device heading from true north, degrees, or `null`.
  final double? headingDeg;
}

/// A trustworthy sample: the arrow points to the Qibla.
final class QiblaReady extends QiblaState {
  /// Creates a [QiblaReady].
  const new(super.qibla, {required this.headingDeg, required this.accuracyDeg});

  /// Device heading from true north, degrees.
  final double headingDeg;

  /// Estimated compass error, degrees.
  final double accuracyDeg;

  /// Clockwise turn from the device heading to the Qibla, `(-180, 180]`.
  double get turnDeg {
    final d = (qibla.bearingDeg - headingDeg) % 360;
    return d > 180 ? d - 360 : d;
  }
}

/// No usable compass: the bearing as a number only.
final class QiblaNumericOnly extends QiblaState {
  const new(super.qibla);
}
