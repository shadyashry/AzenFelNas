import 'dart:async';

import 'package:daily_muslim/features/athan/domain/athan_playback.dart';
import 'package:daily_muslim/features/athan/presentation/athan_voice_providers.dart';
import 'package:daily_muslim/features/radio/data/channel_radio_audio.dart';
import 'package:daily_muslim/features/radio/domain/radio_failure.dart';
import 'package:daily_muslim/features/radio/domain/radio_playback.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:daily_muslim/features/radio/presentation/radio_providers.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'radio_fakes.dart';

const int _day = 24 * 60 * 60 * 1000;
const _husary = RadioStationId(RadioStationId.mp3quran, 74);

final class _Athan implements AthanPlayback {
  final changes = StreamController<bool>.broadcast();

  @override
  Future<bool> athanPlaying() async => false;

  @override
  Future<void> stopAthan() async {}

  @override
  Stream<bool> get athanChanges => changes.stream;
}

void main() {
  late MemorySettings settings;

  setUp(() => settings = MemorySettings());

  Future<ProviderContainer> start({
    required FakeRadioAudio audio,
    required MemoryCatalogStore store,
    required FakeOrigin origin,
    int nowUtcMs = 1000,
    List<Override> extra = const [],
  }) async {
    final container = ProviderContainer(
      overrides: [
        ...radioOverrides(
          audio: audio,
          store: store,
          origin: origin,
          settings: settings,
          nowUtcMs: nowUtcMs,
        ),
        ...extra,
      ],
    );
    addTearDown(container.dispose);
    container
      ..listen(radioControllerProvider, (_, _) {})
      ..listen(radioPlaybackProvider, (_, _) {});
    await _settle();
    return container;
  }

  test('REQ-RADIO-005 REQ-RADIO-006 a fresh kept list and the last station '
      'show at once; nothing plays and nothing is fetched', () async {
    await settings.write(AppSettings.radioStationId, _husary.wire);
    final audio = FakeRadioAudio();
    final origin = FakeOrigin(Result.ok(answer({74: 'x'})));
    final container = await start(
      audio: audio,
      store: MemoryCatalogStore(
        catalogOf([station(108), station(74)], at: 1000),
      ),
      origin: origin,
      nowUtcMs: 1000 + _day - 1,
    );

    final view = container.read(radioControllerProvider);
    expect(view.loaded, isTrue);
    expect(view.selectedId, _husary);
    expect(view.catalog?.stations, hasLength(2));
    expect(origin.calls, 0);
    expect(audio.calls, isEmpty);
  });

  test('REQ-RADIO-005 a stale kept list is shown, then refreshed in the '
      'background', () async {
    final store = MemoryCatalogStore(catalogOf([station(108)], at: 1000));
    final origin = FakeOrigin(Result.ok(answer({108: 'mix', 74: 'h'})));
    final container = await start(
      audio: FakeRadioAudio(),
      store: store,
      origin: origin,
      nowUtcMs: 1000 + _day,
    );

    expect(origin.calls, 2); // Arabic and English.
    expect(store.writes, 1);
    final view = container.read(radioControllerProvider);
    expect(view.catalog?.stations, hasLength(2));
    expect(view.selectedId?.providerId, 108);
  });

  test(
    'REQ-RADIO-005 a failed refresh keeps the kept list and says so',
    () async {
      final store = MemoryCatalogStore(catalogOf([station(108)]));
      final container = await start(
        audio: FakeRadioAudio(),
        store: store,
        origin: FakeOrigin(const Result.err(RadioCatalogOffline())),
        nowUtcMs: 2 * _day,
      );

      final view = container.read(radioControllerProvider);
      expect(view.refreshFailed, isTrue);
      expect(view.catalog?.stations.single.id.providerId, 108);
      expect(store.writes, 0);
    },
  );

  test('REQ-RADIO-006 REQ-RADIO-007 tapping a station plays it once, with '
      'no catalog request, and remembers it', () async {
    final audio = FakeRadioAudio();
    final origin = FakeOrigin(Result.ok(answer({74: 'x'})));
    final container = await start(
      audio: audio,
      store: MemoryCatalogStore(catalogOf([station(74)], at: 1000)),
      origin: origin,
    );

    await container.read(radioControllerProvider.notifier).playStation(
      station(74),
      (title: 'T', subtitle: 'S'),
    );
    await _settle();

    expect(audio.calls, [
      'play mp3quran:74 https://backup.qurango.net/radio/s74',
    ]);
    expect(origin.calls, 0);
    expect(await settings.read(AppSettings.radioStationId), 'mp3quran:74');
  });

  test('REQ-RADIO-007 Play/Pause follows the native state: pause while it '
      'plays, resume when paused on the same station', () async {
    final audio = FakeRadioAudio();
    final container = await start(
      audio: audio,
      store: MemoryCatalogStore(catalogOf([station(74)], at: 1000)),
      origin: FakeOrigin(Result.ok(answer({74: 'x'}))),
    );
    final controller = container.read(radioControllerProvider.notifier);
    (String, String) text(RadioStation s) => ('t', 's');

    audio.emit(
      const RadioPlayback(phase: RadioPhase.playing, stationId: _husary),
    );
    await _settle();
    await controller.togglePlay((s) => (title: text(s).$1, subtitle: ''));
    audio.emit(
      const RadioPlayback(phase: RadioPhase.paused, stationId: _husary),
    );
    await _settle();
    await controller.togglePlay((s) => (title: '', subtitle: ''));

    expect(audio.calls, ['pause', 'resume']);
  });

  test('REQ-RADIO-008 a station that ends unavailable is fetched again once '
      'and, with a new stream, the same station is retried', () async {
    final audio = FakeRadioAudio();
    final origin = FakeOrigin(Result.ok(answer({74: 'moved'})));
    final container = await start(
      audio: audio,
      store: MemoryCatalogStore(
        catalogOf([station(74), station(69)], at: 1000),
      ),
      origin: origin,
    );
    await container.read(radioControllerProvider.notifier).playStation(
      station(74),
      (title: 'T', subtitle: 'S'),
    );

    audio.emit(
      const RadioPlayback(phase: RadioPhase.unavailable, stationId: _husary),
    );
    await _settle();
    // A second unavailable for the same play does not fetch again.
    audio.emit(
      const RadioPlayback(phase: RadioPhase.unavailable, stationId: _husary),
    );
    await _settle();

    expect(origin.calls, 2);
    expect(audio.calls, [
      'play mp3quran:74 https://backup.qurango.net/radio/s74',
      'play mp3quran:74 https://backup.qurango.net/radio/moved',
    ]);
  });

  test('REQ-RADIO-008 when the stream did not change, or the station is '
      'gone, nothing else is played', () async {
    for (final fresh in [
      answer({74: 's74'}),
      answer({69: 's69'}),
    ]) {
      final audio = FakeRadioAudio();
      final container = await start(
        audio: audio,
        store: MemoryCatalogStore(catalogOf([station(74)], at: 1000)),
        origin: FakeOrigin(Result.ok(fresh)),
      );
      await container.read(radioControllerProvider.notifier).playStation(
        station(74),
        (title: 'T', subtitle: 'S'),
      );
      audio.emit(
        const RadioPlayback(phase: RadioPhase.unavailable, stationId: _husary),
      );
      await _settle();

      expect(audio.calls, hasLength(1));
    }
  });

  test(
    'REQ-RADIO-008 after Stop, an unavailable report starts nothing',
    () async {
      final audio = FakeRadioAudio();
      final origin = FakeOrigin(Result.ok(answer({74: 'moved'})));
      final container = await start(
        audio: audio,
        store: MemoryCatalogStore(catalogOf([station(74)], at: 1000)),
        origin: origin,
      );
      final controller = container.read(radioControllerProvider.notifier);
      await controller.playStation(station(74), (title: 'T', subtitle: 'S'));
      await controller.stop();
      audio.emit(
        const RadioPlayback(phase: RadioPhase.unavailable, stationId: _husary),
      );
      await _settle();

      expect(origin.calls, 0);
      expect(audio.calls, [
        'play mp3quran:74 https://backup.qurango.net/radio/s74',
        'stop',
      ]);
    },
  );

  test('REQ-RADIO-011 an Athan that starts pauses the radio, which then '
      'waits', () async {
    final athan = _Athan();
    final audio = FakeRadioAudio(
      initial: const RadioPlayback(
        phase: RadioPhase.playing,
        stationId: _husary,
      ),
    );
    final container = await start(
      audio: audio,
      store: MemoryCatalogStore(catalogOf([station(74)], at: 1000)),
      origin: FakeOrigin(Result.ok(answer({74: 'x'}))),
      extra: [athanPlaybackProvider.overrideWithValue(athan)],
    );
    container.listen(athanPlayingProvider, (_, _) {});
    await _settle();

    athan.changes.add(true);
    await _settle();
    athan.changes.add(false);
    await _settle();

    expect(audio.calls, ['pause']);
  });

  test('REQ-RADIO-007 a station already playing when the app opens becomes '
      'the chosen one', () async {
    final audio = FakeRadioAudio(
      initial: const RadioPlayback(
        phase: RadioPhase.playing,
        stationId: _husary,
      ),
    );
    final container = await start(
      audio: audio,
      store: MemoryCatalogStore(
        catalogOf([station(108), station(74)], at: 1000),
      ),
      origin: FakeOrigin(Result.ok(answer({74: 'x'}))),
    );

    expect(container.read(radioControllerProvider).selectedId, _husary);
    expect(audio.calls, isEmpty);
  });

  test(
    'REQ-RADIO-002 favorites are kept by id: toggling twice removes it',
    () async {
      final container = await start(
        audio: FakeRadioAudio(),
        store: MemoryCatalogStore(catalogOf([station(74)], at: 1000)),
        origin: FakeOrigin(Result.ok(answer({74: 'x'}))),
      );
      final toggle = container.read(toggleRadioFavoriteProvider);

      expect(await toggle(_husary), isTrue);
      expect(await settings.read(AppSettings.radioFavorites), {'mp3quran:74'});
      expect(await toggle(_husary), isFalse);
      expect(await settings.read(AppSettings.radioFavorites), isEmpty);
    },
  );

  group('ChannelRadioAudio.decode', () {
    test('REQ-RADIO-010 each native state reads as itself, with the station, '
        'the attempt and the sleep timer', () {
      for (final phase in RadioPhase.values) {
        expect(
          ChannelRadioAudio.decode({'phase': phase.name}).phase,
          phase,
        );
      }
      final state = ChannelRadioAudio.decode({
        'phase': 'reconnecting',
        'stationId': 'mp3quran:74',
        'attempt': 2,
        'sleepMinutes': 30,
        'sleepDeadlineUtcMs': 99,
      });
      expect(state.stationId, _husary);
      expect(state.attempt, 2);
      expect(
        state.sleep,
        const RadioSleep(option: RadioSleepOption.minutes30, deadlineUtcMs: 99),
      );
    });

    test('REQ-RADIO-010 anything unreadable is Ready with nothing loaded, '
        'never Playing', () {
      for (final message in [
        null,
        'playing',
        {'phase': 'buffering'},
        {'phase': 7},
      ]) {
        expect(ChannelRadioAudio.decode(message), RadioPlayback.idle);
      }
      expect(
        ChannelRadioAudio.decode({
          'phase': 'playing',
          'sleepMinutes': 20,
          'sleepDeadlineUtcMs': 5,
        }).sleep,
        isNull,
      );
    });

    test('REQ-RADIO-012 the mini player shows only while a session exists', () {
      expect(
        [
          for (final p in RadioPhase.values)
            if (RadioPlayback(phase: p).session) p,
        ],
        [
          RadioPhase.connecting,
          RadioPhase.playing,
          RadioPhase.paused,
          RadioPhase.reconnecting,
        ],
      );
    });
  });
}

Future<void> _settle() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
