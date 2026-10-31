import 'dart:async';

import 'package:daily_muslim/features/athan/presentation/athan_voice_providers.dart';
import 'package:daily_muslim/features/radio/domain/radio_catalog.dart';
import 'package:daily_muslim/features/radio/domain/radio_failure.dart';
import 'package:daily_muslim/features/radio/domain/radio_playback.dart';
import 'package:daily_muslim/features/radio/domain/radio_ports.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:daily_muslim/features/radio/presentation/radio_providers.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// What the Radio screens show besides the player's state (§15 D122).
@immutable
final class RadioView {
  /// The view.
  const new({
    this.catalog,
    this.selectedId,
    this.loaded = false,
    this.refreshing = false,
    this.refreshFailed = false,
  });

  /// The station list, kept or fresh; `null` before the first one.
  final RadioCatalog? catalog;

  /// The chosen station; the first featured one until the listener picks.
  final RadioStationId? selectedId;

  /// Whether the kept list has been read.
  final bool loaded;

  /// Whether a refresh is running.
  final bool refreshing;

  /// Whether the last refresh failed (the kept list stays in use).
  final bool refreshFailed;

  /// The chosen station, if it is in the list.
  RadioStation? get selected {
    final id = selectedId;
    return id == null ? null : catalog?.byId(id);
  }

  /// This view with the given fields changed.
  RadioView copyWith({
    RadioCatalog? catalog,
    RadioStationId? selectedId,
    bool? loaded,
    bool? refreshing,
    bool? refreshFailed,
  }) => RadioView(
    catalog: catalog ?? this.catalog,
    selectedId: selectedId ?? this.selectedId,
    loaded: loaded ?? this.loaded,
    refreshing: refreshing ?? this.refreshing,
    refreshFailed: refreshFailed ?? this.refreshFailed,
  );

  @override
  bool operator ==(Object other) =>
      other is RadioView &&
      other.catalog == catalog &&
      other.selectedId == selectedId &&
      other.loaded == loaded &&
      other.refreshing == refreshing &&
      other.refreshFailed == refreshFailed;

  @override
  int get hashCode =>
      Object.hash(catalog, selectedId, loaded, refreshing, refreshFailed);
}

/// The words the native player shows for a station (the lock screen and
/// notification), in the app's language at the moment of Play.
typedef RadioNowPlayingText = ({String title, String subtitle});

/// Holds the station list and the choice, and turns taps into player
/// commands (§15 D122). The player itself is native; this never keeps a
/// second idea of whether audio plays.
///
/// * Start (REQ-RADIO-005, REQ-RADIO-006): the kept list and the last
///   station show at once, nothing plays, and the list is fetched again
///   only when missing or older than [RadioCatalog.maxAge].
/// * Play never fetches the list. If a station ends unavailable after the
///   player's retries, the list is fetched once and, when that station's
///   stream changed, the same station is tried with it; never another
///   station (REQ-RADIO-008).
/// * An Athan that starts pauses the radio, which waits for the listener
///   (REQ-RADIO-011).
final class RadioController extends Notifier<RadioView> {
  int _refreshes = 0;
  RadioPlayRequest? _lastRequest;
  RadioStationId? _recovered;

  RadioAudio get _audio => ref.read(radioAudioProvider);

  @override
  RadioView build() {
    ref
      ..listen(radioPlaybackProvider, (_, next) {
        if (next case AsyncData(:final value)) unawaited(_follow(value));
      })
      ..listen(athanPlayingProvider, (_, next) {
        final playing = ref.read(radioPlaybackProvider).value;
        if (next.value == true && (playing?.wantsSound ?? false)) {
          unawaited(_audio.pause());
        }
      });
    unawaited(Future.microtask(_start));
    return const RadioView();
  }

  Future<void> _start() async {
    final kept = await ref.read(radioCatalogStoreProvider).read();
    final wire = await ref
        .read(watchSettingProvider)
        .watch(AppSettings.radioStationId)
        .first;
    final playing = ref.read(radioPlaybackProvider).value?.stationId;
    final remembered = wire == null ? null : RadioStationId.parse(wire);
    state = state.copyWith(
      catalog: kept,
      selectedId:
          playing ?? state.selectedId ?? remembered ?? _firstFeatured(kept),
      loaded: true,
    );
    final now = ref.read(clockProvider).nowUtcMs();
    if (kept == null || kept.isStale(now)) await refresh();
  }

