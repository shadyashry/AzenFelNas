import 'package:daily_muslim/features/contexts/application/locate_observer.dart';
import 'package:daily_muslim/features/contexts/application/resolve_place.dart';
import 'package:daily_muslim/features/contexts/domain/location_fix.dart';
import 'package:dm_civil_time/dm_civil_time.dart';

import 'fake_device_locator.dart';
import 'fake_location_context_store.dart';
import 'places_fixtures.dart';
import 'recording_events.dart';
import 'settable_clock.dart';
import 'table_polygons.dart';

/// 2026-10-22T12:00:00Z.
const noonUtcMs = 1792670400000;

/// The contexts feature wired to fakes at its ports only; zone and country
/// come from the real resolvers over table polygons.
final class ResolverHarness {
  /// Fresh fakes; the clock reads [noonUtcMs].
  new()
    : clock = SettableClock(noonUtcMs),
      locator = FakeDeviceLocator(),
      store = FakeLocationContextStore(),
      events = RecordingEvents(),
      resolvePlace = ResolvePlace(
        ResolveZone(
          TablePolygons({
            cairoPlace.point: const InsidePolygon(
              'Africa/Cairo',
              otherDistanceM: null,
            ),
            makkahPlace.point: const InsidePolygon(
              'Asia/Riyadh',
              otherDistanceM: null,
            ),
            londonPlace.point: const InsidePolygon(
              'Europe/London',
              otherDistanceM: 4000,
            ),
          }),
        ),
        ResolveCountry(
          TablePolygons({
            cairoPlace.point: const InsidePolygon('EG', otherDistanceM: null),
            makkahPlace.point: const InsidePolygon('SA', otherDistanceM: null),
            londonPlace.point: const InsidePolygon('GB', otherDistanceM: null),
          }),
        ),
      );

  /// The clock.
  final SettableClock clock;

  /// The device.
  final FakeDeviceLocator locator;

  /// The context store.
  final FakeLocationContextStore store;

  /// The diagnostic log.
  final RecordingEvents events;

  /// Zone and country resolution.
  final ResolvePlace resolvePlace;

  /// The device-location chain over these fakes.
  LocateObserver get locate => LocateObserver(
    clock: clock,
    locator: locator,
    read: store,
    write: store,
    resolvePlace: resolvePlace,
    events: events,
  );
}

/// A fix at [point], [ageMs] old at [noonUtcMs].
LocationFix fixAt(
  GeoPointE6 point, {
  double accuracyM = 1000,
  int ageMs = 0,
  bool isMock = false,
}) => LocationFix(
  point: point,
  horizontalAccuracyM: accuracyM,
  fixUtcMs: noonUtcMs - ageMs,
  isMock: isMock,
);
