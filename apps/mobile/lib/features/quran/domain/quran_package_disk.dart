import 'package:daily_muslim/features/quran/domain/installed_quran.dart';
import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:daily_muslim/features/quran/domain/quran_manifest.dart';
import 'package:daily_muslim/features/quran/domain/quran_manifest_file.dart';
import 'package:daily_muslim/features/quran/domain/staged_quran.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The Quran package on this device's persistent app storage (§15 D106):
/// one active package, at most one staging directory for a download in
/// progress, and an atomic switch between them. Never a cache directory,
/// so the OS does not clear it.
abstract interface class QuranPackageDisk {
  /// The active package, or `null` when none is installed. A pointer to a
  /// package whose manifest is missing or not the pinned one reads as none.
  Future<InstalledQuran?> active();

  /// Paths of [installed]'s files that are missing or have the wrong size
  /// (fast; run at every start).
  Future<List<String>> quickCheck(InstalledQuran installed);

  /// Paths of [installed]'s files whose SHA-256 differs from the manifest
  /// (reads every byte), reporting files checked through [progress].
  Future<List<String>> fullCheck(
    InstalledQuran installed, {
    void Function(int done, int total)? progress,
  });

  /// The download in progress, or `null`.
  Future<StagedQuran?> staging();

  /// Starts a staging directory holding [manifestBytes] (already checked
  /// against the pin) and its decoded [manifest]; replaces an older one.
  Future<Result<StagedQuran, QuranFailure>> startStaging(
    List<int> manifestBytes,
    QuranManifest manifest,
  );

  /// Path of the partial download of package file [path] in [directory].
  String partPath(String directory, String path);

  /// Checks the partial download of [file] in [directory] against the
  /// manifest; when it matches, moves it into place and records it,
  /// otherwise deletes it and fails with [QuranIntegrityFailed].
  Future<Result<void, QuranFailure>> commitFile(
    String directory,
    QuranManifestFile file,
  );

  /// Deletes [path] and its partial download from [directory], so a repair
  /// downloads it again.
  Future<void> discardFile(String directory, String path);

  /// Makes [staged] the active package in one rename, then deletes the
  /// previous one. Until the rename the previous package stays usable.
  Future<Result<InstalledQuran, QuranFailure>> activate(StagedQuran staged);

  /// Deletes the active package, any staging directory and the pointer.
  Future<Result<void, QuranFailure>> removeAll();
}
