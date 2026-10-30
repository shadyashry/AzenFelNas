import 'package:daily_muslim/features/quran/domain/download_progress.dart';
import 'package:daily_muslim/features/quran/domain/installed_quran.dart';
import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:meta/meta.dart';

/// Where the offline Quran package stands on this device (§15 D106).
/// The reader opens only on [QuranReady]; "Ready offline" is shown only
/// after every file was verified and the local search answered.
@immutable
sealed class QuranPackageStatus {
  const new();
}

/// Being checked at start.
final class QuranChecking extends QuranPackageStatus {
  /// The status.
  const new();
}

/// Nothing downloaded, and no partial download to resume.
final class QuranNotInstalled extends QuranPackageStatus {
  /// The status, with the [failure] of the last attempt if any.
  const new({this.failure});

  /// Why the last attempt stopped.
  final QuranFailure? failure;
}

/// Downloading and verifying files.
final class QuranDownloading extends QuranPackageStatus {
  /// The status at [progress].
  const new(this.progress);

  /// Progress so far.
  final DownloadProgress progress;
}

/// A partial download is kept and can be resumed.
final class QuranPaused extends QuranPackageStatus {
  /// The status at [progress], stopped by [failure].
  const new(this.progress, {this.failure});

  /// Progress kept on disk.
  final DownloadProgress progress;

  /// Why it stopped (`null` when the app was closed).
  final QuranFailure? failure;
}

/// All files verified; building the local search index and activating.
final class QuranInstalling extends QuranPackageStatus {
  /// The status.
  const new();
}

/// Verified and active: everything works offline.
final class QuranReady extends QuranPackageStatus {
  /// The status of [installed].
  const new(this.installed);

  /// The active package.
  final InstalledQuran installed;
}

/// The active package has missing or damaged files; reading is blocked
/// until they are repaired.
final class QuranDamaged extends QuranPackageStatus {
  /// The status of [installed] with its [badFiles]; [failure] when a
  /// repair attempt stopped.
  const new(this.installed, this.badFiles, {this.failure});

  /// The package.
  final InstalledQuran installed;

  /// Paths inside the package that failed the check.
  final List<String> badFiles;

  /// Why the last repair stopped.
  final QuranFailure? failure;
}
