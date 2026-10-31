import 'dart:async';

import 'package:daily_muslim/features/athan/domain/athan_grant.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/contexts/application/context_use_cases.dart';
import 'package:daily_muslim/features/contexts/domain/device_zone.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:daily_muslim/features/contexts/domain/location_access.dart';
import 'package:daily_muslim/features/contexts/domain/search_key.dart';
import 'package:daily_muslim/features/onboarding/application/complete_first_run.dart';
import 'package:daily_muslim/features/onboarding/presentation/language_choice.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_controller.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_page.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/domain/setting_key.dart';
import 'package:daily_muslim/features/settings/domain/settings_ports.dart';
import 'package:daily_muslim/features/storage/data/places_database.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';
import '../../support/fake_athan_grant.dart';
import '../../support/fake_location_access.dart';
import '../../support/runtime_fixtures.dart';
import '../../support/state_harness.dart';
import '../contexts/support/fake_device_locator.dart';

final class _Settings implements WriteSetting {
  final written = <String, Object?>{};

  @override
  Future<void> write<T>(SettingKey<T> key, T value) async =>
      written[key.wire] = value;
}

void main() {
  late PlacesDatabase db;
  late FakeAthanGrant grant;
  setUp(() => db = PlacesDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<(FakeLocationAccess, _Settings)> pump(
    WidgetTester tester, {
    LocationAccess access = LocationAccess.denied,
    Future<Result<ContextUseCases, Failure>>? useCases,
    FindPlacesAround around = const NoPlacesAround(),
    ReadDeviceZone zone = const FakeDeviceZone(null),
    Locale locale = const Locale('en'),
  }) async {
    final fakeAccess = FakeLocationAccess(access);
    grant = FakeAthanGrant();
    final settings = _Settings();
    final locator = FakeDeviceLocator()
      ..current = Ok(cairoFix(fixUtcMs: harnessNowUtcMs));
    final ready = fakeContextUseCases(
      db: db,
      places: _NoPlaces(),
      access: fakeAccess,
      locator: locator,
      around: around,
      deviceZone: zone,
    );
    await tester.pumpWidget(
      localizedApp(
        const OnboardingPage(),
        overrides: [
          contextUseCasesProvider.overrideWith(
            (ref) => useCases ?? Future.value(Ok(ready)),
          ),
          completeFirstRunProvider.overrideWithValue(
            CompleteFirstRun(settings),
          ),
          requestAthanGrantProvider.overrideWithValue(grant),
        ],
        locale: locale,
      ),
    );
    await tester.pump();
    return (fakeAccess, settings);
  }

  group('Onboarding UiState (§18.4) — every variant renders', () {
    testWidgets('step(welcome) explains offline use and asks for nothing', (
      tester,
    ) async {
      final (access, _) = await pump(tester);
      expect(find.text('Let’s make it local.'), findsOneWidget);
      expect(find.text('Works offline'), findsOneWidget);
      expect(access.requests, 0);
    });

    testWidgets('the welcome step finds the place in one tap, or lets the '
        'user choose a city (§15 D98, D100)', (tester) async {
      final (access, _) = await pump(tester);
      expect(find.text('Use my location'), findsOneWidget);
      expect(find.text('Choose a city instead'), findsOneWidget);
      expect(access.requests, 0);
    });

    testWidgets('step(place) shows the city search', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Choose a city instead'));
      await tester.pump();
      expect(find.byKey(const Key('placeSearch')), findsOneWidget);
    });

    testWidgets('resolving shows progress on the action while the place is '
        'found', (tester) async {
      await pump(
        tester,
        useCases: Completer<Result<ContextUseCases, Failure>>().future,
      );
      await tester.tap(find.text('Use my location'));
      await tester.pump();
      expect(
        find.descendant(
          of: find.byKey(const Key('onboardingDetect')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
    });

    testWidgets('REQ-ERR-002 failed keeps the code for support (long press) '
        'and offers the manual-place branch (§18.3, §15 D98)', (tester) async {
      final (access, _) = await pump(tester);
      await tester.tap(find.text('Use my location'));
      await pumpUntil(tester, find.text('Location is not available'));
      expect(access.requests, 1);
      expect(find.textContaining('LOC_PERMISSION_DENIED'), findsNothing);
      expect(find.byTooltip('Code LOC_PERMISSION_DENIED'), findsOneWidget);
      expect(find.text('Choose a city instead'), findsOneWidget);
      expect(find.text('Use my location'), findsOneWidget);
    });

    testWidgets('REQ-ALM-026 step(done) after a granted fix: Set up prayer '
        'alerts asks for notifications and exact alarms and keeps setup open; '
        'View today\u2019s prayer times completes the first run', (
      tester,
    ) async {
      final (_, settings) = await pump(tester, access: LocationAccess.granted);
      await tester.tap(find.text('Use my location'));
      await pumpUntil(tester, find.byKey(const Key('setupDone')));
      await pumpUntil(tester, find.text('Set up prayer alerts'));
      await tester.tap(find.text('Set up prayer alerts'));
      for (var i = 0; i < 20 && grant.asked.length < 2; i++) {
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pump();
      }
      expect(grant.asked, [AthanGrant.notifications, AthanGrant.exactAlarms]);
      expect(settings.written, isEmpty);
      await tester.tap(find.text('View today’s prayer times'));
      for (var i = 0; i < 20 && settings.written.isEmpty; i++) {
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pump();
      }
      expect(settings.written, {'onboardingComplete': true});
      expect(grant.asked, hasLength(2));
    });
  });

  group('Finding the place without asking for it (§15 D100)', () {
    final cairo = GazetteerHit(
      id: 360630,
      name: 'Cairo',
      matchedName: 'Cairo',
      exact: false,
      country: 'EG',
      admin1: '11',
      point: GeoPointE6(30062630, 31249670),
      population: 9606916,
      zoneId: 'Africa/Cairo',
      arabicName: 'القاهرة',
    );

    testWidgets('a granted fix is named after the place it is in', (
      tester,
    ) async {
      await pump(
        tester,
        access: LocationAccess.granted,
        around: FakePlacesAround(nearby: cairo),
      );
      await tester.tap(find.text('Use my location'));
      await pumpUntil(tester, find.byKey(const Key('setupDone')));
      expect(find.text('Cairo'), findsOneWidget);
    });

    testWidgets('when location fails, the phone time zone offers its city '
        'and one tap uses it', (tester) async {
      await pump(
        tester,
        around: FakePlacesAround(zone: 'Africa/Cairo', inZone: [cairo]),
        zone: const FakeDeviceZone('Africa/Cairo'),
      );
      await tester.tap(find.text('Use my location'));
      await pumpUntil(tester, find.text('Location is not available'));
      expect(
        find.text("Your phone's time zone suggests Cairo."),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('onboardingUseSuggestion')));
      await pumpUntil(tester, find.byKey(const Key('setupDone')));
      expect(find.text('Cairo'), findsOneWidget);
    });

    testWidgets('with no zone city the failure offers the city list first', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.text('Use my location'));
      await pumpUntil(tester, find.text('Location is not available'));
      expect(find.byKey(const Key('onboardingUseSuggestion')), findsNothing);
      expect(find.text('Choose a city instead'), findsOneWidget);
    });

    testWidgets('REQ-UX-030 the header mirrors in Arabic while the actions '
        'keep their place (§15 D126)', (tester) async {
      // Wide enough that the test font keeps the header on one line.
      tester.view.physicalSize = const Size(1440, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      Future<(Rect, Rect)> layout(Locale locale) async {
        await pump(tester, locale: locale);
        return (
          tester.getRect(find.byType(LanguageChoice)),
          tester.getRect(find.byKey(const Key('onboardingDetect'))),
        );
      }

      final width =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final (englishChoice, englishAction) = await layout(const Locale('en'));
      final (arabicChoice, arabicAction) = await layout(const Locale('ar'));
      expect(englishChoice.right, greaterThan(width - 30));
      expect(arabicChoice.left, lessThan(30));
      // Full width in both: the taller Arabic lines may move it down.
      expect(
        (arabicAction.left, arabicAction.right),
        (englishAction.left, englishAction.right),
      );
    });
  });
}

final class _NoPlaces implements FindGazetteerPlaces {
  @override
  Future<Result<List<GazetteerHit>, GazetteerFailure>> findByPrefix(
    SearchKey prefix, {
    required int limit,
  }) async => const Ok([]);
}
