import 'package:daily_muslim/features/athan/application/athan_preferences.dart';
import 'package:daily_muslim/features/athan/application/athan_sound_options.dart';
import 'package:daily_muslim/features/athan/domain/athan_voice.dart';
import 'package:daily_muslim/features/athan/domain/voice_download_status.dart';
import 'package:daily_muslim/features/athan/domain/voice_failure.dart';
import 'package:daily_muslim/features/athan/presentation/athan_page.dart';
import 'package:daily_muslim/features/athan/presentation/athan_voice_providers.dart';
import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/features/shell/presentation/scroll_insets.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Which Athan a voice choice is for (§15 D111, REQ-ALM-052).
enum VoiceSlot {
  /// Every prayer but Fajr, and Fajr while it follows the Athan.
  athan,

  /// Fajr's own choice.
  fajr,
}

/// The Athan page's row for one [slot]: the voice that plays now, and a
/// warning when the chosen one is gone and another plays (REQ-ALM-053).
final class VoiceSlotTile extends ConsumerWidget {
  /// The row of [slot].
  const new({required this.slot, super.key});

  /// Athan or Fajr.
  final VoiceSlot slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final options = ref.watch(athanSoundOptionsProvider).value;
    final catalog = ref.watch(voiceCatalogProvider).value ?? const [];
    final athan = ref.watch(athanSoundSettingProvider).value;
    final fajr = ref.watch(fajrSoundSettingProvider).value;
    final lang = Localizations.localeOf(context).languageCode;
    String name(String id) => soundName(l, id, catalog, lang);
    final (playing, fellBack, chosen) = switch ((slot, options)) {
      (_, null) => (null, false, null),
      (VoiceSlot.athan, final AthanSoundOptions o) => (
        o.athanSound(athan),
        o.athanFellBack(athan),
        athan,
      ),
      (VoiceSlot.fajr, final AthanSoundOptions o) => (
        o.fajrSound(fajr, athan),
        o.fajrFellBack(fajr, athan),
        fajr,
      ),
    };
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        slot == VoiceSlot.athan ? l.athanVoice : l.athanFajrVoice,
        style: theme.textTheme.labelMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            switch ((slot, fajr, playing)) {
              (_, _, null) => '',
              (VoiceSlot.fajr, null, _) => l.athanVoiceSameAsAthan,
              (_, _, final String id) => name(id),
            },
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (fellBack && chosen != null && playing != null)
            Text(
              l.athanVoiceMissing(name(chosen), name(playing)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => AthanVoicesPage(slot: slot)),
      ),
    );
  }

  /// The name of sound [id]: the device tone, a bundled sound, a catalog
  /// voice in [lang], or a voice this build no longer offers.
  static String soundName(
    AppLocalizations l,
    String id,
    List<AthanVoice> catalog,
    String lang,
  ) {
    if (id == AthanPreferences.deviceAlarmSoundId) return l.athanVoiceDevice;
    for (final v in catalog) {
      if (v.soundId == id) return v.name(lang);
    }
    return id.startsWith(AthanPage.testSoundPrefix)
        ? l.athanSoundTest
        : l.athanVoiceUnavailable;
  }
}

/// Choosing the voice of one [slot] (§15 D111): the device alarm tone, for
/// Fajr "same as the Athan", the bundled sounds and every voice of the
/// catalog this slot may play, each with its kind, length, size, source and
/// licence, and its download, preview and removal.
final class AthanVoicesPage extends ConsumerWidget {
  /// The page of [slot].
  const new({required this.slot, super.key});

