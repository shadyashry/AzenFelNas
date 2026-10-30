import 'package:daily_muslim/features/quran/domain/download_progress.dart';
import 'package:daily_muslim/features/quran/domain/installed_quran.dart';
import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:meta/meta.dart';

/// Where the offline Quran package stands on this device (§15 D107).
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
  /// The status at [progress]; [current] is the package still readable
  /// during an update.
  const new(this.progress, {this.current});

  /// Progress so far.
  final DownloadProgress progress;

  /// The active package, if any.
  final InstalledQuran? current;
}

/// A partial download is kept and can be resumed.
final class QuranPaused extends QuranPackageStatus {
  /// The status at [progress], stopped by [failure]; [current] is the
  /// package still readable during an update.
  const new(this.progress, {this.failure, this.current});

  /// Progress kept on disk.
  final DownloadProgress progress;

  /// Why it stopped (`null` when the app was closed).
  final QuranFailure? failure;

  /// The active package, if any.
  final InstalledQuran? current;
}

/// All files verified; building the local search index and activating.
final class QuranInstalling extends QuranPackageStatus {
  /// The status; [current] is the package still readable meanwhile.
  const new({this.current});

  /// The active package, if any.
  final InstalledQuran? current;
}

/// Verified and active: everything works offline.
final class QuranReady extends QuranPackageStatus {
  /// The status of [installed]; [updateAvailable] when this build pins a
  /// newer package.
  const new(this.installed, {this.updateAvailable = false});

  /// The active package.
  final InstalledQuran installed;

  /// Whether a newer package can be downloaded (the current one stays
  /// readable until it is ready).
  final bool updateAvailable;
}

/// The package the reader can show during [status], if any.
InstalledQuran? readablePackage(QuranPackageStatus status) => switch (status) {
  QuranReady(:final installed) => installed,
  QuranDownloading(:final current) ||
  QuranPaused(:final current) ||
  QuranInstalling(:final current) => current,
  QuranChecking() || QuranNotInstalled() || QuranDamaged() => null,
};

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
