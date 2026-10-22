import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/active_package.dart';
import 'package:dm_packages/src/client/package_event.dart';
import 'package:dm_packages/src/client/package_file_state.dart';
import 'package:dm_packages/src/client/ports/apply_package.dart';
import 'package:dm_packages/src/client/ports/read_package_catalog.dart';
import 'package:dm_packages/src/client/ports/record_package_event.dart';
import 'package:dm_packages/src/client/ports/write_package_catalog.dart';
import 'package:dm_packages/src/client/staged_package.dart';
import 'package:dm_packages/src/verify/metadata_role.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// Activates a staged package (REQ-PKG-001): refuses a pointer downgrade,
/// runs the type's [ApplyPackage] step, then flips `active_packages` in one
/// transaction and logs `PKG_ACTIVATED`. On any failure the previous
/// version stays active and the staged file becomes `garbage`.
final class ActivateStaged {
  /// The use case over its ports.
  const new({
    required this._read,
    required this._write,
    required this._apply,
    required this._events,
  });

  final ReadPackageCatalog _read;
  final WritePackageCatalog _write;
  final ApplyPackage _apply;
  final RecordPackageEvent _events;

  /// The new pointer of [staged], activated under the `targets.json`
  /// [sequence] (0 for a bundled seed) at [nowUtcMs].
  Future<Result<ActivePackage, PackageFailure>> call(
    StagedPackage staged, {
    required int sequence,
    required int nowUtcMs,
  }) async {
    final file = staged.file;
    final current = await _read.active(file.type);
    if (current != null && sequence < current.sequence) {
      return await _refuse(
        staged,
        current,
        nowUtcMs,
        PackageFailure.sequenceRegression(
          role: MetadataRole.targets,
          sequence: sequence,
          trusted: current.sequence,
        ),
      );
    }
    final applied = await _apply(file.type, file.version, staged.payload);
    if (applied case Err(:final failure)) {
      return await _refuse(staged, current, nowUtcMs, failure);
    }
    final next = ActivePackage(
      type: file.type,
      version: file.version,
      sequence: sequence,
      sha256: file.sha256,
      source: file.source,
      activatedUtcMs: nowUtcMs,
      previousVersion: current?.version == file.version
          ? current?.previousVersion
          : current?.version,
    );
    final flipped = await _write.activate(
      next,
      file.withState(PackageFileState.active, nowUtcMs),
    );
    if (flipped case Err(:final failure)) {
      return await _refuse(staged, current, nowUtcMs, failure);
    }
    await _events.record(
      PackageActivated(
        utcMs: nowUtcMs,
        type: file.type,
        version: file.version,
        source: file.source,
      ),
    );
    return Result.ok(next);
  }

  Future<Result<ActivePackage, PackageFailure>> _refuse(
    StagedPackage staged,
    ActivePackage? current,
    int nowUtcMs,
    PackageFailure failure,
  ) async {
    // The refusal is the result; a failed garbage mark only means the next
    // sync tries the target again, so its own failure is not reported. The
    // active version's row is never marked.
    if (current?.version != staged.file.version) {
      await _write.record(
        staged.file.withState(PackageFileState.garbage, nowUtcMs),
      );
    }
    return Result.err(failure);
  }
}
