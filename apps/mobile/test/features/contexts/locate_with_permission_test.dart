import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:daily_muslim/features/contexts/domain/location_access.dart';
import 'package:daily_muslim/features/contexts/domain/search_key.dart';
import 'package:daily_muslim/features/storage/data/places_database.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';
import '../../support/fake_location_access.dart';
import '../../support/runtime_fixtures.dart';
import '../../support/state_harness.dart';
import 'support/fake_device_locator.dart';

void main() {
  late PlacesDatabase db;
  setUp(() => db = PlacesDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  for (final refused in [
    LocationAccess.denied,
    LocationAccess.permanentlyDenied,
    LocationAccess.restricted,
  ]) {
    test('REQ-PRIV-002 ${refused.name} access is LOC_PERMISSION_DENIED and '
        'the device is never asked for a fix', () async {
      final locator = FakeDeviceLocator()
        ..current = Ok(cairoFix(fixUtcMs: harnessNowUtcMs));
      final useCases = fakeContextUseCases(
        db: db,
        places: const _NoSearch(),
        access: FakeLocationAccess(refused),
        locator: locator,
      );
      final result = await useCases.locate();
      expect(switch (result) {
        Ok() => 'ok',
        Err(:final failure) => failure.code.wire,
      }, 'LOC_PERMISSION_DENIED');
    });
  }

  test('REQ-PRIV-002 granted access stores the fix as the current '
      'context', () async {
    final useCases = fakeContextUseCases(
      db: db,
      places: const _NoSearch(),
      access: FakeLocationAccess(LocationAccess.granted),
      locator: FakeDeviceLocator()
        ..current = Ok(cairoFix(fixUtcMs: harnessNowUtcMs)),
    );
    final result = await useCases.locate();
    expect(switch (result) {
      Ok(:final value) => value.context.kind,
      Err() => null,
    }, ContextKind.current);
  });
}

final class _NoSearch implements FindGazetteerPlaces {
  const new();

  @override
  Future<Result<List<GazetteerHit>, GazetteerFailure>> findByPrefix(
    SearchKey prefix, {
    required int limit,
  }) async => const Ok([]);
}
