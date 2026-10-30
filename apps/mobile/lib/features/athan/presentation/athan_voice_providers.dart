import 'dart:async';

import 'package:daily_muslim/features/athan/application/athan_sound_options.dart';
import 'package:daily_muslim/features/athan/application/check_voices.dart';
import 'package:daily_muslim/features/athan/application/download_voice.dart';
import 'package:daily_muslim/features/athan/application/remove_voice.dart';
import 'package:daily_muslim/features/athan/domain/athan_playback.dart';
import 'package:daily_muslim/features/athan/domain/athan_voice.dart';
import 'package:daily_muslim/features/athan/domain/voice_download_status.dart';
import 'package:daily_muslim/features/athan/domain/voice_ports.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/quran/domain/download_cancel.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The voice catalog of this build (bound in `app/di.dart`).
final readVoiceCatalogProvider = Provider<ReadVoiceCatalog>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The voices on disk (bound in `app/di.dart`).
final voiceDiskProvider = Provider<VoiceDisk>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The voices' CDN (bound in `app/di.dart`).
final voiceOriginProvider = Provider<VoiceOrigin>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The native alarm player's copy of the voices (bound in `app/di.dart`).
final voiceAudioHostProvider = Provider<VoiceAudioHost>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The preview player (bound in `app/di.dart`).
final voicePreviewProvider = Provider<VoicePreview>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The Athan playing now, bound in `app/di.dart`; none until bound
/// (§15 D118).
final athanPlaybackProvider = Provider<AthanPlayback>(
  (ref) => const _NoPlayback(),
);

/// Whether an Athan is playing now: asked once, then followed.
final StreamProvider<bool> athanPlayingProvider = StreamProvider((ref) async* {
  final playback = ref.watch(athanPlaybackProvider);
  yield await playback.athanPlaying();
  yield* playback.athanChanges;
});

final class _NoPlayback implements AthanPlayback {
  const new();

  @override
  Future<bool> athanPlaying() async => false;

  @override
  Future<void> stopAthan() async {}

  @override
  Stream<bool> get athanChanges => const Stream.empty();
}

/// The downloadable voices this build offers (§15 D111).
final FutureProvider<List<AthanVoice>> voiceCatalogProvider =
    FutureProvider<List<AthanVoice>>(
      (ref) => ref.watch(readVoiceCatalogProvider).call(),
    );

/// The downloaded voices, checked against their pins once per app start and
/// again after every download or removal (REQ-ALM-051). No network.
final FutureProvider<VoiceInventory> voiceInventoryProvider =
    FutureProvider<VoiceInventory>((ref) async {
      final catalog = await ref.watch(voiceCatalogProvider.future);
      return await CheckVoices(
        disk: ref.watch(voiceDiskProvider),
        host: ref.watch(voiceAudioHostProvider),
      )(catalog);
    });

/// What may play for the Athan and for Fajr now: bundled sounds and
/// downloaded voices (§15 D111).
final FutureProvider<AthanSoundOptions> athanSoundOptionsProvider =
    FutureProvider.autoDispose<AthanSoundOptions>((ref) async {
      final bundled = await ref.watch(athanSoundsProvider.future);
      final catalog = await ref.watch(voiceCatalogProvider.future);
      final inventory = await ref.watch(voiceInventoryProvider.future);
      return AthanSoundOptions.of(
        bundled: bundled,
        catalog: catalog,
        installed: inventory.installed,
      );
    });

/// Voice downloads in progress or failed, by `soundId` (§15 D111). It lives
/// as long as the app, so a download continues while the user leaves the
/// page; closing the app stops it, and the next attempt resumes.
final NotifierProvider<VoiceDownloads, Map<String, VoiceDownloadStatus>>
voiceDownloadsProvider =
    NotifierProvider<VoiceDownloads, Map<String, VoiceDownloadStatus>>(
      VoiceDownloads.new,
    );

/// Turns download, cancel and remove taps into use-case calls.
final class VoiceDownloads extends Notifier<Map<String, VoiceDownloadStatus>> {
  final Map<String, DownloadCancel> _cancels = {};

  @override
  Map<String, VoiceDownloadStatus> build() {
    ref.onDispose(() {
      for (final c in _cancels.values) {
        c.cancel();
      }
    });
    return const {};
  }

  /// Starts or resumes [voice]'s download; a second tap while it runs does
  /// nothing.
  void download(AthanVoice voice) {
    if (_cancels.containsKey(voice.soundId)) return;
    final cancel = _cancels[voice.soundId] = DownloadCancel();
    final run = DownloadVoice(
      disk: ref.read(voiceDiskProvider),
      origin: ref.read(voiceOriginProvider),
      host: ref.read(voiceAudioHostProvider),
      freeSpace: ref.read(readFreeSpaceProvider),
    );
    unawaited(_follow(voice, run(voice, cancel)));
  }

  /// Stops [voice]'s download; the bytes so far are kept.
  void cancel(AthanVoice voice) => _cancels[voice.soundId]?.cancel();

  /// Deletes [voice] from the phone.
  Future<void> remove(AthanVoice voice) async {
    cancel(voice);
    await RemoveVoice(
      disk: ref.read(voiceDiskProvider),
      host: ref.read(voiceAudioHostProvider),
    )(voice);
    if (!ref.mounted) return;
    state = {...state}..remove(voice.soundId);
    ref.invalidate(voiceInventoryProvider);
  }

  Future<void> _follow(
    AthanVoice voice,
    Stream<VoiceDownloadStatus> statuses,
  ) async {
    await for (final status in statuses) {
      if (!ref.mounted) return;
      state = {...state, voice.soundId: status};
    }
    _cancels.remove(voice.soundId);
    if (!ref.mounted) return;
    if (state[voice.soundId] is VoiceDownloaded) {
      state = {...state}..remove(voice.soundId);
      ref.invalidate(voiceInventoryProvider);
    }
  }
}

/// The voice being previewed, or null (REQ-ALM-054): one at a time; it
/// ends by itself, on Stop, when the page closes or when an Athan starts.
final NotifierProvider<VoicePreviewing, String?> voicePreviewingProvider =
    NotifierProvider.autoDispose<VoicePreviewing, String?>(
      VoicePreviewing.new,
    );

/// Starts and stops previews of downloaded voices; the local file only.
final class VoicePreviewing extends Notifier<String?> {
  @override
  String? build() {
    final preview = ref.watch(voicePreviewProvider);
    final ended = preview.ended.listen((_) {
      if (ref.mounted) state = null;
    });
    ref.onDispose(() {
      unawaited(ended.cancel());
      unawaited(preview.stop());
    });
    return null;
  }

  /// Plays [voice] from [path], or stops it when it is the one playing.
  Future<void> toggle(AthanVoice voice, String path) async {
    final preview = ref.read(voicePreviewProvider);
    if (state == voice.soundId) {
      await preview.stop();
      if (ref.mounted) state = null;
      return;
    }
    final started = await preview.play(path);
    if (ref.mounted) state = started ? voice.soundId : null;
  }

  /// Stops any preview.
  Future<void> stop() async {
    await ref.read(voicePreviewProvider).stop();
    if (ref.mounted) state = null;
  }
}
