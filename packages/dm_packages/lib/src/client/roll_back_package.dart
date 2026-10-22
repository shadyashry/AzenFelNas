import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/active_package.dart';
import 'package:dm_packages/src/client/load_package_payload.dart';
import 'package:dm_packages/src/client/package_event.dart';
import 'package:dm_packages/src/client/package_file_state.dart';
import 'package:dm_packages/src/client/package_type.dart';
import 'package:dm_packages/src/client/ports/apply_package.dart';
import 'package:dm_packages/src/client/ports/read_package_catalog.dart';
import 'package:dm_packages/src/client/ports/record_package_event.dart';
import 'package:dm_packages/src/client/ports/write_package_catalog.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// Returns a type to its previous version on the device, when the active
/// one cannot be used (REQ-PKG-001): loads and re-applies the previous
/// payload, flips the pointer back in one transaction, marks the abandoned
/// version `garbage` so sync does not choose it again for 7 days, and logs
/// `PKG_ROLLED_BACK`. A signed rollback from the CDN is an ordinary
/// activation of a target with `rollbackOf` (REQ-DIST-002).
final class RollBackPackage {
  /// The use case over its ports.
  const new({
    required this._read,
    required this._write,
    required this._load,
    required this._apply,
    required this._events,
  });

  final ReadPackageCatalog _read;
  final WritePackageCatalog _write;
  final LoadPackagePayload _load;
  final ApplyPackage _apply;
  final RecordPackageEvent _events;

  /// The restored pointer of [type] at [nowUtcMs]; `PKG_STORAGE` when there
  /// is nothing to go back to. On a failure the active version is unchanged.
  Future<Result<ActivePackage, PackageFailure>> call(
    PackageType type, {
    required int nowUtcMs,
  }) async {
    final current = await _read.active(type);
    final previous = [
      for (final file in await _read.files(type))
        if (file.state == PackageFileState.previous) file,
    ];
    if (current == null || previous.isEmpty) {
      return Result.err(
        PackageFailure.storage('${type.wire} has no previous version'),
      );
    }
    final target = previous.first;
    switch (await _load(target)) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(value: final payload):
        if (await _apply(type, target.version, payload) case Err(
          :final failure,
        )) {
          return Result.err(failure);
        }
    }
    final restored = await _write.rollBack(type, nowUtcMs);
    if (restored case Ok(:final value)) {
      await _events.record(
        PackageRolledBack(
          utcMs: nowUtcMs,
          type: type,
          fromVersion: current.version,
          toVersion: value.version,
        ),
      );
    }
    return restored;
  }
}
