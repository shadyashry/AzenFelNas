import 'package:daily_muslim/features/radio/domain/radio_catalog.dart';
import 'package:daily_muslim/features/radio/domain/radio_failure.dart';
import 'package:daily_muslim/features/radio/domain/radio_ports.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:daily_muslim/features/radio/domain/radio_stream_policy.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Reads MP3Quran's `api/v3/radios` answers (§15 D122, REQ-RADIO-001):
/// `{"radios": [{"id", "name", "url", "recent_date"}]}`, once per language.
///
/// * An entry needs a positive `id`, a `name` and an HTTPS `url` on an
///   allowed host ([RadioStreamPolicy]); any other entry is skipped, and
///   unknown fields are ignored.
/// * The two languages are joined by `id`; a name missing in one language
///   takes the other's. The Arabic answer's stream wins if they differ.
/// * Names lose the catalog's decoration (leading and trailing `-`, `*`,
///   and the English `Radio ` prefix); the stored identity is the id.
/// * Featured entries apply only while the id still has the stream path
///   they name, so a reused id never inherits another station's label.
/// * No playable entry at all is [RadioCatalogMalformed]: an empty answer
///   never replaces a kept list.
abstract final class Mp3QuranCatalogParser {
  /// The catalog of [ar] and [en] (decoded JSON), with [featured] first,
  /// dated [nowUtcMs].
  static Result<RadioCatalog, RadioCatalogFailure> parse({
    required Object? ar,
    required Object? en,
    required List<FeaturedStation> featured,
    required int nowUtcMs,
  }) {
    final arabic = _entries(ar);
    final english = _entries(en);
    if (arabic == null && english == null) {
      return const Result.err(RadioCatalogMalformed('no radios list'));
    }
    final ids = <int>[
      ...?arabic?.keys,
      for (final id in english?.keys ?? const <int>[])
        if (arabic == null || !arabic.containsKey(id)) id,
    ];
    final byId = <int, RadioStation>{};
    for (final id in ids) {
      final a = arabic?[id];
      final e = english?[id];
      final url = a?.url ?? e?.url;
      final nameAr = a?.name ?? e?.name;
      final nameEn = e?.name ?? a?.name;
      if (url == null || nameAr == null || nameEn == null) continue;
      byId[id] = RadioStation(
        id: RadioStationId(RadioStationId.mp3quran, id),
        nameEn: nameEn,
        nameAr: nameAr,
        streamUrl: url,
        description: RadioVariantDescription(variantOf(url)),
      );
    }
    if (byId.isEmpty) {
      return const Result.err(RadioCatalogMalformed('no playable station'));
    }
    final ordered = <RadioStation>[];
    for (final entry in featured) {
      final station = byId[entry.providerId];
      if (station == null || station.streamUrl.path != entry.streamPath) {
        continue;
      }
      byId.remove(entry.providerId);
      ordered.add(
        RadioStation(
          id: station.id,
          nameEn: entry.nameEn ?? station.nameEn,
          nameAr: entry.nameAr ?? station.nameAr,
          streamUrl: station.streamUrl,
          description: entry.description ?? station.description,
          featured: true,
        ),
      );
    }
    ordered.addAll(byId.values);
    return Result.ok(RadioCatalog(stations: ordered, refreshedUtcMs: nowUtcMs));
  }

  /// The variant [url]'s last path segment names.
  static RadioVariant variantOf(Uri url) {
    final last = url.pathSegments.isEmpty
        ? ''
        : url.pathSegments.last.toLowerCase();
    if (last.endsWith('_mojawwad')) return RadioVariant.mujawwad;
    if (last.endsWith('_warsh')) return RadioVariant.warsh;
    return RadioVariant.plain;
  }

  /// [raw] without the catalog's decoration; `null` when nothing is left.
  static String? cleanName(String raw) {
    var name = raw
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[\s\-*]+|[\s\-*]+$'), '');
    if (name.startsWith('Radio ') && name.length > 6) {
      name = name.substring(6);
    }
    name = name.replaceAll(RegExp(r'\s*-\s*Radio$'), '');
    return name.isEmpty ? null : name;
  }

  static Map<int, ({String name, Uri url})>? _entries(Object? json) {
    final list = switch (json) {
      {'radios': final List<Object?> radios} => radios,
      _ => null,
    };
    if (list == null) return null;
    final entries = <int, ({String name, Uri url})>{};
    for (final item in list) {
      if (item case {
        'id': final Object id,
        'name': final String rawName,
        'url': final String rawUrl,
      }) {
        final number = switch (id) {
          final int n => n,
          final String s => int.tryParse(s),
          _ => null,
        };
        final name = cleanName(rawName);
        final url = Uri.tryParse(rawUrl.trim());
        if (number == null || number <= 0 || name == null || url == null) {
          continue;
        }
        if (!RadioStreamPolicy.allows(url)) continue;
        entries.putIfAbsent(number, () => (name: name, url: url));
      }
    }
    return entries;
  }
}
