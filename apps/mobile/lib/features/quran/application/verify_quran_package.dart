import 'package:daily_muslim/features/quran/domain/installed_quran.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_disk.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';

/// Reads every byte of the active package and compares each file with its
/// pinned SHA-256 (§15 D106, REQ-QRN-013): [QuranReady] when all match,
/// [QuranDamaged] with the files that do not.
final class VerifyQuranPackage {
  /// The use case over [_disk].
  const new(this._disk);

  final QuranPackageDisk _disk;

  /// The verdict on [installed], reporting files checked through
  /// [progress].
  Future<QuranPackageStatus> call(
    InstalledQuran installed, {
    void Function(int done, int total)? progress,
  }) async {
    final bad = await _disk.fullCheck(installed, progress: progress);
    return bad.isEmpty ? QuranReady(installed) : QuranDamaged(installed, bad);
  }
}
