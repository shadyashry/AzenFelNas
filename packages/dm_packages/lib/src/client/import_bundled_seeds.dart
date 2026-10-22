import 'package:crypto/crypto.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/activate_staged.dart';
import 'package:dm_packages/src/client/active_package.dart';
import 'package:dm_packages/src/client/app_compat.dart';
import 'package:dm_packages/src/client/bundled_seed.dart';
import 'package:dm_packages/src/client/package_file.dart';
import 'package:dm_packages/src/client/package_file_state.dart';
import 'package:dm_packages/src/client/package_source.dart';
import 'package:dm_packages/src/client/package_type.dart';
import 'package:dm_packages/src/client/ports/check_payload.dart';
import 'package:dm_packages/src/client/ports/read_bundled_seeds.dart';
import 'package:dm_packages/src/client/ports/read_package_catalog.dart';
import 'package:dm_packages/src/client/seed_import_report.dart';
import 'package:dm_packages/src/client/staged_package.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// Imports the seeds bundled in the binary as `source=bundled`
/// (REQ-PKG-003). Runs on every app start and is idempotent: a type whose
/// active version was downloaded is never replaced by a seed (the pointer
/// is downgrade-safe), and a seed already active is skipped. A seed is
/// checked like a download — SHA-256, supported schema, payload schema —
/// before `ActivateStaged` applies it under sequence 0.
final class ImportBundledSeeds {
  /// The use case over its ports.
  const new({
    required this._seeds,
    required this._catalog,
    required this._app,
    required this._checkPayload,
    required this._activate,
  });

  final ReadBundledSeeds _seeds;
  final ReadPackageCatalog _catalog;
  final AppCompat _app;
  final CheckPayload _checkPayload;
  final ActivateStaged _activate;

  /// Imports what is missing at [nowUtcMs].
  Future<SeedImportReport> call({required int nowUtcMs}) async {
    final imported = <ActivePackage>[];
    final failures = <PackageType, PackageFailure>{};
    for (final seed in await _seeds.seeds()) {
      final current = await _catalog.active(seed.type);
      final skip = switch (current?.source) {
        null => false,
        PackageSource.downloaded => true,
        PackageSource.bundled => current?.sha256 == seed.sha256,
      };
      if (skip) continue;
      switch (await _staged(seed, nowUtcMs)) {
        case Err(:final failure):
          failures[seed.type] = failure;
        case Ok(value: final staged):
          switch (await _activate(staged, sequence: 0, nowUtcMs: nowUtcMs)) {
            case Ok(:final value):
              imported.add(value);
            case Err(:final failure):
              failures[seed.type] = failure;
          }
      }
    }
    return SeedImportReport(imported: imported, failures: failures);
  }

  Future<Result<StagedPackage, PackageFailure>> _staged(
    BundledSeed seed,
    int nowUtcMs,
  ) async {
    final supported = _app.schemaVersions[seed.type];
    if (supported == null || seed.schemaVersion > supported) {
      return Result.err(
        PackageFailure.incompatible('$seed schema ${seed.schemaVersion}'),
      );
    }
    final List<int> payload;
    switch (await _seeds.payload(seed)) {
      case Ok(:final value):
        payload = value;
      case Err(:final failure):
        return Result.err(failure);
    }
    if (sha256.convert(payload).toString() != seed.sha256) {
      return Result.err(
        PackageFailure.hashMismatch('$seed does not match its index'),
      );
    }
    return _checkPayload(
      seed.type,
      seed.version,
      seed.schemaVersion,
      payload,
    ).map(
      (_) => StagedPackage(
        file: PackageFile(
          type: seed.type,
          version: seed.version,
          path: PackageFile.bundledPath(seed.type, seed.version),
          sha256: seed.sha256,
          source: PackageSource.bundled,
          state: PackageFileState.staged,
          updatedUtcMs: nowUtcMs,
        ),
        payload: payload,
      ),
    );
  }
}
