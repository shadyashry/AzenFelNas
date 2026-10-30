import 'package:daily_muslim/features/quran/domain/build_search_index.dart';
import 'package:daily_muslim/features/quran/domain/download_cancel.dart';
import 'package:daily_muslim/features/quran/domain/download_progress.dart';
import 'package:daily_muslim/features/quran/domain/installed_quran.dart';
import 'package:daily_muslim/features/quran/domain/quran_origin.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_disk.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Downloads again only the damaged files of the active package, checks
/// each against the pinned manifest, rebuilds the search index if needed
/// and checks every file before reporting ready (§15 D106, REQ-QRN-013).
final class RepairQuranPackage {
  /// The use case over its ports.
  const new({
    required this._disk,
    required this._origin,
    required this._buildIndex,
  });

  final QuranPackageDisk _disk;
  final QuranOrigin _origin;
  final BuildSearchIndex _buildIndex;

  /// The statuses of the repair of [installed]'s [badFiles].
  Stream<QuranPackageStatus> call(
    InstalledQuran installed,
    List<String> badFiles,
    DownloadCancel cancel,
  ) async* {
    final dir = installed.directory;
    final files = [
      for (final f in installed.manifest.files)
        if (badFiles.contains(f.path)) f,
    ];
    final total = files.fold<int>(0, (sum, f) => sum + f.bytes);
    var done = 0;
    var count = 0;
    DownloadProgress progress() => DownloadProgress(
      doneBytes: done > total ? total : done,
      totalBytes: total,
      doneFiles: count,
      totalFiles: files.length,
    );
    yield QuranDownloading(progress());
    for (final file in files) {
      await _disk.discardFile(dir, file.path);
      final fetched = await _origin.download(
        file.path,
        _disk.partPath(dir, file.path),
        totalBytes: file.bytes,
        onBytes: (n) => done += n,
        cancelled: () => cancel.isCancelled,
      );
      if (fetched case Err(:final failure)) {
        yield QuranDamaged(installed, badFiles, failure: failure);
        return;
      }
      if (await _disk.commitFile(dir, file) case Err(:final failure)) {
        yield QuranDamaged(installed, badFiles, failure: failure);
        return;
      }
      count++;
      yield QuranDownloading(progress());
    }
    yield const QuranInstalling();
    final still = await _disk.fullCheck(installed);
    if (still.isNotEmpty) {
      yield QuranDamaged(installed, still);
      return;
    }
    if (await _buildIndex(dir) case Err()) {
      yield QuranDamaged(installed, const [searchIndexFileName]);
      return;
    }
    yield QuranReady((await _disk.active()) ?? installed);
  }
}
