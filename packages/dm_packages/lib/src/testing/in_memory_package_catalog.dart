import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/active_package.dart';
import 'package:dm_packages/src/client/package_file.dart';
import 'package:dm_packages/src/client/package_file_state.dart';
import 'package:dm_packages/src/client/package_type.dart';
import 'package:dm_packages/src/client/ports/read_package_catalog.dart';
import 'package:dm_packages/src/client/ports/write_package_catalog.dart';
import 'package:dm_packages/src/verify/metadata_role.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// The package catalog in memory: the fake of [ReadPackageCatalog] and
/// [WritePackageCatalog] that runs the same contract suite as the drift
/// store. [failWrites] makes every write fail with `PKG_STORAGE` and change
/// nothing.
final class InMemoryPackageCatalog
    implements ReadPackageCatalog, WritePackageCatalog {
  /// An empty catalog.
  new();

  final Map<PackageType, ActivePackage> _active = {};
  final Map<(PackageType, String), PackageFile> _files = {};

  /// When true, writes fail and change nothing.
  bool failWrites = false;

  @override
  Future<ActivePackage?> active(PackageType type) async => _active[type];

  @override
  Future<List<ActivePackage>> activeAll() async =>
      _active.values.toList()
        ..sort((a, b) => a.type.wire.compareTo(b.type.wire));

  @override
  Future<List<PackageFile>> files(PackageType type) async => _sorted(
    _files.values.where((f) => f.type == type),
  );

  @override
  Future<List<PackageFile>> garbageBefore(int utcMs) async => _sorted(
    _files.values.where(
      (f) => f.state == PackageFileState.garbage && f.updatedUtcMs <= utcMs,
    ),
  );

  @override
  Future<Result<void, PackageFailure>> record(PackageFile file) async {
    if (failWrites) return _storage;
    _files[(file.type, file.version)] = file;
    return const Result.ok(null);
  }

  @override
  Future<Result<void, PackageFailure>> activate(
    ActivePackage next,
    PackageFile file,
  ) async {
    if (failWrites) return _storage;
    final current = _active[next.type];
    if (current != null && next.sequence < current.sequence) {
      return Result.err(
        PackageFailure.sequenceRegression(
          role: MetadataRole.targets,
          sequence: next.sequence,
          trusted: current.sequence,
        ),
      );
    }
    final now = next.activatedUtcMs;
    for (final old in [..._files.values]) {
      if (old.type != next.type || old.version == file.version) continue;
      final demoted = switch (old.state) {
        PackageFileState.previous => PackageFileState.garbage,
        PackageFileState.active => PackageFileState.previous,
        PackageFileState.staged || PackageFileState.garbage => null,
      };
      if (demoted != null) {
        _files[(old.type, old.version)] = old.withState(demoted, now);
      }
    }
    _files[(file.type, file.version)] = file;
    _active[next.type] = next;
    return const Result.ok(null);
  }

  @override
  Future<Result<ActivePackage, PackageFailure>> rollBack(
    PackageType type,
    int utcMs,
  ) async {
    if (failWrites) return _storage;
    final current = _active[type];
    final previous = _files.values
        .where((f) => f.type == type && f.state == PackageFileState.previous)
        .firstOrNull;
    if (current == null || previous == null) {
      return Result.err(
        PackageFailure.storage('${type.wire} has no previous version'),
      );
    }
    if (_files[(type, current.version)] case final abandoned?) {
      _files[(type, current.version)] = abandoned.withState(
        PackageFileState.garbage,
        utcMs,
      );
    }
    _files[(type, previous.version)] = previous.withState(
      PackageFileState.active,
      utcMs,
    );
    final restored = ActivePackage(
      type: type,
      version: previous.version,
      sequence: current.sequence,
      sha256: previous.sha256,
      source: previous.source,
      activatedUtcMs: utcMs,
    );
    _active[type] = restored;
    return Result.ok(restored);
  }

  @override
  Future<Result<void, PackageFailure>> forget(PackageFile file) async {
    if (failWrites) return _storage;
    _files.remove((file.type, file.version));
    return const Result.ok(null);
  }

  static List<PackageFile> _sorted(Iterable<PackageFile> files) =>
      files.toList()..sort((a, b) {
        final byType = a.type.wire.compareTo(b.type.wire);
        return byType != 0 ? byType : a.version.compareTo(b.version);
      });

  static const Err<Never, PackageFailure> _storage = Err(
    PackageFailure.storage('in-memory catalog set to fail'),
  );
}
