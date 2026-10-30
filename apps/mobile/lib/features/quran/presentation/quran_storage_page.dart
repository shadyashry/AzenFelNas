import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/presentation/quran_download_view.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/shell/presentation/scroll_insets.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Quran download (§15 D106, REQ-QRN-061): its status, edition and
/// measured size on this device, a full check of every file against the
/// official copy, and removal (notes are kept).
final class QuranStoragePage extends ConsumerWidget {
  /// The page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final status = ref.watch(quranPackageProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.quranStorage)),
      body: switch (status) {
        QuranReady(updateAvailable: false) => const _Installed(),
        _ => QuranDownloadView(status: status),
      },
    );
  }
}

final NotifierProvider<_Verifying, (int, int)?> _verifyingProvider =
    NotifierProvider.autoDispose<_Verifying, (int, int)?>(_Verifying.new);

/// Files checked so far, or `null` when no check runs.
final class _Verifying extends Notifier<(int, int)?> {
  @override
  (int, int)? build() => null;

  Future<void> run() async {
    state = (0, 0);
    await ref
        .read(quranPackageProvider.notifier)
        .verify(
          progress: (done, total) {
            if (ref.mounted) state = (done, total);
          },
        );
    if (ref.mounted) state = null;
  }
}

final class _Installed extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final status = ref.watch(quranPackageProvider);
    final verifying = ref.watch(_verifyingProvider);
    if (status is! QuranReady) return const SizedBox.shrink();
    final installed = status.installed;
    final manifest = installed.manifest;
    return ListView(
      padding: scrollInsets(context, horizontal: 4),
      children: [
        RawdahSection(
          title: l.quranReadyOffline,
          children: [
            ListTile(
              leading: const Icon(
                Icons.offline_pin,
                color: RawdahPalette.enabled,
              ),
              title: Text(l.quranReadyOffline),
              subtitle: Text(
                l.quranEdition(
                  style.digits.apply(manifest.printEdition),
                  style.digits.apply(manifest.version),
                ),
              ),
            ),
            ListTile(
              title: Text(
                l.quranOnDevice(
                  QuranFormat.bytes(installed.installedBytes, style),
                ),
              ),
              subtitle: Text(
                l.quranDownloadSize(
                  QuranFormat.bytes(QuranEditionPin.downloadBytes, style),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: switch (verifying) {
            (final done, final total) => Text(
              l.quranVerifying(
                QuranFormat.number(done, style),
                QuranFormat.number(total, style),
              ),
            ),
            null => OutlinedButton.icon(
              icon: const Icon(Icons.verified_outlined),
              label: Text(l.quranVerify),
              onPressed: () async {
                await ref.read(_verifyingProvider.notifier).run();
                if (!context.mounted) return;
                if (ref.read(quranPackageProvider) is QuranReady) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l.quranVerified(
                          manifest.files.length,
                          QuranFormat.number(manifest.files.length, style),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: Text(l.quranRemove),
            onPressed: verifying == null ? () => _remove(context, ref) : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${l.quranUninstallNote}\n\n'
            '${l.quranAttribution}\n${l.quranJuzAttribution}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.quranRemoveTitle),
        content: Text(
          l.quranRemoveBody(
            QuranFormat.bytes(QuranEditionPin.downloadBytes, style),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.quranKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.quranRemoveConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(quranPackageProvider.notifier).remove();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.quranRemoved)));
  }
}
