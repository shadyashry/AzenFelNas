import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Where the Quran package is downloaded from: `cdn.azenfelnas.app` only
/// (§0.2, §15 D106). Used only by the download; reading never calls it.
abstract interface class QuranOrigin {
  /// The package's `manifest.json`, at most [maxBytes] bytes.
  Future<Result<List<int>, QuranFailure>> manifest({required int maxBytes});

  /// Appends package file [path] to [partPath], resuming after the bytes
  /// already in it, until [totalBytes]. Reports bytes appended through
  /// [onBytes]; stops with [QuranCancelled] when [cancelled] turns true.
  Future<Result<void, QuranFailure>> download(
    String path,
    String partPath, {
    required int totalBytes,
    required void Function(int bytes) onBytes,
    required bool Function() cancelled,
  });
}
