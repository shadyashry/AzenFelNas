import 'package:daily_muslim/features/contexts/data/drift_location_context_store.dart';
import 'package:daily_muslim/features/contexts/data/places_database.dart';
import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/context_source.dart';
import 'package:daily_muslim/features/contexts/domain/location_context.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_location_context_store.dart';
import 'support/places_fixtures.dart';

/// Both ports of one implementation, and how to release it.
typedef _Store = ({
  ReadLocationContexts read,
  WriteLocationContexts write,
  Future<void> Function() close,
});

T _ok<T>(Result<T, LocationFailure> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => fail('$failure'),
};

void main() {
  final implementations = <String, _Store Function()>{
    'DriftLocationContextStore': () {
      final db = PlacesDatabase(NativeDatabase.memory());
      final store = DriftLocationContextStore(db);
      return (read: store, write: store, close: db.close);
    },
    'FakeLocationContextStore': () {
      final store = FakeLocationContextStore();
      return (read: store, write: store, close: () async {});
    },
  };

  for (final MapEntry(key: name, value: open) in implementations.entries) {
    group('REQ-TEST-004 location context port contract: $name', () {
      late _Store store;

      setUp(() => store = open());
      tearDown(() => store.close());

      test('an empty store has no active and no current context', () async {
        expect(_ok(await store.read.active()), isNull);
        expect(_ok(await store.read.current()), isNull);
      });

      test('saveCurrent keeps one current row and its creation time', () async {
        final first = _ok(
          await store.write.saveCurrent(
            cairoPlace,
            ContextSource.freshFix,
            utcMs: 1000,
          ),
        );
        final second = _ok(
          await store.write.saveCurrent(
            londonPlace,
            ContextSource.lastKnownFix,
            utcMs: 2000,
          ),
        );
        expect(second.id, first.id);
        expect(second.kind, ContextKind.current);
        expect(second.place, londonPlace);
        expect(second.source, ContextSource.lastKnownFix);
        expect(second.createdUtcMs, 1000);
        expect(second.lastUsedUtcMs, 2000);
        expect(_ok(await store.read.current()), second);
        expect(_ok(await store.read.active()), second);
      });

      test('places round-trip at micro-degree precision, null country '
          'and null accuracy included', () async {
        final ocean = _ok(
          await store.write.saveCurrent(
            oceanPlace,
            ContextSource.freshFix,
            utcMs: 1,
          ),
        );
        final makkah = _ok(
          await store.write.addChosen(
            ChosenKind.manual,
            makkahPlace,
            ContextSource.gazetteer,
            utcMs: 2,
          ),
        );
        expect(ocean.place, oceanPlace);
        expect(makkah.place, makkahPlace);
        expect(makkah.kind, ContextKind.manual);
      });

      test('the context used last is active; markUsed changes only the '
          'last-used time', () async {
        final makkah = _ok(
          await store.write.addChosen(
            ChosenKind.pinned,
            makkahPlace,
            ContextSource.freshFix,
            utcMs: 10,
          ),
        );
        _ok(
          await store.write.saveCurrent(
            cairoPlace,
            ContextSource.freshFix,
            utcMs: 20,
          ),
        );
        expect(_ok(await store.read.active())?.kind, ContextKind.current);
        final used = _ok(await store.write.markUsed(makkah.id, utcMs: 30));
        expect(
          used,
          LocationContext(
            id: makkah.id,
            kind: ContextKind.pinned,
            place: makkahPlace,
            source: ContextSource.freshFix,
            createdUtcMs: 10,
            lastUsedUtcMs: 30,
          ),
        );
        expect(_ok(await store.read.active()), used);
      });

      test('markUsed of an unknown id fails with LOC_UNAVAILABLE', () async {
        final result = await store.write.markUsed(99, utcMs: 1);
        expect(
          switch (result) {
            Err(:final failure) => failure.code,
            Ok() => null,
          },
          FailureCode.locUnavailable,
        );
      });

      test(
        'REQ-PRIV-002 saveCurrent never changes a pinned or manual row',
        () async {
          final pinned = _ok(
            await store.write.addChosen(
              ChosenKind.pinned,
              cairoPlace,
              ContextSource.freshFix,
              utcMs: 1,
            ),
          );
          final manual = _ok(
            await store.write.addChosen(
              ChosenKind.manual,
              makkahPlace,
              ContextSource.typedCoordinates,
              utcMs: 2,
            ),
          );
          for (var i = 0; i < 3; i++) {
            _ok(
              await store.write.saveCurrent(
                londonPlace,
                ContextSource.freshFix,
                utcMs: 3 + i,
              ),
            );
          }
          final current = _ok(await store.read.current());
          expect(current?.place, londonPlace);
          expect(current?.id, isNot(anyOf(pinned.id, manual.id)));
          expect(
            _ok(await store.write.markUsed(pinned.id, utcMs: 9)).place,
            cairoPlace,
          );
          expect(
            _ok(await store.write.markUsed(manual.id, utcMs: 10)).place,
            makkahPlace,
          );
        },
      );
    });
  }
}
