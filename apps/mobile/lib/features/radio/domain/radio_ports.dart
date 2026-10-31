import 'package:daily_muslim/features/radio/domain/radio_catalog.dart';
import 'package:daily_muslim/features/radio/domain/radio_failure.dart';
import 'package:daily_muslim/features/radio/domain/radio_playback.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// The provider's station list in one language (§15 D122): MP3Quran's
/// documented `api/v3/radios` endpoint, decoded JSON, nothing else.
abstract interface class RadioCatalogOrigin {
  /// The decoded answer for [language].
  Future<Result<Object?, RadioCatalogFailure>> radios(RadioLanguage language);
}

/// The station list kept on the phone. Contract: never throws; an
/// unreadable or other-version file reads as `null`.
abstract interface class RadioCatalogStore {
  /// The kept list, or `null`.
  Future<RadioCatalog?> read();

  /// Replaces the kept list with [catalog].
  Future<void> write(RadioCatalog catalog);
}

/// One featured station as the bundled list names it (§15 D122).
@immutable
final class FeaturedStation {
  /// The entry.
  const new({
    required this.providerId,
    required this.streamPath,
    this.nameEn,
    this.nameAr,
    this.description,
  });

  /// The provider's id.
  final int providerId;

  /// The stream path the id must still have (`/radio/<name>`); when the
  /// provider gives the id another stream, the entry is not applied.
  final String streamPath;

  /// A display name replacing the provider's English one, if any.
  final String? nameEn;

  /// A display name replacing the provider's Arabic one, if any.
  final String? nameAr;

  /// The checked description, if any.
  final RadioCuratedDescription? description;
}

/// The bundled featured stations, in order.
abstract interface class ReadFeaturedStations {
  /// The entries; empty when the bundled file cannot be read.
  Future<List<FeaturedStation>> call();
}

/// What the native player is asked to play.
@immutable
final class RadioPlayRequest {
  /// The request.
  const new({
    required this.stationId,
    required this.url,
    required this.title,
    required this.subtitle,
  });

  /// The station.
  final RadioStationId stationId;

  /// Its stream.
  final Uri url;

  /// The name shown on the lock screen and notification.
  final String title;

  /// The line under it (live, and the source).
  final String subtitle;
}

/// The one native radio player (§15 D122): Media3 on Android, AVPlayer on
/// iOS. It keeps playing with no screen open and owns the sleep timer, the
/// retries and the system controls.
abstract interface class RadioAudio {
  /// The current state.
  Future<RadioPlayback> current();

  /// Every change of state.
  Stream<RadioPlayback> get changes;

  /// Starts [request], replacing whatever played.
  Future<void> play(RadioPlayRequest request);

  /// Pauses.
  Future<void> pause();

  /// Resumes the loaded station.
  Future<void> resume();

  /// Stops, cancels retries and the sleep timer, and releases the stream.
  Future<void> stop();

  /// Sets the sleep timer; [RadioSleepOption.off] cancels it.
  Future<void> sleep(RadioSleepOption option);
}
