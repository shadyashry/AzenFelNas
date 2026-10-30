import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/download_progress.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_package_controller.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/shell/presentation/scroll_insets.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Quran download before the reader opens (§15 D107, REQ-QRN-010):
/// what it is and where it comes from, its measured sizes, the one action
/// that fits the state, progress, and every failure in words.
final class QuranDownloadView extends ConsumerWidget {
  /// The view of [status].
  const new({required this.status, super.key});

  /// Not ready: not installed, downloading, paused, installing or damaged.
  final QuranPackageStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final controller = ref.read(quranPackageProvider.notifier);
    return ListView(
      padding: scrollInsets(context, horizontal: 20, top: 12),
      children: [
        const Center(
          child: RawdahGlyph(
            kind: RawdahGlyphKind.mushaf,
            color: RawdahPalette.gold,
            size: 72,
          ),
        ),
        const SizedBox(height: 16),
        Text(l.quranDownloadBody, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        _Sizes(style: style),
        const SizedBox(height: 20),
        _StatusPanel(status: status, style: style),
        const SizedBox(height: 12),
        _Action(status: status, controller: controller),
        const SizedBox(height: 24),
        Text(
          l.quranUninstallNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Text(l.quranAttribution, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Text(
          l.quranJuzAttribution,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

final class _Sizes extends StatelessWidget {
  const new({required this.style});

  final DisplayStyle style;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    String size(int bytes) => QuranFormat.bytes(bytes, style);
    return RawdahSection(
      title: l.quranStorage,
      children: [
        ListTile(
          title: Text(l.quranDownloadSize(size(QuranEditionPin.downloadBytes))),
        ),
        ListTile(
          title: Text(
            l.quranInstalledSize(
              size(
                QuranEditionPin.downloadBytes +
                    QuranEditionPin.manifestBytes +
                    QuranEditionPin.searchIndexBytes,
              ),
            ),
          ),
        ),
        ListTile(
          title: Text(
            l.quranRequiredSpace(size(QuranEditionPin.requiredFreeBytes)),
          ),
        ),
      ],
    );
  }
}

final class _StatusPanel extends StatelessWidget {
  const new({required this.status, required this.style});

  final QuranPackageStatus status;
  final DisplayStyle style;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    String describe(QuranFailure f) => QuranFormat.failure(l, f, style);
    final (
      String? line,
      DownloadProgress? progress,
      bool busy,
    ) = switch (status) {
      QuranNotInstalled(:final failure?) => (describe(failure), null, false),
      QuranDownloading(:final progress) => (
        l.quranDownloading(
          QuranFormat.bytes(progress.doneBytes, style),
          QuranFormat.bytes(progress.totalBytes, style),
        ),
        progress,
        true,
      ),
      QuranPaused(:final progress, :final failure) => (
        failure == null ? l.quranPaused : describe(failure),
        progress,
        false,
      ),
      QuranInstalling() => (l.quranInstalling, null, true),
      QuranDamaged(:final badFiles, :final failure) => (
        [
          l.quranDamagedTitle,
          l.quranDamagedBody(
            badFiles.length,
            QuranFormat.number(badFiles.length, style),
          ),
          if (failure != null) describe(failure),
        ].join('\n'),
        null,
        false,
      ),
      QuranReady(updateAvailable: true) => (l.quranUpdateBody, null, false),
      QuranNotInstalled() || QuranChecking() || QuranReady() => (
        null,
        null,
        false,
      ),
    };
    if (line == null) return const SizedBox.shrink();
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (progress != null || busy)
            LinearProgressIndicator(
              value: progress?.fraction,
              semanticsLabel: line,
            ),
          const SizedBox(height: 8),
          Text(line),
        ],
      ),
    );
  }
}

final class _Action extends StatelessWidget {
  const new({required this.status, required this.controller});

  final QuranPackageStatus status;
  final QuranPackageController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return switch (status) {
      QuranDownloading() => OutlinedButton.icon(
        onPressed: controller.cancel,
        icon: const Icon(Icons.stop_circle_outlined),
        label: Text(l.quranCancel),
      ),
      QuranReady(updateAvailable: true) => FilledButton.icon(
        onPressed: controller.download,
        icon: const Icon(Icons.system_update_alt),
        label: Text(l.quranUpdate),
      ),
      QuranInstalling() ||
      QuranChecking() ||
      QuranReady() => const SizedBox.shrink(),
      QuranPaused() => FilledButton.icon(
        onPressed: controller.download,
        icon: const Icon(Icons.download),
        label: Text(l.quranResume),
      ),
      QuranDamaged() => FilledButton.icon(
        onPressed: controller.repair,
        icon: const Icon(Icons.build_outlined),
        label: Text(l.quranRepair),
      ),
      QuranNotInstalled() => FilledButton.icon(
        onPressed: controller.download,
        icon: const Icon(Icons.download),
        label: Text(l.quranDownloadAction),
      ),
    };
  }
}
