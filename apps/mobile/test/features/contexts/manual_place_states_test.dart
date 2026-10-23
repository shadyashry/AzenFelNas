import 'dart:async';

import 'package:daily_muslim/features/contexts/application/context_use_cases.dart';
import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:daily_muslim/features/contexts/domain/search_key.dart';
import 'package:daily_muslim/features/contexts/presentation/manual_place_view.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/storage/data/places_database.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';
import '../../support/fake_location_access.dart';
import '../../support/state_harness.dart';
import 'support/fake_device_locator.dart';

final _alexandria = GazetteerHit(
  id: 361058,
  name: 'Alexandria',
  matchedName: 'Alexandria',
  exact: true,
  country: 'EG',
  admin1: 'Alexandria',
  point: GeoPointE6(31200092, 29918739),
  population: 3811516,
  zoneId: 'Africa/Cairo',
);

final class _Places implements FindGazetteerPlaces {
  new(this.answer);

  final Result<List<GazetteerHit>, GazetteerFailure> answer;

  @override
  Future<Result<List<GazetteerHit>, GazetteerFailure>> findByPrefix(
    SearchKey prefix, {
    required int limit,
  }) async => answer;
}

void main() {
  late PlacesDatabase db;
  setUp(() => db = PlacesDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<List<ResolvedContext>> pump(
    WidgetTester tester, {
    Result<List<GazetteerHit>, GazetteerFailure> answer = const Ok([]),
    Future<Result<ContextUseCases, Failure>>? useCases,
  }) async {
    final pinned = <ResolvedContext>[];
    final ready = fakeContextUseCases(
      db: db,
      places: _Places(answer),
      access: FakeLocationAccess(),
      locator: FakeDeviceLocator(),
    );
    await tester.pumpWidget(
      localizedApp(
        Scaffold(body: ManualPlaceView(onPinned: pinned.add)),
        overrides: [
          contextUseCasesProvider.overrideWith(
            (ref) => useCases ?? Future.value(Ok(ready)),
          ),
        ],
      ),
    );
    await tester.pump();
    return pinned;
  }

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byKey(const Key('placeSearch')), query);
    await tester.testTextInput.receiveAction(TextInputAction.search);
  }

  group('Manual place UiState (§18.4) — every variant renders', () {
    testWidgets('idle invites a search', (tester) async {
      await pump(tester);
      expect(find.text('Search the offline list of cities.'), findsOneWidget);
    });

    testWidgets('searching shows progress', (tester) async {
      await pump(
        tester,
        useCases: Completer<Result<ContextUseCases, Failure>>().future,
      );
      await search(tester, 'Alex');
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('results list the places', (tester) async {
      await pump(tester, answer: Ok([_alexandria]));
      await search(tester, 'Alex');
      await pumpUntil(tester, find.widgetWithText(ListTile, 'Alexandria'));
      expect(find.text('Alexandria · EG'), findsOneWidget);
    });

    testWidgets('empty suggests another spelling or coordinates', (
      tester,
    ) async {
      await pump(tester);
      await search(tester, 'Zzz');
      await pumpUntil(tester, find.textContaining('No place found'));
    });

    testWidgets('REQ-ERR-002 error names the failure code', (tester) async {
      await pump(
        tester,
        answer: const Err(GazetteerFailure.storage('disk')),
      );
      await search(tester, 'Alex');
      await pumpUntil(tester, find.textContaining('PKG_STORAGE'));
    });

    testWidgets('coordinateEntry refuses out-of-range numbers', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.text('Enter coordinates'));
      await tester.pump();
      expect(find.byKey(const Key('placeLatitude')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('placeLatitude')), '95');
      await tester.enterText(find.byKey(const Key('placeLongitude')), '10');
      await tester.tap(find.text('Use this place'));
      await pumpUntil(tester, find.textContaining('Latitude from -90'));
    });
  });

  group('Pinning (REQ-PRIV-002)', () {
    testWidgets('REQ-PRIV-002 a search hit becomes a manual context with the '
        'gazetteer zone and label', (tester) async {
      final pinned = await pump(tester, answer: Ok([_alexandria]));
      await search(tester, 'Alex');
      await pumpUntil(tester, find.widgetWithText(ListTile, 'Alexandria'));
      await tester.tap(find.widgetWithText(ListTile, 'Alexandria'));
      for (var i = 0; i < 100 && pinned.isEmpty; i++) {
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pump();
      }
      final context = pinned.single.context;
      expect(context.kind, ContextKind.manual);
      expect(context.place.zoneId, 'Africa/Cairo');
      expect(context.place.label, 'Alexandria');
    });

    testWidgets('REQ-PRIV-002 typed coordinates become a manual context '
        'resolved by the polygons', (tester) async {
      final pinned = await pump(tester);
      await tester.tap(find.text('Enter coordinates'));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('placeLatitude')), '30.0444');
      await tester.enterText(
        find.byKey(const Key('placeLongitude')),
        '31.2357',
      );
      await tester.enterText(find.byKey(const Key('placeName')), 'Home');
      await tester.tap(find.text('Use this place'));
      for (var i = 0; i < 100 && pinned.isEmpty; i++) {
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pump();
      }
      final place = pinned.single.context.place;
      expect(pinned.single.context.kind, ContextKind.manual);
      expect(place.zoneId, 'Africa/Cairo');
      expect(place.country, 'EG');
      expect(place.label, 'Home');
    });
  });
}
