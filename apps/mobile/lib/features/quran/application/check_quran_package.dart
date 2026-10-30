import 'package:daily_muslim/features/quran/domain/build_search_index.dart';
import 'package:daily_muslim/features/quran/domain/download_progress.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_disk.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The package's status at start, without the network (§15 D106,
/// REQ-QRN-010): the active package if every file has its size and the
/// local search index is current (rebuilt here when it is not), damaged if
/// a file is missing or cut short, paused if a download was left, and not
/// installed otherwise.
final class CheckQuranPackage {
  /// The use case over its ports; `indexIsCurrent` tells whether a
  /// package directory holds a current search index, `pinnedManifestSha256`
  /// is the package this build expects.
  const new(
    this._disk,
    this._buildIndex,
    this._indexIsCurrent, {
    this._pinnedManifestSha256 = QuranEditionPin.manifestSha256,
  });

  final QuranPackageDisk _disk;
  final BuildSearchIndex _buildIndex;
  final bool Function(String directory) _indexIsCurrent;
  final String _pinnedManifestSha256;

  /// The status now.
  Future<QuranPackageStatus> call() async {
    final installed = await _disk.active();
    if (installed != null) {
      final bad = await _disk.quickCheck(installed);
      if (bad.isNotEmpty) return QuranDamaged(installed, bad);
      if (!_indexIsCurrent(installed.directory)) {
        if (await _buildIndex(installed.directory) case Err()) {
          return QuranDamaged(installed, const [searchIndexFileName]);
        }
      }
      return QuranReady(
        installed,
        updateAvailable: installed.manifestSha256 != _pinnedManifestSha256,
      );
    }
    final staged = await _disk.staging();
    if (staged == null) return const QuranNotInstalled();
    return QuranPaused(
      DownloadProgress(
        doneBytes: staged.doneBytes,
        totalBytes: staged.totalBytes,
        doneFiles: staged.verified.length,
        totalFiles: staged.manifest.files.length,
      ),
    );
  }
}
