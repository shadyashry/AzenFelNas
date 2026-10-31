import 'package:daily_muslim/features/radio/data/mp3quran_catalog_parser.dart';
import 'package:daily_muslim/features/radio/domain/radio_catalog.dart';
import 'package:daily_muslim/features/radio/domain/radio_failure.dart';
import 'package:daily_muslim/features/radio/domain/radio_ports.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Fetches the full station list in Arabic and English, joins it and keeps
/// it (§15 D122, REQ-RADIO-001, REQ-RADIO-005). A whole list every time:
/// the provider documents no way to learn which stations were removed. On
/// any failure nothing is written, so the kept list stays in use.
final class RefreshRadioCatalog {
  /// The use case.
  const new({
    required this._origin,
    required this._store,
    required this._featured,
    required this._clock,
  });

  final RadioCatalogOrigin _origin;
  final RadioCatalogStore _store;
  final ReadFeaturedStations _featured;
  final Clock _clock;

  /// The new list, kept; or why there is none.
  Future<Result<RadioCatalog, RadioCatalogFailure>> call() async {
    final (ar, en, featured) = await (
      _origin.radios(RadioLanguage.ar),
      _origin.radios(RadioLanguage.en),
      _featured(),
    ).wait;
    final Object? arabic;
    final Object? english;
    switch ((ar, en)) {
      case (Err(:final failure), Err()):
        return Result.err(failure);
      case (Ok(value: final a), Err()):
        arabic = a;
        english = null;
      case (Err(), Ok(value: final e)):
        arabic = null;
        english = e;
      case (Ok(value: final a), Ok(value: final e)):
        arabic = a;
        english = e;
    }
    final parsed = Mp3QuranCatalogParser.parse(
      ar: arabic,
      en: english,
      featured: featured,
      nowUtcMs: _clock.nowUtcMs(),
    );
    if (parsed case Ok(:final value)) await _store.write(value);
    return parsed;
  }
}
