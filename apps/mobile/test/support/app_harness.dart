import 'dart:io';

import 'package:daily_muslim/app/daily_muslim_app.dart';
import 'package:daily_muslim/app/di.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:daily_muslim/features/storage/data/opened_databases.dart';
import 'package:daily_muslim/features/storage/data/places_database.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/contexts/support/fake_device_locator.dart';
import 'fake_location_access.dart';

/// 2026-10-22T09:00:00Z.
const harnessNowUtcMs = 1792659600000;

/// Both databases in memory.
OpenedDatabases memoryDatabases() => OpenedDatabases(
  dm: DmDatabase(NativeDatabase.memory()),
  places: PlacesDatabase(NativeDatabase.memory()),
  placesExcludedFromBackup: true,
);

/// The real app with the real bindings over [databases], the test asset
/// bundle and a fixed clock.
Widget harnessApp(
  OpenedDatabases databases, {
  String initialLocation = '/',
  Directory? blobRoot,
  LocateDevice? locator,
  RequestLocationAccess? locationAccess,
  Clock? clock,
}) => ProviderScope(
  overrides: AppBindings.of(
    databases: databases,
    assets: rootBundle,
    clock: clock ?? FixedClock(harnessNowUtcMs),
    blobRoot: blobRoot ?? Directory.systemTemp.createTempSync('dm_blobs'),
    locator: locator ?? FakeDeviceLocator(),
    locationAccess: locationAccess ?? FakeLocationAccess(),
  ),
  child: DailyMuslimApp(initialLocation: initialLocation),
);

/// Unmounts the app so drift's stream timers fire inside the fake clock, then
/// closes [databases] on the real event loop.
Future<void> disposeApp(WidgetTester tester, OpenedDatabases databases) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
  await tester.runAsync(databases.close);
}

/// Pumps, letting database work finish on the real event loop between
/// frames, until [finder] matches; fails after [attempts] rounds.
Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  int attempts = 200,
}) async {
  for (var i = 0; i < attempts; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
    await tester.pump(const Duration(milliseconds: 16));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('not found after $attempts rounds: $finder');
}
