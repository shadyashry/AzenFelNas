import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/bench/bench_profiles.dart';

import 'sites.dart';

/// A Hijri state for engine tests. Shape test data: S05 events do not read
/// it; it only enters the Calculation ID.
const HijriState testHijri = HijriState(
  dateAtDawn: HijriDate(year: 1447, month: 10, day: 1),
  dateAtNight: HijriDate(year: 1447, month: 10, day: 2),
  confidence: HijriConfidence.expected,
);

/// The S05 `engine.default` stand-in (sunrise and maghrib horizon rules,
/// dhuhr transit, all at their §6.2 defaults).
const PrayerProfile testProfile = BenchProfiles.engineDefault;

/// The observer of [city].
Observer observerOf(TestCity city) => Observer(
  latitudeDeg: city.site.latitudeDeg,
  longitudeDeg: city.site.longitudeDeg,
  zoneId: city.zoneId,
  source: ObserverSource.benchmark,
);

/// [CalculateDay] for [city] on [day] with [profile], expecting success.
DayResult calculateOk(
  TestCity city,
  CivilDate day, {
  PrayerProfile profile = testProfile,
  TzDatabase? tzdb,
}) => switch (const CalculateDay()(
  observer: observerOf(city),
  profile: profile,
  day: day,
  tzdb: tzdb ?? testTzdb,
  hijri: testHijri,
)) {
  Ok(:final value) => value,
  Err(:final failure) => throw StateError('Unexpected $failure'),
};

/// The time of [event] in [result].
PrayerTime timeOf(DayResult result, PrayerEvent event) =>
    result.times.singleWhere((time) => time.event == event);

/// The test city in [zoneId].
TestCity cityIn(String zoneId) =>
    testCities.singleWhere((city) => city.zoneId == zoneId);
