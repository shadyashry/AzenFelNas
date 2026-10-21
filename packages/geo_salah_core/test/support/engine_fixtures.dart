import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import 'bench_profile_files.dart';
import 'sites.dart';

/// A Hijri state for engine tests. Shape test data: no S06 event reads it
/// (Ramadan rules arrive in S08); it only enters the Calculation ID.
const HijriState testHijri = HijriState(
  dateAtDawn: HijriDate(year: 1447, month: 10, day: 1),
  dateAtNight: HijriDate(year: 1447, month: 10, day: 2),
  confidence: HijriConfidence.expected,
);

/// The `engine.default` bench stand-in, read from its data file (§15 D48).
final PrayerProfile testProfile = readEngineDefault();

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
  PrayerProfile? profile,
  TzDatabase? tzdb,
}) => switch (const CalculateDay()(
  observer: observerOf(city),
  profile: profile ?? testProfile,
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
