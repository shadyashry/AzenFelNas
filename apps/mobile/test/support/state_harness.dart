import 'package:daily_muslim/features/contexts/application/context_use_cases.dart';
import 'package:daily_muslim/features/contexts/application/follow_device_location.dart';
import 'package:daily_muslim/features/contexts/application/locate_observer.dart';
import 'package:daily_muslim/features/contexts/application/locate_with_permission.dart';
import 'package:daily_muslim/features/contexts/application/name_nearest_place.dart';
import 'package:daily_muslim/features/contexts/application/pin_place.dart';
import 'package:daily_muslim/features/contexts/application/resolve_observer_context.dart';
import 'package:daily_muslim/features/contexts/application/resolve_place.dart';
import 'package:daily_muslim/features/contexts/application/search_gazetteer.dart';
import 'package:daily_muslim/features/contexts/application/suggest_places.dart';
import 'package:daily_muslim/features/contexts/data/drift_location_context_store.dart';
import 'package:daily_muslim/features/contexts/domain/context_changed.dart';
import 'package:daily_muslim/features/contexts/domain/device_zone.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/storage/data/places_database.dart';
import 'package:daily_muslim/features/travel/application/handle_zone_change.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import 'app_harness.dart';
import 'runtime_fixtures.dart';

/// [home] in a localised app with the display settings and the clock fixed,
/// plus [overrides]; no router, databases or platform.
Widget localizedApp(
  Widget home, {
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
  DigitsSetting digits = DigitsSetting.locale,
}) => ProviderScope(
  overrides: [
    clockProvider.overrideWithValue(FixedClock(harnessNowUtcMs)),
    nowUtcMsProvider.overrideWith((ref) => Stream.value(harnessNowUtcMs)),
    digitsSettingProvider.overrideWith((ref) => Stream.value(digits)),
    reducedMotionSettingProvider.overrideWith((ref) => Stream.value(true)),
    ...overrides,
  ],
  child: MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  ),
);

/// The real location use cases over [db] with fake ports: [places] answers
/// searches, [access] and [locator] stand for the platform.
ContextUseCases fakeContextUseCases({
  required PlacesDatabase db,
  required FindGazetteerPlaces places,
  required RequestLocationAccess access,
  required LocateDevice locator,
  FindPlacesAround around = const NoPlacesAround(),
  ReadDeviceZone deviceZone = const FakeDeviceZone(null),
}) {
  final data = bundledRuntimeData();
  final clock = FixedClock(harnessNowUtcMs);
  final contexts = DriftLocationContextStore(db);
  final resolvePlace = ResolvePlace(
    ResolveZone(data.zones),
    ResolveCountry(data.countries),
  );
  final locate = LocateObserver(
    clock: clock,
    locator: locator,
    read: contexts,
    write: contexts,
    resolvePlace: resolvePlace,
    events: const _NoEvents(),
  );
  return ContextUseCases(
    locate: LocateWithPermission(access, locate),
    resolve: ResolveObserverContext(contexts, locate, resolvePlace),
    pin: PinPlace(
      clock: clock,
      read: contexts,
      write: contexts,
      resolvePlace: resolvePlace,
    ),
    search: SearchGazetteer(places),
    travel: HandleZoneChange(contexts, locator, resolvePlace, clock),
    follow: FollowDeviceLocation(locate),
    suggest: SuggestPlaces(deviceZone, around),
    nameNearest: NameNearestPlace(around),
  );
}

final class _NoEvents implements RecordContextEvent {
  const new();

  @override
  Future<void> record(ContextChanged event) async {}
}

/// No place is near anything and no zone has places.
final class NoPlacesAround implements FindPlacesAround {
  /// The fake.
  const new();

  @override
  Future<Result<GazetteerHit?, GazetteerFailure>> nearest(
    GeoPointE6 point, {
    required double withinKm,
  }) async => const Ok(null);

  @override
  Future<Result<List<GazetteerHit>, GazetteerFailure>> largestIn(
    String zoneId, {
    required int limit,
  }) async => const Ok([]);
}

/// Places around fixed answers: [near] for any point, [inZone] for [zone].
final class FakePlacesAround implements FindPlacesAround {
  /// The fake.
  const new({this.near, this.zone = '', this.inZone = const []});

  /// The nearest place to any point.
  final GazetteerHit? near;

  /// The zone that has [inZone].
  final String zone;

  /// The places of [zone].
  final List<GazetteerHit> inZone;

  @override
  Future<Result<GazetteerHit?, GazetteerFailure>> nearest(
    GeoPointE6 point, {
    required double withinKm,
  }) async => Ok(near);

  @override
  Future<Result<List<GazetteerHit>, GazetteerFailure>> largestIn(
    String zoneId, {
    required int limit,
  }) async => Ok(zoneId == zone ? inZone.take(limit).toList() : const []);
}

/// A phone set to [id].
final class FakeDeviceZone implements ReadDeviceZone {
  /// The fake.
  const new(this.id);

  /// The zone id, or `null` when the platform does not say.
  final String? id;

  @override
  Future<String?> zoneId() async => id;
}
