import 'dart:async';

import 'package:daily_muslim/features/quran/application/check_quran_package.dart';
import 'package:daily_muslim/features/quran/application/download_quran_package.dart';
import 'package:daily_muslim/features/quran/application/remove_quran_package.dart';
import 'package:daily_muslim/features/quran/application/repair_quran_package.dart';
import 'package:daily_muslim/features/quran/application/verify_quran_package.dart';
import 'package:daily_muslim/features/quran/domain/download_cancel.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Turns the reader's actions on the Quran download into use-case calls
/// and keeps the latest [QuranPackageStatus] (§15 D107). It lives as long
/// as the app, so a download continues while the reader visits other tabs;
/// closing the app stops it, and the next attempt resumes.
final class QuranPackageController extends Notifier<QuranPackageStatus> {
  DownloadCancel? _cancel;
  StreamSubscription<QuranPackageStatus>? _running;

  @override
  QuranPackageStatus build() {
    ref.onDispose(() => _running?.cancel());
    unawaited(check());
    return const QuranChecking();
  }

  /// Re-reads the status from disk (no network). When the app carries its
  /// own copy and nothing is installed, installs it at once (§15 D117),
  /// unless the reader removed the Quran themself; an installed package
  /// older than the copy is replaced the same way (§15 D123), the old one
  /// staying readable until the new one is verified and active.
  Future<void> check() async {
    final checked = await CheckQuranPackage(
      ref.read(quranPackageDiskProvider),
      ref.read(buildSearchIndexProvider),
      ref.read(searchIndexIsCurrentProvider),
    )();
    if (!ref.mounted || _running != null) return;
    state = checked;
    final pending = switch (checked) {
      QuranNotInstalled(failure: null) => true,
      QuranPaused(failure: null, current: null) => true,
      QuranReady(updateAvailable: true) => true,
      _ => false,
    };
    if (pending && await _installsFromApp() && ref.mounted) download();
  }

  Future<bool> _installsFromApp() async =>
      await ref.read(quranBundleProvider)() &&
      !await ref
          .read(watchSettingProvider)
          .watch(AppSettings.quranRemoved)
          .first;

  /// Starts or resumes the download.
  void download() {
    if (_running != null) return;
    unawaited(
      ref.read(writeSettingProvider).write(AppSettings.quranRemoved, false),
    );
    _follow(
      DownloadQuranPackage(
        disk: ref.read(quranPackageDiskProvider),
        origin: ref.read(quranOriginProvider),
        freeSpace: ref.read(readFreeSpaceProvider),
        buildIndex: ref.read(buildSearchIndexProvider),
        accept: ref.read(acceptManifestProvider),
      ),
    );
  }

  /// Downloads again the damaged files of the active package.
  void repair() {
    if (_running != null) return;
    if (state case QuranDamaged(:final installed, :final badFiles)) {
      final cancel = _cancel = DownloadCancel();
      _listen(
        RepairQuranPackage(
          disk: ref.read(quranPackageDiskProvider),
          origin: ref.read(quranOriginProvider),
          buildIndex: ref.read(buildSearchIndexProvider),
        )(installed, badFiles, cancel),
      );
    }
  }

  /// Stops the download; what was verified is kept.
  void cancel() => _cancel?.cancel();

  /// Checks every byte of the active package.
  Future<void> verify({void Function(int done, int total)? progress}) async {
    if (state case QuranReady(:final installed)) {
      final verdict = await VerifyQuranPackage(
        ref.read(quranPackageDiskProvider),
      )(installed, progress: progress);
      if (ref.mounted) state = verdict;
    }
  }

  /// Removes the package and any partial download; notes are kept.
  Future<bool> remove() async {
    _cancel?.cancel();
    await _running?.cancel();
    _running = null;
    final removed = await RemoveQuranPackage(
      ref.read(quranPackageDiskProvider),
    )();
    if (!ref.mounted) return false;
    await ref.read(writeSettingProvider).write(AppSettings.quranRemoved, true);
    if (!ref.mounted) return false;
    state = const QuranNotInstalled();
    return removed is Ok;
  }

  void _follow(DownloadQuranPackage download) {
    final cancel = _cancel = DownloadCancel();
    _listen(download(cancel));
  }

  void _listen(Stream<QuranPackageStatus> statuses) {
    _running = statuses.listen(
      (status) {
        if (ref.mounted) state = status;
      },
      onDone: () {
        _running = null;
        _cancel = null;
      },
    );
  }
}
