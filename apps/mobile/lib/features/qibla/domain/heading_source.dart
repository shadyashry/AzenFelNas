import 'package:daily_muslim/features/qibla/domain/heading_event.dart';

/// The compass port (`HeadingApi`, §7.8): listening starts the sensor,
/// cancelling stops it. The observer's coordinates let the platform convert
/// magnetic to true north (Android `GeomagneticField`); they stay on the
/// device.
abstract interface class HeadingSource {
  /// Compass events until the subscription is cancelled. Never errors: a
  /// failure is a [HeadingUnavailable] event.
  Stream<HeadingEvent> watch({
    required double latitudeDeg,
    required double longitudeDeg,
  });
}
