import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_reader.dart';
import 'package:daily_muslim/features/quran/presentation/quran_download_view.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/shell/presentation/app_tab_bar.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Quran tab (§15 D107, D123): the reader once the package is ready
/// offline, the download and its states before that. With the reader the
/// tab bar stays in a portrait window, so the familiar navigation is always
/// there and the page never changes size when the reader's controls come
/// and go; a landscape window gives the reader the whole screen (its menu
/// leads Home).
final class QuranPage extends ConsumerWidget {
  /// The page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final status = ref.watch(quranPackageProvider);
    // During an update the installed package stays readable.
    final readable = readablePackage(status);
    final size = MediaQuery.sizeOf(context);
    final tabs = readable == null || size.width <= size.height;
    return Scaffold(
      appBar: readable != null
          ? null
          : AppBar(title: Text(l.quranTitle), automaticallyImplyLeading: false),
      bottomNavigationBar: tabs
          ? const AppTabBar(current: RawdahTab.quran)
          : null,
      body: switch (status) {
        _ when readable != null => MushafReader(installed: readable),
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