  /// Athan or Fajr.
  final VoiceSlot slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final write = ref.watch(writeSettingProvider);
    final key = slot == VoiceSlot.athan
        ? AppSettings.soundId
        : AppSettings.fajrSoundId;
    final chosen = ref.watch(
      slot == VoiceSlot.athan
          ? athanSoundSettingProvider
          : fajrSoundSettingProvider,
    );
    final options = ref.watch(athanSoundOptionsProvider).value;
    final catalog = ref.watch(voiceCatalogProvider).value ?? const [];
    final installed =
        ref.watch(voiceInventoryProvider).value?.installed ?? const {};
    final voices = [
      for (final v in catalog)
        if (slot == VoiceSlot.fajr || !v.fajrOnly) v,
    ];
    final stored = chosen.value;
    final playing = switch ((slot, options)) {
      (_, null) => null,
      (VoiceSlot.athan, final AthanSoundOptions o) => o.athanSound(stored),
      (VoiceSlot.fajr, final AthanSoundOptions o) => o.fajrSound(
        stored,
        ref.watch(athanSoundSettingProvider).value,
      ),
    };
    // Fajr shows "same as the Athan" as chosen until the user picks a voice.
    bool isSelected(String? id) =>
        slot == VoiceSlot.fajr && stored == null ? id == null : id == playing;
    void choose(String? id) => write.write(key, id);
    return Scaffold(
      appBar: AppBar(
        title: Text(slot == VoiceSlot.athan ? l.athanVoice : l.athanFajrVoice),
      ),
      body: ListView(
        padding: scrollInsets(context),
        children: [
          RawdahSection(
            footnote: l.athanVoicesOffline,
            children: [
              _ChoiceRow(
                title: l.athanVoiceDevice,
                subtitle: l.athanVoiceDeviceNote,
                selected: isSelected(AthanPreferences.deviceAlarmSoundId),
                onTap: () => choose(AthanPreferences.deviceAlarmSoundId),
              ),
              if (slot == VoiceSlot.fajr)
                _ChoiceRow(
                  title: l.athanVoiceSameAsAthan,
                  selected: isSelected(null),
                  onTap: () => choose(null),
                ),
              for (final id in options?.athan ?? const <String>[])
                if (!installed.contains(id))
                  _ChoiceRow(
                    title: VoiceSlotTile.soundName(
                      l,
                      id,
                      catalog,
                      Localizations.localeOf(context).languageCode,
                    ),
                    selected: isSelected(id),
                    onTap: () => choose(id),
                  ),
            ],
          ),
          RawdahSection(
            title: l.athanVoicesDownloadable,
            footnote: l.athanVoicesPlatformNote,
            children: [
              if (voices.isEmpty)
                ListTile(title: Text(l.athanVoicesNone))
              else
                for (final v in voices)
                  _VoiceRow(
                    voice: v,
                    downloaded: installed.contains(v.soundId),
                    selected: isSelected(v.soundId),
                    onSelect: () => choose(v.soundId),
                    onRemoved: () {
                      // Removing the chosen voice is the user's own change:
                      // the choice goes back to its default, shown at once.
                      if (stored == v.soundId) choose(null);
                    },
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A plain choice: the device tone, "same as the Athan" or a bundled sound.
final class _ChoiceRow extends StatelessWidget {
  const new({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final note = subtitle;
    return ListTile(
      leading: _SelectionMark(selected: selected, enabled: true),
      title: Text(title),
      subtitle: note == null ? null : Text(note),
      selected: selected,
      onTap: onTap,
    );
  }
}

final class _SelectionMark extends StatelessWidget {
  const new({required this.selected, required this.enabled});

  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      selected: selected,
      label: selected ? l.athanVoiceSelected : null,
      child: Icon(
        selected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: selected
            ? RawdahPalette.enabled
            : enabled
            ? Theme.of(context).colorScheme.outline
            : Theme.of(context).disabledColor,
      ),
    );
  }
}

/// One catalog voice: its facts, credit and the action its state allows.
final class _VoiceRow extends ConsumerWidget {
  const new({
    required this.voice,
    required this.downloaded,
    required this.selected,
    required this.onSelect,
    required this.onRemoved,
  });

  final AthanVoice voice;
  final bool downloaded;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final type = DmType.of(style.locale);
    final theme = Theme.of(context);
    final status = ref.watch(voiceDownloadsProvider)[voice.soundId];
    final downloads = ref.read(voiceDownloadsProvider.notifier);
    final previewing = ref.watch(voicePreviewingProvider) == voice.soundId;
    final lang = Localizations.localeOf(context).languageCode;
    final facts = [
      if (voice.fajrOnly) l.athanVoiceKindFajr else l.athanVoiceKindAthan,
      _duration(voice.durationMs, style),
      QuranFormat.bytes(voice.bytes, style),
    ].join(' · ');
    return ListTile(
      isThreeLine: true,
      leading: _SelectionMark(selected: selected, enabled: downloaded),
      selected: selected,
      onTap: downloaded ? onSelect : null,
      title: Text(voice.name(lang), style: type.rowName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(facts, style: type.supporting),
          if (voice.review == VoiceReview.pending)
            Text(
              l.athanVoiceReviewPending,
              style: type.supporting.copyWith(color: RawdahPalette.goldInk),
            ),
          InkWell(
            onTap: () => context.push(const AttributionsRoute().location),
            child: Text(
              l.athanVoiceCredit(
                _licence(voice.credit.licence),
                voice.credit.creator,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          if (downloaded) Text(l.athanVoiceOnPhone, style: type.supporting),
          switch (status) {
            VoiceDownloading(:final fraction) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: LinearProgressIndicator(
                value: fraction,
                semanticsLabel: l.athanVoiceDownloading,
                semanticsValue: style.digits.apply(
                  '${(fraction * 100).round()}%',
                ),
              ),
            ),
            VoiceDownloadFailed(:final failure) => Text(
              _failure(l, failure, style),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            VoiceDownloaded() || null => const SizedBox.shrink(),
          },
        ],
      ),
      trailing: switch ((downloaded, status)) {
        (_, VoiceDownloading()) => IconButton(
          tooltip: l.athanVoiceCancel,
          icon: const Icon(Icons.close),
          onPressed: () => downloads.cancel(voice),
        ),
        (true, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: previewing ? l.athanVoiceStop : l.athanVoicePreview,
              icon: Icon(previewing ? Icons.stop : Icons.play_arrow),
              onPressed: () => ref
                  .read(voicePreviewingProvider.notifier)
                  .toggle(voice, ref.read(voiceDiskProvider).filePath(voice)),
            ),
            IconButton(
              tooltip: l.athanVoiceRemove,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                if (previewing) {
                  await ref.read(voicePreviewingProvider.notifier).stop();
                }
                await downloads.remove(voice);
                onRemoved();
              },
            ),
          ],
        ),
        (false, VoiceDownloadFailed()) => TextButton(
          onPressed: () => downloads.download(voice),
          child: Text(l.athanVoiceRetry),
        ),
        (false, _) => TextButton(
          onPressed: () => downloads.download(voice),
          child: Text(l.athanVoiceDownload),
        ),
      },
    );
  }

  static String _duration(int ms, DisplayStyle style) {
    final seconds = (ms / 1000).round();
    final s = (seconds % 60).toString().padLeft(2, '0');
    return style.digits.apply('${seconds ~/ 60}:$s');
  }

  /// SPDX id to the licence's usual short name, e.g. `CC BY 3.0`.
  static String _licence(String spdx) => switch (spdx) {
    'CC0-1.0' => 'CC0 1.0',
    _ => switch (RegExp(r'^CC-(.+)-([0-9.]+)$').firstMatch(spdx)) {
      final RegExpMatch m => 'CC ${m[1]} ${m[2]}',
      null => spdx,
    },
  };

  static String _failure(
    AppLocalizations l,
    VoiceFailure failure,
    DisplayStyle style,
  ) => switch (failure) {
    VoiceOffline() => l.athanVoiceFailOffline,
    VoiceServerRefused() => l.athanVoiceFailServer,
    VoiceNoSpace(:final neededBytes) => l.athanVoiceFailSpace(
      QuranFormat.bytes(neededBytes, style),
    ),
    VoiceIntegrityFailed() => l.athanVoiceFailIntegrity,
    VoiceStorageFailed() => l.athanVoiceFailStorage,
    VoiceCancelled() => l.athanVoiceFailCancelled,
  };
}
