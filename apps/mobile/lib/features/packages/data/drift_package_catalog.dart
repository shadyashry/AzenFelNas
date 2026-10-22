import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:drift/drift.dart';

/// [ReadPackageCatalog] and [WritePackageCatalog] on drift (§7.3
/// `active_packages`, `package_files`). Each write is one transaction, so a
/// failure leaves the last-known-good active (REQ-PKG-001). Rows with a
/// type, source or state this build does not know are skipped on read.
final class DriftPackageCatalog
    implements ReadPackageCatalog, WritePackageCatalog {
  /// The catalog in [_db].
  const new(this._db);

  final DmDatabase _db;

  @override
  Future<ActivePackage?> active(PackageType type) async {
    final row = await (_db.select(
      _db.activePackages,
    )..where((t) => t.type.equals(type.wire))).getSingleOrNull();
    return row == null ? null : _active(row);
  }

  @override
  Future<List<ActivePackage>> activeAll() async {
    final rows = await (_db.select(
      _db.activePackages,
    )..orderBy([(t) => OrderingTerm.asc(t.type)])).get();
    return [for (final row in rows) ?_active(row)];
  }

  @override
  Future<List<PackageFile>> files(PackageType type) async {
    final rows =
        await (_db.select(_db.packageFiles)
              ..where((t) => t.type.equals(type.wire))
              ..orderBy([(t) => OrderingTerm.asc(t.version)]))
            .get();
    return [for (final row in rows) ?_file(row)];
  }

  @override
  Future<List<PackageFile>> garbageBefore(int utcMs) async {
    final rows =
        await (_db.select(_db.packageFiles)
              ..where(
                (t) =>
                    t.state.equals(PackageFileState.garbage.wire) &
                    t.updatedUtc.isSmallerOrEqualValue(utcMs),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.type),
                (t) => OrderingTerm.asc(t.version),
              ]))
            .get();
    return [for (final row in rows) ?_file(row)];
  }

  @override
  Future<Result<void, PackageFailure>> record(PackageFile file) => _guard(
    () => _db.into(_db.packageFiles).insertOnConflictUpdate(_row(file)),
  );

  @override
  Future<Result<void, PackageFailure>> activate(
    ActivePackage next,
    PackageFile file,
  ) async {
    final current = await active(next.type);
    if (current != null && next.sequence < current.sequence) {
      return Result.err(
        PackageFailure.sequenceRegression(
          role: MetadataRole.targets,
          sequence: next.sequence,
          trusted: current.sequence,
        ),
      );
    }
    return await _guard(
      () => _db.transaction(() async {
        final now = next.activatedUtcMs;
        await _demote(
          next.type,
          file.version,
          PackageFileState.previous,
          PackageFileState.garbage,
          now,
        );
        await _demote(
          next.type,
          file.version,
          PackageFileState.active,
          PackageFileState.previous,
          now,
        );
        await _db.into(_db.packageFiles).insertOnConflictUpdate(_row(file));
        await _db
            .into(_db.activePackages)
            .insertOnConflictUpdate(
              ActivePackagesCompanion.insert(
                type: next.type.wire,
                version: next.version,
                sequence: next.sequence,
                sha256: next.sha256,
                source: next.source.wire,
                activatedUtc: next.activatedUtcMs,
                previousVersion: Value(next.previousVersion),
              ),
            );
      }),
    );
  }

  @override
  Future<Result<ActivePackage, PackageFailure>> rollBack(
    PackageType type,
    int utcMs,
  ) async {
    final current = await active(type);
    final previous = [
      for (final f in await files(type))
        if (f.state == PackageFileState.previous) f,
    ].firstOrNull;
    if (current == null || previous == null) {
      return Result.err(
        PackageFailure.storage('${type.wire} has no previous version'),
      );
    }
    final restored = ActivePackage(
      type: type,
      version: previous.version,
      sequence: current.sequence,
      sha256: previous.sha256,
      source: previous.source,
      activatedUtcMs: utcMs,
    );
    final written = await _guard(
      () => _db.transaction(() async {
        await _setState(type, current.version, PackageFileState.garbage, utcMs);
        await _setState(type, previous.version, PackageFileState.active, utcMs);
        await _db
            .into(_db.activePackages)
            .insertOnConflictUpdate(
              ActivePackagesCompanion.insert(
                type: type.wire,
                version: restored.version,
                sequence: restored.sequence,
                sha256: restored.sha256,
                source: restored.source.wire,
                activatedUtc: utcMs,
                previousVersion: const Value(null),
              ),
            );
      }),
    );
    return written.map((_) => restored);
  }

  @override
  Future<Result<void, PackageFailure>> forget(PackageFile file) => _guard(
    () =>
        (_db.delete(_db.packageFiles)..where(
              (t) =>
                  t.type.equals(file.type.wire) &
                  t.version.equals(file.version),
            ))
            .go(),
  );

  Future<void> _demote(
    PackageType type,
    String keep,
    PackageFileState from,
    PackageFileState to,
    int utcMs,
  ) =>
      (_db.update(_db.packageFiles)..where(
            (t) =>
                t.type.equals(type.wire) &
                t.state.equals(from.wire) &
                t.version.equals(keep).not(),
          ))
          .write(
            PackageFilesCompanion(
              state: Value(to.wire),
              updatedUtc: Value(utcMs),
            ),
          );

  Future<void> _setState(
    PackageType type,
    String version,
    PackageFileState state,
    int utcMs,
  ) =>
      (_db.update(_db.packageFiles)..where(
            (t) => t.type.equals(type.wire) & t.version.equals(version),
          ))
          .write(
            PackageFilesCompanion(
              state: Value(state.wire),
              updatedUtc: Value(utcMs),
            ),
          );

  static Future<Result<void, PackageFailure>> _guard(
    Future<void> Function() write,
  ) async {
    try {
      await write();
      return const Result.ok(null);
    } on Exception catch (error) {
      return Result.err(PackageFailure.storage('$error'));
    }
  }

  static PackageFilesCompanion _row(PackageFile file) =>
      PackageFilesCompanion.insert(
        type: file.type.wire,
        version: file.version,
        path: file.path,
        sha256: file.sha256,
        source: file.source.wire,
        state: file.state.wire,
        updatedUtc: file.updatedUtcMs,
      );

  static ActivePackage? _active(ActivePackageRow row) => switch ((
    PackageType.fromWire(row.type),
    PackageSource.fromWire(row.source),
  )) {
    (final type?, final source?) => ActivePackage(
      type: type,
      version: row.version,
      sequence: row.sequence,
      sha256: row.sha256,
      source: source,
      activatedUtcMs: row.activatedUtc,
      previousVersion: row.previousVersion,
    ),
    _ => null,
  };

  static PackageFile? _file(PackageFileRow row) => switch ((
    PackageType.fromWire(row.type),
    PackageSource.fromWire(row.source),
    PackageFileState.fromWire(row.state),
  )) {
    (final type?, final source?, final state?) => PackageFile(
      type: type,
      version: row.version,
      path: row.path,
      sha256: row.sha256,
      source: source,
      state: state,
      updatedUtcMs: row.updatedUtc,
    ),
    _ => null,
  };
}
