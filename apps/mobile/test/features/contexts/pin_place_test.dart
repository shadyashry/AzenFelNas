import 'package:daily_muslim/features/contexts/application/follow_device_location.dart';
import 'package:daily_muslim/features/contexts/application/pin_place.dart';
import 'package:daily_muslim/features/contexts/application/resolve_observer_context.dart';
import 'package:daily_muslim/features/contexts/application/select_context.dart';
import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/context_place.dart';
import 'package:daily_muslim/features/contexts/domain/context_source.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/place_choice.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/places_fixtures.dart';
import 'support/resolver_harness.dart';

ResolvedContext _ok(Result<ResolvedContext, LocationFailure> result) =>
    switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => fail('$failure'),
    };

void main() {
  late ResolverHarness h;
  late PinPlace pin;
  late ResolveObserverContext resolve;

  setUp(() {
    h = ResolverHarness();
    pin = PinPlace(
      clock: h.clock,
      read: h.store,
      write: h.store,
      resolvePlace: h.resolvePlace,
    );
    resolve = ResolveObserverContext(h.store, h.locate, h.resolvePlace);
  });

  test('REQ-PRIV-002 a gazetteer choice becomes the active manual context '
      'with the gazetteer zone and country', () async {
    final hit = GazetteerHit(
      id: 104515,
      name: 'Mecca',
      matchedName: 'مكة',
      exact: true,
      country: 'SA',
      admin1: '14',
      point: makkahPlace.point,
      population: 1323624,
      zoneId: 'Asia/Riyadh',
    );
    final pinned = _ok(await pin(GazetteerChoice(hit)));
    expect(pinned.context.kind, ContextKind.manual);
    expect(pinned.context.source, ContextSource.gazetteer);
    expect(pinned.context.place, makkahPlace);

    h.locator.current = Ok(fixAt(cairoPlace.point));
    expect(_ok(await resolve()).context, pinned.context);
  });

  test('typed coordinates are resolved through the polygons', () async {
    final typed = _ok(
      await pin(TypedCoordinates(londonPlace.point, label: 'Office')),
    );
    expect(typed.context.place.zoneId, 'Europe/London');
    expect(typed.context.place.country, 'GB');
    expect(typed.context.place.label, 'Office');
    expect(typed.context.place.horizontalAccuracyM, isNull);
    expect(typed.context.source, ContextSource.typedCoordinates);
  });

  test('REQ-PRIV-002 pinning keeps the current place while the device '
      'moves on', () async {
    h.locator.current = Ok(fixAt(cairoPlace.point));
    final current = _ok(await resolve()).context;
    final pinned = _ok(await pin(const PinCurrentLocation(label: 'Home')));
    expect(pinned.context.kind, ContextKind.pinned);
    expect(
      pinned.context.place,
      ContextPlace(
        point: current.place.point,
        horizontalAccuracyM: current.place.horizontalAccuracyM,
        zoneId: 'Africa/Cairo',
        country: 'EG',
        label: 'Home',
      ),
    );

    h
      ..clock.utcMs += 1
      ..locator.current = Ok(fixAt(londonPlace.point));
    expect(_ok(await resolve()).context, pinned.context);
  });

  test(
    'pinning without a current context fails with LOC_UNAVAILABLE',
    () async {
      final result = await pin(const PinCurrentLocation(label: 'Home'));
      expect(
        switch (result) {
          Err(:final failure) => failure.code,
          Ok() => null,
        },
        FailureCode.locUnavailable,
      );
      expect(h.store.rows, isEmpty);
    },
  );

  test('the user changes a chosen context back to the device location and '
      'selects it again; the chosen row is never altered', () async {
    final manual = _ok(
      await pin(TypedCoordinates(makkahPlace.point, label: 'مكة')),
    ).context;
    h
      ..clock.utcMs += 1
      ..locator.current = Ok(fixAt(cairoPlace.point));
    final followed = _ok(await FollowDeviceLocation(h.locate)());
    expect(followed.context.kind, ContextKind.current);
    expect(_ok(await resolve()).context.kind, ContextKind.current);

    h.clock.utcMs += 1;
    final selected = _ok(
      await SelectContext(h.clock, h.store, h.resolvePlace)(manual.id),
    );
    expect(selected.context.place, manual.place);
    expect(selected.context.lastUsedUtcMs, h.clock.utcMs);
    expect(_ok(await resolve()).context.id, manual.id);
  });
}
