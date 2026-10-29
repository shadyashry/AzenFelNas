import 'dart:async';

import 'package:daily_muslim/features/athan/domain/athan_grant.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/contexts/application/context_use_cases.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:daily_muslim/features/contexts/domain/location_access.dart';
import 'package:daily_muslim/features/contexts/domain/search_key.dart';
import 'package:daily_muslim/features/onboarding/application/complete_first_run.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_controller.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_page.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/domain/setting_key.dart';
import 'package:daily_muslim/features/settings/domain/settings_ports.dart';
import 'package:daily_muslim/features/storage/data/places_database.dart';
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
      expect(find.text('Prayer times for where you are'), findsOneWidget);
      expect(access.requests, 0);
    });

    testWidgets('the welcome step offers approximate location or a place, '
        'one tap from the times (§15 D98)', (tester) async {
      final (access, _) = await pump(tester);
      expect(find.text('Use approximate location'), findsOneWidget);
      expect(find.text('Choose a place'), findsOneWidget);
      expect(access.requests, 0);
    });

    testWidgets('step(place) shows the manual place search', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Choose a place'));
      await tester.pump();
      expect(find.byKey(const Key('placeSearch')), findsOneWidget);
    });

    testWidgets('resolving shows progress while the place is found', (
      tester,
    ) async {
      await pump(
        tester,
        useCases: Completer<Result<ContextUseCases, Failure>>().future,
      );
      await tester.tap(find.text('Use approximate location'));
      await tester.pump();
      expect(find.text('Finding your place…'), findsOneWidget);
    });

    testWidgets('REQ-ERR-002 failed keeps the code for support (long press) '
        'and offers the manual-place branch (§18.3, §15 D98)', (tester) async {
      final (access, _) = await pump(tester);
      await tester.tap(find.text('Use approximate location'));
      await pumpUntil(tester, find.text('Location is not available'));
      expect(access.requests, 1);
      expect(find.textContaining('LOC_PERMISSION_DENIED'), findsNothing);
      expect(find.byTooltip('Code LOC_PERMISSION_DENIED'), findsOneWidget);
      expect(find.text('Choose a place'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('REQ-ALM-026 step(done) after a granted fix; finishing asks '
        'for notifications and exact alarms and completes the first run', (
      tester,
    ) async {
      final (_, settings) = await pump(tester, access: LocationAccess.granted);
      await tester.tap(find.text('Use approximate location'));
      await pumpUntil(tester, find.text('Your times are ready'));
      await tester.tap(find.text("Show today's times"));
      await pumpUntil(tester, find.text('Your times are ready'));
      for (var i = 0; i < 20 && settings.written.isEmpty; i++) {
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pump();
      }
      expect(settings.written, {'onboardingComplete': true});
      expect(grant.asked, [AthanGrant.notifications, AthanGrant.exactAlarms]);
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
