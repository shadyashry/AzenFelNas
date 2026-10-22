import 'dart:convert';
import 'dart:math';

import 'package:daily_muslim/features/contexts/application/resolve_observer_context.dart';
import 'package:daily_muslim/features/contexts/data/event_log_context_events.dart';
import 'package:daily_muslim/features/contexts/domain/context_changed.dart';
import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/context_source.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import 'support/places_fixtures.dart';
import 'support/resolver_harness.dart';

const int _minute = 60 * 1000;

ResolvedContext _ok(Result<ResolvedContext, LocationFailure> result) =>
    switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => fail('$failure'),
    };

FailureCode? _code(Result<ResolvedContext, LocationFailure> result) =>
    switch (result) {
      Err(:final failure) => failure.code,
      Ok() => null,
    };

void main() {
  late ResolverHarness h;
  late ResolveObserverContext resolve;

  setUp(() {
    h = ResolverHarness();
    resolve = ResolveObserverContext(h.store, h.locate, h.resolvePlace);
  });

  group('REQ-PRIV-002 pinned and manual contexts are never replaced', () {
    test('an active manual place is returned as stored despite a fresh '
        'fix elsewhere', () async {
      await h.store.addChosen(
        ChosenKind.manual,
        makkahPlace,
        ContextSource.gazetteer,
        utcMs: 1,
      );
      final before = h.store.rows;
      h.locator.current = Ok(fixAt(londonPlace.point));

      final resolved = _ok(await resolve());

      expect(resolved.context.place, makkahPlace);
      expect(resolved.context.kind, ContextKind.manual);
      expect(resolved.offerPreciseLocation, isFalse);
      expect(h.store.rows, before);
      expect(h.events.entries, isEmpty);
    });

    test('random sequences of fixes and resolver runs leave every chosen '
        'row unchanged', () async {
      final random = Random(13);
      final points = [cairoPlace, londonPlace, oceanPlace, makkahPlace];
      for (var round = 0; round < 50; round++) {
        h = ResolverHarness();
        resolve = ResolveObserverContext(h.store, h.locate, h.resolvePlace);
        await h.store.saveCurrent(
          cairoPlace,
          ContextSource.freshFix,
          utcMs: 1,
        );
        await h.store.addChosen(
          random.nextBool() ? ChosenKind.pinned : ChosenKind.manual,
          points[random.nextInt(points.length)],
          ContextSource.typedCoordinates,
          utcMs: 2 + random.nextInt(2),
        );
        final chosen = h.store.rows.where((c) => c.kind.isUserChosen).toList();
        for (var step = 0; step < 10; step++) {
          h.locator.current = Ok(
            fixAt(
              points[random.nextInt(points.length)].point,
              accuracyM: random.nextDouble() * 8000,
              ageMs: random.nextInt(30) * _minute,
              isMock: random.nextBool(),
            ),
          );
          final resolved = _ok(await resolve());
          expect(resolved.context, chosen.single);
        }
        expect(h.store.rows.where((c) => c.kind.isUserChosen), chosen);
      }
    });
  });

  group('current context: fresh fix → last known → manual prompt (§7.5)', () {
    test('a fresh fix within 15 min and 5 000 m becomes the current '
        'context with its zone and country', () async {
      h.locator.current = Ok(fixAt(cairoPlace.point, ageMs: 15 * _minute));

      final resolved = _ok(await resolve());

      expect(resolved.context.kind, ContextKind.current);
      expect(resolved.context.source, ContextSource.freshFix);
      expect(resolved.context.place.zoneId, 'Africa/Cairo');
      expect(resolved.context.place.country, 'EG');
      expect(resolved.stale, isFalse);
      expect(resolved.flags, isEmpty);
    });

    test('a coarse or old fresh fix falls back to a last known fix, '
        'flagged stale', () async {
      h.locator
        ..current = Ok(fixAt(londonPlace.point, accuracyM: 5001))
        ..lastKnown = Ok(fixAt(cairoPlace.point, ageMs: 23 * 60 * _minute));
      var resolved = _ok(await resolve());
      expect(resolved.context.source, ContextSource.lastKnownFix);
      expect(resolved.context.place.zoneId, 'Africa/Cairo');
      expect(resolved.stale, isTrue);

      h.locator.current = Ok(fixAt(londonPlace.point, ageMs: 16 * _minute));
      resolved = _ok(await resolve());
      expect(resolved.stale, isTrue);
    });

    test('no acceptable fix asks for a manual place with the reason', () async {
      h.locator
        ..current = const Err(LocationFailure.permissionDenied())
        ..lastKnown = Ok(fixAt(cairoPlace.point, ageMs: 24 * 60 * _minute + 1));
      expect(_code(await resolve()), FailureCode.locPermissionDenied);

      h.locator.current = Ok(fixAt(cairoPlace.point, ageMs: 16 * _minute));
      expect(_code(await resolve()), FailureCode.locUnavailable);
      expect(h.store.rows, isEmpty);
    });

    test('near a tz boundary the precise-location offer is made', () async {
      h.locator.current = Ok(fixAt(londonPlace.point));
      final resolved = _ok(await resolve());
      expect(resolved.flags, {ResultFlag.zoneBoundaryProximity});
      expect(resolved.offerPreciseLocation, isTrue);
    });

    test('no polygon gives the nautical zone, no country and '
        'noLocalProfile', () async {
      h.locator.current = Ok(fixAt(oceanPlace.point));
      final resolved = _ok(await resolve());
      expect(resolved.context.place.zoneId, 'Etc/GMT+1');
      expect(resolved.context.place.country, isNull);
      expect(resolved.flags, {
        ResultFlag.manualCoordinateResolution,
        ResultFlag.noLocalProfile,
      });
    });
  });

  group('mock location is recorded in diagnostics only (§7.5)', () {
    test('REQ-PRIV-001 a mock fix resolves like a real one and adds one '
        'coordinate-free event', () async {
      h.locator.current = Ok(fixAt(cairoPlace.point, isMock: true));
      final mocked = _ok(await resolve());

      final real = ResolverHarness()
        ..locator.current = Ok(fixAt(cairoPlace.point));
      final unmocked = _ok(
        await ResolveObserverContext(
          real.store,
          real.locate,
          real.resolvePlace,
        )(),
      );

      expect(mocked, unmocked);
      final mockEvents = h.events.entries.where(
        (e) => e.reason == ContextChangeReason.mockLocation,
      );
      expect(mockEvents, [
        const ContextChanged(
          utcMs: noonUtcMs,
          reason: ContextChangeReason.mockLocation,
          zoneId: 'Africa/Cairo',
          country: 'EG',
        ),
      ]);
      expect(
        real.events.entries.where(
          (e) => e.reason == ContextChangeReason.mockLocation,
        ),
        isEmpty,
      );
      final wire = jsonEncode([
        for (final e in h.events.entries)
          EventLogContextEvents.entryOf(e).toJson(),
      ]);
      expect(wire, isNot(contains('30.04')));
      expect(wire, isNot(contains('31.23')));
    });

    test('a zone or country change is logged once, a repeat is not', () async {
      h.locator.current = Ok(fixAt(cairoPlace.point));
      await resolve();
      await resolve();
      h.locator.current = Ok(fixAt(londonPlace.point));
      await resolve();
      expect(
        [for (final e in h.events.entries) e.zoneId],
        ['Africa/Cairo', 'Europe/London'],
      );
    });
  });
}
