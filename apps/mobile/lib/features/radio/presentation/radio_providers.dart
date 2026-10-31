import 'package:daily_muslim/features/radio/application/refresh_radio_catalog.dart';
import 'package:daily_muslim/features/radio/application/toggle_radio_favorite.dart';
import 'package:daily_muslim/features/radio/domain/radio_playback.dart';
import 'package:daily_muslim/features/radio/domain/radio_ports.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:daily_muslim/features/radio/presentation/radio_controller.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The native player (bound in `app/di.dart`).
final radioAudioProvider = Provider<RadioAudio>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The kept station list (bound in `app/di.dart`).
final radioCatalogStoreProvider = Provider<RadioCatalogStore>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Fetches and keeps the station list (bound in `app/di.dart`).
final refreshRadioCatalogProvider = Provider<RefreshRadioCatalog>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Toggles a favorite (bound in `app/di.dart`).
final toggleRadioFavoriteProvider = Provider<ToggleRadioFavorite>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The one player's state: asked once, then followed (REQ-RADIO-007). The
/// full and mini players both read this, never a copy of their own.
final StreamProvider<RadioPlayback> radioPlaybackProvider = StreamProvider((
  ref,
) async* {
  final audio = ref.watch(radioAudioProvider);
  yield await audio.current();
  yield* audio.changes;
});

/// The favorite stations, by id (REQ-RADIO-002).
final StreamProvider<Set<RadioStationId>> radioFavoritesProvider =
    StreamProvider(
      (ref) => ref
          .watch(watchSettingProvider)
          .watch(AppSettings.radioFavorites)
          .map(
            (wires) => {
              for (final wire in wires) ?RadioStationId.parse(wire),
            },
          ),
    );

/// The list, the chosen station and the commands (§15 D122). Kept for the
/// whole run, not per screen, so leaving the Radio tab changes nothing.
final NotifierProvider<RadioController, RadioView> radioControllerProvider =
    NotifierProvider(RadioController.new);
