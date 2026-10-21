import 'package:geo_salah_core/src/astro/topocentric_site.dart';

import 'fake_tz_database.dart';

/// A test observer: Appendix H coordinates with the zone's standard offset
/// (DST is irrelevant to the properties these tests check).
typedef TestCity = ({String zoneId, TopocentricSite site, int offsetSeconds});

TestCity _city(String zoneId, double lat, double lon, double offsetHours) => (
  zoneId: zoneId,
  site: TopocentricSite.of(latitudeDeg: lat, longitudeDeg: lon),
  offsetSeconds: (offsetHours * 3600).round(),
);

/// A spread of Appendix H cities: equatorial, mid-latitude, polar, and zones
/// far from their solar time (Kiritimati UTC+14 at 157° W, Suva near the date
/// line).
final List<TestCity> testCities = [
  _city('Asia/Riyadh', 21.42, 39.83, 3),
  _city('Africa/Cairo', 30.04, 31.24, 2),
  _city('Europe/London', 51.51, -0.13, 0),
  _city('Europe/Oslo', 59.91, 10.75, 1),
  _city('Arctic/Longyearbyen', 78.22, 15.63, 1),
  _city('Europe/Tromso', 69.65, 18.96, 1),
  _city('America/Anchorage', 71.29, -156.79, -9),
  _city('America/Guayaquil', -0.18, -78.47, -5),
  _city('Pacific/Kiritimati', 1.87, -157.43, 14),
  _city('Pacific/Fiji', -18.14, 178.44, 12),
  _city('America/Argentina/Ushuaia', -54.80, -68.30, -3),
  _city('Australia/Sydney', -33.87, 151.21, 10),
];

/// The fake time-zone port for [testCities].
final FakeTzDatabase testTzdb = FakeTzDatabase({
  for (final city in testCities) city.zoneId: city.offsetSeconds,
});
