import 'package:daily_muslim/features/qibla/domain/heading_event.dart';
import 'package:daily_muslim/features/qibla/domain/heading_source.dart';
import 'package:daily_muslim/features/qibla/domain/qibla_state.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// The Qibla screen's state over time (§6.6, §18.4): the bearing from
/// [CalculateQibla] combined with the compass.
///
/// A sample is trusted only with a true-north heading and an accuracy of at
/// most [readyAccuracyDeg]; otherwise the user is asked to calibrate. No
/// compass gives the number alone.
final class ObserveHeading {
  /// The use case over [_source].
  const new(this._source);

  final HeadingSource _source;

  /// Largest compass error, degrees, at which the arrow is shown — a sensor
  /// quality bar, not a religious tolerance (§15 D78).
  static const double readyAccuracyDeg = 15;

  static const CalculateQibla _qibla = CalculateQibla();

  /// The states for [observer], starting with [QiblaNoHeading].
  Stream<QiblaState> call(Observer observer) async* {
    final qibla = _qibla(observer);
    yield QiblaNoHeading(qibla);
    await for (final event in _source.watch(
      latitudeDeg: observer.latitudeDeg,
      longitudeDeg: observer.longitudeDeg,
    )) {
      yield switch (event) {
        HeadingUnavailable() => QiblaNumericOnly(qibla),
        HeadingReading(
          trueHeadingDeg: final double heading,
          accuracyDeg: final double accuracy,
        )
            when accuracy <= readyAccuracyDeg =>
          QiblaReady(qibla, headingDeg: heading, accuracyDeg: accuracy),
        HeadingReading(:final trueHeadingDeg, :final accuracyDeg) =>
          QiblaCalibrating(qibla, accuracyDeg, headingDeg: trueHeadingDeg),
      };
      if (event is HeadingUnavailable) return;
    }
  }
}
