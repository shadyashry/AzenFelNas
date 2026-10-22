// REQ-TEST-004: the package catalog contract, run against the drift
// adapter and the in-memory fake alike.
import 'package:daily_muslim/features/packages/data/drift_package_catalog.dart';
import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:dm_packages/testing.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Catalog = ({
  ReadPackageCatalog read,
  WritePackageCatalog write,
  Future<void> Function() close,
});

const PackageType _tz = PackageType.tzdata;

PackageFile _file(String version, {int at = 0}) => PackageFile(
  type: _tz,
  version: version,
  path: 'tzdata/$version/$version.dmpkg',
  sha256: 'sha-$version',
  source: PackageSource.downloaded,
  state: PackageFileState.staged,
  updatedUtcMs: at,
);

ActivePackage _pointer(String version, int sequence, {String? previous}) =>
    ActivePackage(
      type: _tz,
      version: version,
      sequence: sequence,
      sha256: 'sha-$version',
      source: PackageSource.downloaded,
      activatedUtcMs: sequence * 1000,
      previousVersion: previous,
    );

Future<void> _activate(_Catalog c, String version, int sequence) async {
  final previous = (await c.read.active(_tz))?.version;
  final result = await c.write.activate(
    _pointer(version, sequence, previous: previous),
    _file(version).withState(PackageFileState.active, sequence * 1000),
  );
  expect(result, isA<Ok<void, PackageFailure>>());
}

Future<List<(String, PackageFileState)>> _states(_Catalog c) async => [
  for (final f in await c.read.files(_tz)) (f.version, f.state),
];

void main() {
  final implementations = <String, _Catalog Function()>{
    'DriftPackageCatalog': () {
      final db = DmDatabase(NativeDatabase.memory());
      final catalog = DriftPackageCatalog(db);
      return (read: catalog, write: catalog, close: db.close);
    },
    'InMemoryPackageCatalog': () {
      final catalog = InMemoryPackageCatalog();
      return (read: catalog, write: catalog, close: () async {});
    },
  };

  for (final MapEntry(key: name, value: open) in implementations.entries) {
    group('$name honours the package catalog contract (REQ-TEST-004, '
        'REQ-PKG-001)', () {
      late _Catalog c;
      setUp(() => c = open());
      tearDown(() => c.close());

      test('an empty catalog has no active package and no files', () async {
        expect(await c.read.active(_tz), isNull);
        expect(await c.read.activeAll(), isEmpty);
        expect(await c.read.files(_tz), isEmpty);
      });

      test('record upserts by type and version', () async {
        await c.write.record(_file('2026d'));
        await c.write.record(
          _file('2026d').withState(PackageFileState.garbage, 5),
        );
        expect(await _states(c), [('2026d', PackageFileState.garbage)]);
      });

      test('activation demotes active → previous → garbage', () async {
        await _activate(c, '2026c', 1);
        await _activate(c, '2026d', 2);
        await _activate(c, '2026e', 3);

        final active = await c.read.active(_tz);
        expect(active, _pointer('2026e', 3, previous: '2026d'));
        expect(await _states(c), [
          ('2026c', PackageFileState.garbage),
          ('2026d', PackageFileState.previous),
          ('2026e', PackageFileState.active),
        ]);
        expect(await c.read.activeAll(), [active]);
      });

      test('a lower sequence is refused and changes nothing', () async {
        await _activate(c, '2026e', 3);

        final result = await c.write.activate(
          _pointer('2026d', 2),
          _file('2026d').withState(PackageFileState.active, 0),
        );

        expect(
          result,
          isA<Err<void, PackageFailure>>().having(
            (e) => e.failure.code,
            'code',
            FailureCode.pkgSequenceRegression,
          ),
        );
        expect((await c.read.active(_tz))?.version, '2026e');
        expect(await _states(c), [('2026e', PackageFileState.active)]);
      });

      test('rollBack restores previous under the active sequence', () async {
        await _activate(c, '2026d', 2);
        await _activate(c, '2026e', 3);

        final result = await c.write.rollBack(_tz, 9000);

        expect(
          result,
          const Ok<ActivePackage, PackageFailure>(
            ActivePackage(
              type: _tz,
              version: '2026d',
              sequence: 3,
              sha256: 'sha-2026d',
              source: PackageSource.downloaded,
              activatedUtcMs: 9000,
            ),
          ),
        );
        expect(await _states(c), [
          ('2026d', PackageFileState.active),
          ('2026e', PackageFileState.garbage),
        ]);
      });

      test('rollBack without a previous version is PKG_STORAGE', () async {
        await _activate(c, '2026e', 3);

        final result = await c.write.rollBack(_tz, 9000);

        expect(
          result,
          isA<Err<ActivePackage, PackageFailure>>().having(
            (e) => e.failure.code,
            'code',
            FailureCode.pkgStorage,
          ),
        );
        expect((await c.read.active(_tz))?.version, '2026e');
      });

      test('garbageBefore is bounded by time; forget removes a row', () async {
        await c.write.record(
          _file('old').withState(PackageFileState.garbage, 100),
        );
        await c.write.record(
          _file('new').withState(PackageFileState.garbage, 200),
        );
        await c.write.record(_file('kept'));

        final due = await c.read.garbageBefore(150);
        await c.write.forget(due.single);

        expect(due.map((f) => f.version), ['old']);
        expect(await _states(c), [
          ('kept', PackageFileState.staged),
          ('new', PackageFileState.garbage),
        ]);
      });
    });
  }
}
