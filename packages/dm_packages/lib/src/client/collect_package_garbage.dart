import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/package_source.dart';
import 'package:dm_packages/src/client/ports/read_package_catalog.dart';
import 'package:dm_packages/src/client/ports/store_package_blobs.dart';
import 'package:dm_packages/src/client/ports/write_package_catalog.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// Deletes package files that have been `garbage` for 7 days (§7.3,
/// §7.4): the blob first, then the row, so a crash in between leaves a row
/// that the next run removes. Never touches `active` or `previous` files.
final class CollectPackageGarbage {
  /// The use case over its ports.
  const new({
    required this._read,
    required this._write,
    required this._blobs,
  });

  final ReadPackageCatalog _read;
  final WritePackageCatalog _write;
  final StorePackageBlobs _blobs;

  /// How long a garbage file is kept.
  static const Duration retention = Duration(days: 7);

  /// The number of files deleted at [nowUtcMs], or the first failure.
  Future<Result<int, PackageFailure>> call({required int nowUtcMs}) async {
    final due = await _read.garbageBefore(nowUtcMs - retention.inMilliseconds);
    for (final file in due) {
      if (file.source == PackageSource.downloaded) {
        if (await _blobs.delete(file.path) case Err(:final failure)) {
          return Result.err(failure);
        }
      }
      if (await _write.forget(file) case Err(:final failure)) {
        return Result.err(failure);
      }
    }
    return Result.ok(due.length);
  }
}