  /// Fetches the list again (pull to refresh, Try again, a stale list).
  /// A newer refresh supersedes an older one, whose answer is dropped.
  Future<Result<RadioCatalog, RadioCatalogFailure>> refresh() async {
    final run = ++_refreshes;
    state = state.copyWith(refreshing: true);
    final result = await ref.read(refreshRadioCatalogProvider)();
    if (run != _refreshes) return const Result.err(RadioCatalogCancelled());
    switch (result) {
      case Ok(:final value):
        state = state.copyWith(
          catalog: value,
          selectedId: state.selectedId ?? _firstFeatured(value),
          refreshing: false,
          refreshFailed: false,
        );
      case Err():
        state = state.copyWith(refreshing: false, refreshFailed: true);
    }
    return result;
  }

  /// Chooses [station] and plays it: tapping a station is the listener
  /// asking for it (REQ-RADIO-006).
  Future<void> playStation(RadioStation station, RadioNowPlayingText text) {
    state = state.copyWith(selectedId: station.id);
    unawaited(
      ref
          .read(writeSettingProvider)
          .write(AppSettings.radioStationId, station.id.wire),
    );
    return _play(station, text);
  }

  /// Play or Pause for the chosen station.
  Future<void> togglePlay(RadioNowPlayingText Function(RadioStation) text) {
    final playback = ref.read(radioPlaybackProvider).value;
    final station = state.selected;
    if (playback != null && playback.wantsSound) return _audio.pause();
    if (station == null) return Future.value();
    if (playback != null &&
        playback.phase == RadioPhase.paused &&
        playback.stationId == station.id) {
      return _audio.resume();
    }
    return _play(station, text(station));
  }

  /// Pause only (the mini player when audio plays).
  Future<void> pause() => _audio.pause();

  /// Resume the loaded station, or start the chosen one.
  Future<void> resumeOrPlay(RadioNowPlayingText Function(RadioStation) text) {
    final playback = ref.read(radioPlaybackProvider).value;
    if (playback != null && playback.phase == RadioPhase.paused) {
      return _audio.resume();
    }
    return togglePlay(text);
  }

  /// Stops: no retry, no sleep timer, nothing resumes on its own.
  Future<void> stop() {
    _lastRequest = null;
    _recovered = null;
    return _audio.stop();
  }

  /// Sets or cancels the sleep timer.
  Future<void> sleep(RadioSleepOption option) => _audio.sleep(option);

  Future<void> _play(RadioStation station, RadioNowPlayingText text) {
    final request = RadioPlayRequest(
      stationId: station.id,
      url: station.streamUrl,
      title: text.title,
      subtitle: text.subtitle,
    );
    _lastRequest = request;
    _recovered = null;
    return _audio.play(request);
  }

  Future<void> _follow(RadioPlayback playback) async {
    final id = playback.stationId;
    if (id != null && playback.session && id != state.selectedId) {
      state = state.copyWith(selectedId: id);
    }
    final last = _lastRequest;
    if (playback.phase != RadioPhase.unavailable ||
        id == null ||
        last == null ||
        last.stationId != id ||
        _recovered == id) {
      return;
    }
    _recovered = id;
    final result = await refresh();
    if (result case Ok(:final value)) {
      final fresh = value.byId(id);
      // Only the same station, and only if its stream really changed.
      if (fresh == null ||
          fresh.streamUrl == last.url ||
          _lastRequest != last) {
        return;
      }
      final retry = RadioPlayRequest(
        stationId: id,
        url: fresh.streamUrl,
        title: last.title,
        subtitle: last.subtitle,
      );
      _lastRequest = retry;
      await _audio.play(retry);
    }
  }

  static RadioStationId? _firstFeatured(RadioCatalog? catalog) {
    if (catalog == null || catalog.stations.isEmpty) return null;
    return catalog.stations.first.id;
  }
}
