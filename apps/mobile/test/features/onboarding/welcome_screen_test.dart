import 'dart:async';

import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/contexts/application/context_use_cases.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:daily_muslim/features/contexts/domain/location_access.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/location_fix.dart';
import 'package:daily_muslim/features/contexts/domain/search_key.dart';
import 'package:daily_muslim/features/onboarding/application/complete_first_run.dart';
import 'package:daily_muslim/features/onboarding/presentation/language_choice.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_controller.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_page.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_view.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/data/drift_settings_store.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/domain/setting_key.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/settings/domain/settings_ports.dart';
import 'package:daily_muslim/features/storage/data/places_database.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';
import '../../support/fake_athan_grant.dart';
import '../../support/fake_location_access.dart';
import '../../support/runtime_fixtures.dart';
import '../../support/state_harness.dart';
import '../contexts/support/fake_device_locator.dart';

final _cairo = GazetteerHit(
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

/// The gazetteer: Cairo answers any prefix of its name.
final class _Places implements FindGazetteerPlaces {
  @override
  Future<Result<List<GazetteerHit>, GazetteerFailure>> findByPrefix(
    SearchKey prefix, {
    required int limit,
  }) async => Ok([if ('cairo'.startsWith(prefix.value)) _cairo]);
}

final class _Settings implements WriteSetting {
  final written = <String, Object?>{};

  @override
  Future<void> write<T>(SettingKey<T> key, T value) async =>
      written[key.wire] = value;
}

/// A regular phone: 390 × 844.
void _phone(WidgetTester tester, {Size size = const Size(390, 844)}) {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  late PlacesDatabase db;
  late FakeAthanGrant grant;
  setUp(() => db = PlacesDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// The onboarding page over fake platform ports.
  Future<FakeLocationAccess> pump(
    WidgetTester tester, {
    LocationAccess access = LocationAccess.denied,
    Result<LocationFix, LocationFailure>? fix,
    Future<Result<ContextUseCases, Failure>>? useCases,
    Locale locale = const Locale('en'),
  }) async {
    final fakeAccess = FakeLocationAccess(access);
    grant = FakeAthanGrant();
    final locator = FakeDeviceLocator()
      ..current = fix ?? Ok(cairoFix(fixUtcMs: harnessNowUtcMs));
    final ready = fakeContextUseCases(
      db: db,
      places: _Places(),
      access: fakeAccess,
      locator: locator,
    );
    await tester.pumpWidget(
      localizedApp(
        const OnboardingPage(),
        overrides: [
          contextUseCasesProvider.overrideWith(
            (ref) => useCases ?? Future.value(Ok(ready)),
          ),
          completeFirstRunProvider.overrideWithValue(
            CompleteFirstRun(_Settings()),
          ),
          requestAthanGrantProvider.overrideWithValue(grant),
        ],
        locale: locale,
      ),
    );
    await tester.pump();
    return fakeAccess;
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  group('REQ-UX-050 language on the welcome screen', () {
    testWidgets('the switch applies at once, persists, and keeps the setup '
        'state', (tester) async {
      _phone(tester);
      final dbs = memoryDatabases();
      await tester.pumpWidget(harnessApp(dbs));
      await pumpUntil(tester, find.text('Use my location'));
      await tester.tap(find.text('Use my location'));
      await pumpUntil(tester, find.text('Location is not available'));

      await tester.tap(find.text('العربية'));
      await pumpUntil(tester, find.text('ابدأ بمواقيت مدينتك'));

      // The failure is still shown, now in Arabic, right to left.
      expect(find.text('الموقع مش متاح'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('ابدأ بمواقيت مدينتك'))),
        TextDirection.rtl,
      );
      final stored = await tester.runAsync(
        () => DriftSettingsStore(dbs.dm).read(AppSettings.locale),
      );
      expect(stored, LocaleSetting.ar);
      await disposeApp(tester, dbs);
    });

    testWidgets('each language is named in its own script and the selected '
        'one is marked for screen readers', (tester) async {
      _phone(tester);
      final semantics = tester.ensureSemantics();
      await pump(tester);
      expect(
        tester.getSemantics(find.bySemanticsLabel('English')),
        matchesSemantics(
          label: 'English',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
        ),
      );
      expect(find.text('العربية'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('REQ-UX-051 Use my location', () {
    testWidgets('asks for location only when tapped, and never for '
        'notifications on the welcome screen', (tester) async {
      _phone(tester);
      final access = await pump(tester, access: LocationAccess.granted);
      expect(access.requests, 0);
      await tester.tap(find.text('Use my location'));
      await pumpUntil(tester, find.text('Your times are ready'));
      expect(access.requests, 1);
      expect(grant.asked, isEmpty);
    });

    testWidgets('one request runs at a time', (tester) async {
      _phone(tester);
      final pending = Completer<Result<ContextUseCases, Failure>>();
      final access = FakeLocationAccess();
      await pump(tester, useCases: pending.future);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(WelcomeView)),
      );
      final controller = container.read(onboardingProvider.notifier);
      unawaited(controller.useApproximateLocation());
      unawaited(controller.useApproximateLocation());
      pending.complete(
        Ok(
          fakeContextUseCases(
            db: db,
            places: _Places(),
            access: access,
            locator: FakeDeviceLocator(),
          ),
        ),
      );
      await pumpUntil(tester, find.text('Location is not available'));
      expect(access.requests, 1);
    });

    for (final (outcome, access, fix, settings, advice) in [
      (
        'denied',
        LocationAccess.denied,
        null,
        'Open settings',
        'Allow location access, or choose a place yourself.',
      ),
      (
        'permanently denied',
        LocationAccess.permanentlyDenied,
        null,
        'Open settings',
        'Allow location access, or choose a place yourself.',
      ),
      (
        'restricted',
        LocationAccess.restricted,
        null,
        'Open settings',
        'Allow location access, or choose a place yourself.',
      ),
      (
        'services off',
        LocationAccess.granted,
        const Err<LocationFix, LocationFailure>(LocationFailure.servicesOff()),
        'Turn on location',
        'Turn on location in the device settings, or choose a place '
            'yourself.',
      ),
      (
        'a timeout or no position',
        LocationAccess.granted,
        const Err<LocationFix, LocationFailure>(
          LocationFailure.unavailable('timeout'),
        ),
        null,
        'Choose your city from the list.',
      ),
    ]) {
      testWidgets('$outcome: the progress stops, the fix is said, a Settings '
          'action only where one helps, and a city can still be chosen', (
        tester,
      ) async {
        _phone(tester);
        await pump(tester, access: access, fix: fix);
        await tester.tap(find.text('Use my location'));
        await pumpUntil(tester, find.text('Location is not available'));
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text(advice), findsOneWidget);
        expect(
          find.text(settings ?? 'Open settings'),
          settings == null ? findsNothing : findsOneWidget,
        );
        await tapVisible(tester, find.text('Choose a city instead'));
        expect(find.byKey(const Key('placeSearch')), findsOneWidget);
      });
    }

    testWidgets('a city chosen while location is found stands', (
      tester,
    ) async {
      _phone(tester);
      final pending = Completer<Result<ContextUseCases, Failure>>();
      await pump(tester, useCases: pending.future);
      await tester.tap(find.text('Use my location'));
      await tester.pump();
      await tapVisible(tester, find.text('Choose a city instead'));
      pending.complete(
        Ok(
          fakeContextUseCases(
            db: db,
            places: _Places(),
            access: FakeLocationAccess(),
            locator: FakeDeviceLocator(),
          ),
        ),
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump();
      }
      expect(find.byKey(const Key('placeSearch')), findsOneWidget);
      expect(find.text('Location is not available'), findsNothing);
    });
  });

  group('REQ-UX-052 the city picker', () {
    Future<void> search(WidgetTester tester, String query) async {
      await pump(tester);
      await tapVisible(tester, find.text('Choose a city instead'));
      expect(find.text('Where do you pray?'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('placeSearch')), query);
      await tester.testTextInput.receiveAction(TextInputAction.search);
    }

    testWidgets('finds a city with its country, marks the one chosen, and '
        'stores it only on Use this city', (tester) async {
      _phone(tester);
      await search(tester, 'Cai');
      await pumpUntil(tester, find.widgetWithText(ListTile, 'Cairo'));
      expect(find.textContaining('EG'), findsOneWidget);
      final confirm = find.byKey(const Key('cityPickerConfirm'));
      expect(
        tester
            .widget<TextButton>(
              find.descendant(
                of: confirm,
                matching: find.byType(TextButton),
              ),
            )
            .onPressed,
        isNull,
      );

      await tester.tap(find.widgetWithText(ListTile, 'Cairo'));
      await tester.pump();
      expect(tester.widget<ListTile>(find.byType(ListTile)).selected, isTrue);
      expect(find.text('Your times are ready'), findsNothing);

      await tester.tap(confirm);
      await pumpUntil(tester, find.text('Your times are ready'));
      expect(find.text('Prayer times for Cairo.'), findsOneWidget);
    });

    testWidgets('says when no city matches', (tester) async {
      _phone(tester);
      await search(tester, 'Zzz');
      await pumpUntil(tester, find.text('No matching cities'));
    });

    testWidgets('back returns to the welcome screen', (tester) async {
      _phone(tester);
      await pump(tester);
      await tester.tap(find.text('Choose a city instead'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('cityPickerBack')));
      await tester.pump();
      expect(find.text('Let’s make it local.'), findsOneWidget);
    });

    testWidgets('stays usable with the keyboard open on a short window', (
      tester,
    ) async {
      _phone(tester, size: const Size(844, 390));
      await search(tester, 'Cai');
      await pumpUntil(tester, find.widgetWithText(ListTile, 'Cairo'));
      // The keyboard takes 300 of the 390 units.
      tester.view.viewInsets = const FakeViewPadding(bottom: 900);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump();
      final list = find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.widgetWithText(ListTile, 'Cairo'),
        40,
        scrollable: list,
      );
      await tapVisible(tester, find.widgetWithText(ListTile, 'Cairo'));
      final confirm = find.byKey(const Key('cityPickerConfirm'));
      await tester.scrollUntilVisible(confirm, 40, scrollable: list);
      await tapVisible(tester, confirm);
      await pumpUntil(tester, find.text('Your times are ready'));
    });
  });

  testWidgets('REQ-UX-053 a returning user opens on Home, never on the '
      'welcome screen', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final dbs = memoryDatabases();
    final locator = FakeDeviceLocator()
      ..current = Ok(cairoFix(fixUtcMs: harnessNowUtcMs));
    Widget app() => harnessApp(
      dbs,
      locator: locator,
      locationAccess: FakeLocationAccess(LocationAccess.granted),
    );
    await tester.pumpWidget(app());
    await pumpUntil(tester, find.text('Use my location'));
    await tester.tap(find.text('Use my location'));
    await pumpUntil(tester, find.text('Your times are ready'));
    await tester.tap(find.text("Show today's times"));
    await pumpUntil(tester, find.byType(TimeRow));

    // The app is closed and opened again over the same storage.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
    await tester.pumpWidget(app());
    await pumpUntil(tester, find.byType(TimeRow));
    expect(find.byType(WelcomeView), findsNothing);
    expect(find.text('Let’s make it local.'), findsNothing);
    await disposeApp(tester, dbs);
  });

  group('REQ-UX-054 the welcome screen fits the window', () {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      for (final size in const [
        Size(320, 568),
        Size(360, 800),
        Size(390, 844),
        Size(430, 932),
        Size(768, 1024),
        Size(844, 390),
      ]) {
        testWidgets('${size.width.round()} × ${size.height.round()} '
            '(${locale.languageCode}): nothing overflows and every action '
            'can be reached', (tester) async {
          _phone(tester, size: size);
          await pump(tester, locale: locale);
          for (final key in const [
            Key('onboardingDetect'),
            Key('onboardingChooseCity'),
          ]) {
            await tester.ensureVisible(find.byKey(key));
            await tester.pump();
            final box = tester.getRect(find.byKey(key));
            expect(box.height, greaterThanOrEqualTo(54));
            expect(box.width, lessThanOrEqualTo(480));
          }
        });
      }
    }

    testWidgets('a regular phone shows the 112-unit logo', (tester) async {
      _phone(tester);
      await pump(tester);
      expect(tester.getSize(find.byType(Image)), const Size(112, 112));
    });

    testWidgets('large text shrinks the logo and spacing first, never the '
        'text', (tester) async {
      _phone(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await pump(tester);
      expect(tester.getSize(find.byType(Image)).width, lessThan(112));
      final eyebrow = tester.renderObject<RenderParagraph>(
        find.text('A moment of peace, every day'),
      );
      expect(eyebrow.textScaler.scale(12), 24);
    });

    for (final (locale, heroFirst) in const [
      (Locale('en'), true),
      (Locale('ar'), false),
    ]) {
      testWidgets('landscape puts the hero on the leading side '
          '(${locale.languageCode})', (tester) async {
        _phone(tester, size: const Size(844, 390));
        await pump(tester, locale: locale);
        final hero = tester.getCenter(find.byType(LanguageChoice));
        final action = tester.getCenter(
          find.byKey(const Key('onboardingDetect')),
        );
        expect(hero.dx < action.dx, heroFirst);
      });
    }
  });
}
