import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_reader.dart';
import 'package:daily_muslim/features/quran/presentation/quran_download_view.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/features/shell/presentation/app_tab_bar.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Quran tab (§15 D106): the reader once the package is ready offline,
/// the download and its states before that. The tab bar hides with the
/// reader's controls, so the page can use the whole screen.
final class QuranPage extends ConsumerWidget {
  /// The page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final status = ref.watch(quranPackageProvider);
    final chrome = switch (status) {
      QuranReady() => ref.watch(readerProvider.select((s) => s.chromeVisible)),
      _ => true,
    };
    return Scaffold(
      appBar: status is QuranReady
          ? null
          : AppBar(title: Text(l.quranTitle), automaticallyImplyLeading: false),
      bottomNavigationBar: chrome
          ? const AppTabBar(current: RawdahTab.quran)
          : null,
      body: switch (status) {
        QuranReady(:final installed) => MushafReader(installed: installed),
        QuranChecking() => _Waiting(label: l.quranChecking),
        QuranNotInstalled() ||
        QuranDownloading() ||
        QuranPaused() ||
        QuranInstalling() ||
        QuranDamaged() => QuranDownloadView(status: status),
      },
    );
  }
}

final class _Waiting extends StatelessWidget {
  const new({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(label, textAlign: TextAlign.center),
      ],
    ),
  );
}
