import 'package:geo_salah_core/geo_salah_core.dart';

/// Maps an engine [PrayerEvent] to its wire name in plans and snapshots.
abstract final class PlanEventCode {
  /// The wire code of [event].
  static PrayerEventCode of(PrayerEvent event) => switch (event) {
    PrayerEvent.imsak => PrayerEventCode.imsak,
    PrayerEvent.fajr => PrayerEventCode.fajr,
    PrayerEvent.sunrise => PrayerEventCode.sunrise,
    PrayerEvent.dhuhr => PrayerEventCode.dhuhr,
    PrayerEvent.asr => PrayerEventCode.asr,
    PrayerEvent.maghrib => PrayerEventCode.maghrib,
    PrayerEvent.isha => PrayerEventCode.isha,
  };
}
