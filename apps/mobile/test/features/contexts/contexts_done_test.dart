import 'dart:convert';
import 'dart:io';

import 'package:daily_muslim/features/contexts/application/follow_device_location.dart';
import 'package:daily_muslim/features/contexts/application/locate_observer.dart';
import 'package:daily_muslim/features/contexts/application/pin_place.dart';
import 'package:daily_muslim/features/contexts/application/resolve_observer_context.dart';
import 'package:daily_muslim/features/contexts/application/resolve_place.dart';
import 'package:daily_muslim/features/contexts/data/drift_location_context_store.dart';
import 'package:daily_muslim/features/contexts/data/event_log_context_events.dart';
import 'package:daily_muslim/features/contexts/domain/context_changed.dart';
import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/location_context.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/place_choice.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:daily_muslim/features/storage/data/places_database.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import 'support/fake_device_locator.dart';
import 'support/recording_events.dart';
import 'support/resolver_harness.dart';
import 'support/settable_clock.dart';

/// The pinned S11 polygons, read through the production reader.
PolygonIndex _pinned(PolygonDataset dataset, String path) =>
    switch (const ReadPolygonIndex()(
      File('../../packages/dm_civil_time/data/$path').readAsBytesSync(),
      dataset: dataset,
    )) {
      Ok(:final value) => value,
      Err(:final failure) => throw StateError('$failure'),
    };

ResolvedContext _ok(Result<ResolvedContext, LocationFailure> result) =>
    switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => fail('$failure'),
    };

/// S13 done-test (§13): REQ-PRIV-002 against the real resolvers, pinned
/// polygons and the drift store, with the mock location recorded.
void main() {
  final resolvePlace = ResolvePlace(
    ResolveZone(
      _pinned(PolygonDataset.tz, 'tz_polygons/2026e/tz_polygons.bin'),
    ),
    ResolveCountry(
      _pinned(
        PolygonDataset.country,
        'country_polygons/5.1.2/country_polygons.bin',
      ),
    ),
  );
  late PlacesDatabase db;
  late DriftLocationContextStore store;
  late FakeDeviceLocator device;
  late RecordingEvents events;
  late SettableClock clock;
  late LocateObserver locate;
  late ResolveObserverContext resolve;
  late PinPlace pin;

  setUp(() {
    db = PlacesDatabase(NativeDatabase.memory());
    store = DriftLocationContextStore(db);
    device = FakeDeviceLocator();
    events = RecordingEvents();
    clock = SettableClock(noonUtcMs);
    locate = LocateObserver(
      clock: clock,
      locator: device,
      read: store,
      write: store,
      resolvePlace: resolvePlace,
      events: events,
    );
    resolve = ResolveObserverContext(store, locate, resolvePlace);
    pin = PinPlace(
      clock: clock,
      read: store,
      write: store,
      resolvePlace: resolvePlace,
    );
  });
  tearDown(() => db.close());

  test('S13 REQ-PRIV-002 a manual place survives fresh fixes in other '
      'zones; the mock fix is recorded and changes nothing else', () async {
    final cairo = GeoPointE6.fromDegrees(30.0444, 31.2357);
    final makkah = GeoPointE6.fromDegrees(21.4225, 39.8262);
    final london = GeoPointE6.fromDegrees(51.5074, -0.1278);

    device.current = Ok(fixAt(cairo));
    final current = _ok(await resolve());
    expect(
      (current.context.kind, current.context.place.zoneId),
      (ContextKind.current, 'Africa/Cairo'),
    );
    expect(current.context.place.country, 'EG');

    clock.utcMs += 1;
    final manual = _ok(
      await pin(TypedCoordinates(makkah, label: 'مكة المكرمة')),
    );
    expect(manual.context.place.zoneId, 'Asia/Riyadh');
    expect(manual.context.place.country, 'SA');

    for (final (point, mock) in [(london, true), (cairo, false)]) {
      clock.utcMs += 60000;
      device.current = Ok(fixAt(point, isMock: mock));
      expect(_ok(await resolve()).context, manual.context);
    }
    expect(
      await store.active(),
      Ok<LocationContext?, LocationFailure>(manual.context),
    );

    // The resolver never read a fix while the manual place was active; the
    // mock fix is recorded once the user follows the device location again.
    expect(
      events.entries.where((e) => e.reason == ContextChangeReason.mockLocation),
      isEmpty,
    );
    device.current = Ok(fixAt(london, isMock: true));
    final followed = _ok(await FollowDeviceLocation(locate)());
    expect(followed.context.place.zoneId, 'Europe/London');
    expect(followed.context.place.country, 'GB');
    expect(followed.context.id, current.context.id);
    final mock = EventLogContextEvents.entryOf(
      events.entries.singleWhere(
        (e) => e.reason == ContextChangeReason.mockLocation,
      ),
    );
    expect(mock.level, EventLogLevel.warn);
    expect(mock.code, EventCode.contextChanged);
    expect(jsonEncode(mock.toJson()), isNot(contains('51.5')));

    final rows = await db.select(db.locationContexts).get();
    expect(rows.where((r) => r.pinned).single.zoneId, 'Asia/Riyadh');
    expect(_ok(await resolve()).context.place.zoneId, 'Europe/London');
    expect(manual.flags, isNot(contains(ResultFlag.noLocalProfile)));
  });
}
