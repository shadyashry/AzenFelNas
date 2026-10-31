import 'dart:async';

import 'package:daily_muslim/features/radio/application/refresh_radio_catalog.dart';
import 'package:daily_muslim/features/radio/application/toggle_radio_favorite.dart';
import 'package:daily_muslim/features/radio/domain/radio_catalog.dart';
import 'package:daily_muslim/features/radio/domain/radio_failure.dart';
import 'package:daily_muslim/features/radio/domain/radio_playback.dart';
import 'package:daily_muslim/features/radio/domain/radio_ports.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:daily_muslim/features/radio/presentation/radio_providers.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/domain/setting_key.dart';
import 'package:daily_muslim/features/settings/domain/settings_ports.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/misc.dart';

/// A station on MP3Quran's stream host.
RadioStation station(
  int id, {
  String? en,
  String? ar,
  String? path,
  bool featured = false,
}) => RadioStation(
  id: RadioStationId(RadioStationId.mp3quran, id),
  nameEn: en ?? 'Station $id',
  nameAr: ar ?? 'إذاعة $id',
  streamUrl: Uri.parse('https://backup.qurango.net/radio/${path ?? 's$id'}'),
  description: const RadioVariantDescription(RadioVariant.plain),
  featured: featured,
);

/// A catalog of [stations] refreshed at [at].
RadioCatalog catalogOf(List<RadioStation> stations, {int at = 0}) =>
    RadioCatalog(stations: stations, refreshedUtcMs: at);

/// The native player, faked at its port: records commands and lets a test
/// push states.
final class FakeRadioAudio implements RadioAudio {
  /// The fake, starting at [initial].
  new({this.initial = RadioPlayback.idle});

  /// The state reported first.
  final RadioPlayback initial;

  final _changes = StreamController<RadioPlayback>.broadcast();

  /// Every command, in order, e.g. `play mp3quran:74 https://…`.
  final List<String> calls = [];

  /// Pushes [state] as the native side would.
  void emit(RadioPlayback state) => _changes.add(state);

  @override
  Future<RadioPlayback> current() async => initial;

  @override
  Stream<RadioPlayback> get changes => _changes.stream;

  @override
  Future<void> play(RadioPlayRequest request) async =>
      calls.add('play ${request.stationId} ${request.url}');

  @override
  Future<void> pause() async => calls.add('pause');

  @override
  Future<void> resume() async => calls.add('resume');

  @override
  Future<void> stop() async => calls.add('stop');

  @override
  Future<void> sleep(RadioSleepOption option) async =>
      calls.add('sleep ${option.minutes}');
}

/// A kept list in memory.
final class MemoryCatalogStore implements RadioCatalogStore {
  /// The store holding [catalog].
  new([this.catalog]);

  /// The kept list.
  RadioCatalog? catalog;

  /// How many times it was written.
  int writes = 0;

  @override
  Future<RadioCatalog?> read() async => catalog;

  @override
  Future<void> write(RadioCatalog catalog) async {
    writes++;
    this.catalog = catalog;
  }
}

/// The provider's answers, faked at the origin port.
final class FakeOrigin implements RadioCatalogOrigin {
  /// The origin answering with [radios] (decoded JSON), or failing.
  new(this.radios_);

  /// What each call answers.
  Result<Object?, RadioCatalogFailure> radios_;

  /// How many calls were made.
  int calls = 0;

  @override
  Future<Result<Object?, RadioCatalogFailure>> radios(
    RadioLanguage language,
  ) async {
    calls++;
    return radios_;
  }
}

/// No featured stations.
final class NoFeatured implements ReadFeaturedStations {
  /// The reader.
  const new();

  @override
  Future<List<FeaturedStation>> call() async => const [];
}

/// An API answer with [stations] (id → stream path).
Map<String, Object?> answer(Map<int, String> stations) => {
  'radios': [
    for (final MapEntry(:key, :value) in stations.entries)
      {
        'id': key,
        'name': 'Station $key',
        'url': 'https://backup.qurango.net/radio/$value',
      },
  ],
};

/// The radio's providers over fakes, the settings over [settings].
List<Override> radioOverrides({
  required FakeRadioAudio audio,
  required MemoryCatalogStore store,
  required FakeOrigin origin,
  required MemorySettings settings,
  int nowUtcMs = 0,
}) => [
  clockProvider.overrideWithValue(FixedClock(nowUtcMs)),
  watchSettingProvider.overrideWithValue(settings),
  writeSettingProvider.overrideWithValue(settings),
  radioAudioProvider.overrideWithValue(audio),
  radioCatalogStoreProvider.overrideWithValue(store),
  refreshRadioCatalogProvider.overrideWithValue(
    RefreshRadioCatalog(
      origin: origin,
      store: store,
      featured: const NoFeatured(),
      clock: FixedClock(nowUtcMs),
    ),
  ),
  toggleRadioFavoriteProvider.overrideWithValue(
    ToggleRadioFavorite(read: settings, write: settings),
  ),
];

/// The settings in memory, faked at the settings ports.
final class MemorySettings implements ReadSetting, WatchSetting, WriteSetting {
  final _values = <String, Object?>{};
  final _changes = StreamController<String>.broadcast();

  @override
  Future<T> read<T>(SettingKey<T> key) => Future<T>.value(_value<T>(key));

  @override
  Stream<T> watch<T>(SettingKey<T> key) async* {
    yield _value(key);
    yield* _changes.stream.where((k) => k == key.wire).map((_) => _value(key));
  }

  @override
  Future<void> write<T>(SettingKey<T> key, T value) async {
    _values[key.wire] = value;
    _changes.add(key.wire);
  }

  T _value<T>(SettingKey<T> key) => switch (_values[key.wire]) {
    final T value => value,
    _ => key.defaultValue,
  };
}
