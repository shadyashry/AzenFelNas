import 'package:meta/meta.dart';

/// A language the station catalog is published in (§15 D122).
enum RadioLanguage {
  /// Arabic (`language=ar`).
  ar,

  /// English (`language=eng`).
  en,
}

/// A station's identity: its provider and the provider's own id (§15 D122),
/// written `mp3quran:74`. Favorites and the last station are kept by this,
/// never by a name, so a renamed station keeps them and a station with a
/// similar name never takes them.
@immutable
final class RadioStationId {
  /// Station [providerId] of [provider].
  const new(this.provider, this.providerId);

  /// The only provider today (§15 D122).
  static const mp3quran = 'mp3quran';

  /// The id written as [wire], or `null` when it is not one.
  static RadioStationId? parse(String wire) {
    final colon = wire.indexOf(':');
    if (colon <= 0) return null;
    final id = int.tryParse(wire.substring(colon + 1));
    if (id == null || id <= 0) return null;
    return RadioStationId(wire.substring(0, colon), id);
  }

  /// The provider, e.g. `mp3quran`.
  final String provider;

  /// The provider's id for the station.
  final int providerId;

  /// The stored form, e.g. `mp3quran:74`.
  String get wire => '$provider:$providerId';

  @override
  bool operator ==(Object other) =>
      other is RadioStationId &&
      other.provider == provider &&
      other.providerId == providerId;

  @override
  int get hashCode => Object.hash(provider, providerId);

  @override
  String toString() => wire;
}

/// The recitation style named by the end of a stream's path (§15 D122):
/// the catalog gives several stations one name and tells them apart only
/// there (`…_mojawwad`, `…_warsh`).
enum RadioVariant {
  /// No style named.
  plain,

  /// `_mojawwad`: the mujawwad recitation.
  mujawwad,

  /// `_warsh`: the Warsh narration.
  warsh,
}

/// What the app says about a station under its name: a description the app
/// checked (the featured stations, §15 D122), or only the variant its
/// stream path names. Nothing else is claimed: a station's name does not
/// say which reciter is on air now.
@immutable
sealed class RadioDescription {
  const new();
}

/// A description checked by hand for a featured station.
final class RadioCuratedDescription extends RadioDescription {
  /// [en] and [ar].
  const new({required this.en, required this.ar});

  /// English.
  final String en;

  /// Arabic.
  final String ar;

  /// The text in [language].
  String of(RadioLanguage language) => switch (language) {
    RadioLanguage.en => en,
    RadioLanguage.ar => ar,
  };

  @override
  bool operator ==(Object other) =>
      other is RadioCuratedDescription && other.en == en && other.ar == ar;

  @override
  int get hashCode => Object.hash(en, ar);
}

/// No checked description: the variant alone.
final class RadioVariantDescription extends RadioDescription {
  /// The description of [variant].
  const new(this.variant);

  /// The stream path's variant.
  final RadioVariant variant;

  @override
  bool operator ==(Object other) =>
      other is RadioVariantDescription && other.variant == variant;

  @override
  int get hashCode => variant.hashCode;
}

/// One live station (§15 D122).
@immutable
final class RadioStation {
  /// The station.
  const new({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.streamUrl,
    required this.description,
    this.featured = false,
  });

  /// Stable identity.
  final RadioStationId id;

  /// The English name.
  final String nameEn;

  /// The Arabic name.
  final String nameAr;

  /// The latest known stream URL (HTTPS, an allowed host).
  final Uri streamUrl;

  /// What is said under the name.
  final RadioDescription description;

  /// One of the stations shown first (§15 D122).
  final bool featured;

  /// The name in [language].
  String nameIn(RadioLanguage language) => switch (language) {
    RadioLanguage.en => nameEn,
    RadioLanguage.ar => nameAr,
  };

  /// This station with [url] as its stream.
  RadioStation withStream(Uri url) => RadioStation(
    id: id,
    nameEn: nameEn,
    nameAr: nameAr,
    streamUrl: url,
    description: description,
    featured: featured,
  );

  @override
  bool operator ==(Object other) =>
      other is RadioStation &&
      other.id == id &&
      other.nameEn == nameEn &&
      other.nameAr == nameAr &&
      other.streamUrl == streamUrl &&
      other.description == description &&
      other.featured == featured;

  @override
  int get hashCode =>
      Object.hash(id, nameEn, nameAr, streamUrl, description, featured);
}
