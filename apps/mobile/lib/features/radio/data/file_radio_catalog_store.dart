import 'dart:convert';
import 'dart:io';

import 'package:daily_muslim/features/radio/domain/radio_catalog.dart';
import 'package:daily_muslim/features/radio/domain/radio_ports.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:daily_muslim/features/radio/domain/radio_stream_policy.dart';

/// [RadioCatalogStore] as one JSON file in app support storage (§15 D122):
/// the ids, both names, the latest stream URLs, the refresh time and the
/// schema version. Written to a temporary file and renamed, so a crash
/// mid-write leaves the previous list. A file of another version, or one
/// that does not read, is ignored and the list fetched again.
final class FileRadioCatalogStore implements RadioCatalogStore {
  /// The file under [_root].
  const new(this._root);

  /// The file name.
  static const String fileName = 'radio_catalog.json';

  final Directory _root;

  File get _file => File('${_root.path}/$fileName');

  @override
  Future<RadioCatalog?> read() async {
    try {
      final file = _file;
      if (!file.existsSync()) return null;
      return decode(jsonDecode(await file.readAsString()));
    } on IOException {
      return null;
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> write(RadioCatalog catalog) async {
    try {
      await _root.create(recursive: true);
      final part = File('${_file.path}.part');
      await part.writeAsString(jsonEncode(encode(catalog)), flush: true);
      await part.rename(_file.path);
    } on IOException {
      // The list stays in memory for this run; the next start fetches it.
    }
  }

  /// The stored form of [catalog].
  static Map<String, Object?> encode(RadioCatalog catalog) => {
    'schemaVersion': RadioCatalog.schemaVersion,
    'refreshedUtcMs': catalog.refreshedUtcMs,
    'stations': [
      for (final s in catalog.stations)
        {
          'id': s.id.wire,
          'nameEn': s.nameEn,
          'nameAr': s.nameAr,
          'url': s.streamUrl.toString(),
          'featured': s.featured,
          'description': switch (s.description) {
            RadioCuratedDescription(:final en, :final ar) => {
              'kind': 'curated',
              'en': en,
              'ar': ar,
            },
            RadioVariantDescription(:final variant) => {
              'kind': 'variant',
              'variant': variant.name,
            },
          },
        },
    ],
  };

  /// The catalog of [json], or `null` when it is not a current one.
  static RadioCatalog? decode(Object? json) {
    if (json case {
      'schemaVersion': RadioCatalog.schemaVersion,
      'refreshedUtcMs': final int refreshed,
      'stations': final List<Object?> stations,
    }) {
      final decoded = <RadioStation>[];
      for (final s in stations) {
        if (s case {
          'id': final String wire,
          'nameEn': final String nameEn,
          'nameAr': final String nameAr,
          'url': final String url,
          'featured': final bool featured,
          'description': final Object? description,
        }) {
          final id = RadioStationId.parse(wire);
          final stream = Uri.tryParse(url);
          final text = _description(description);
          if (id == null ||
              stream == null ||
              text == null ||
              !RadioStreamPolicy.allows(stream)) {
            continue;
          }
          decoded.add(
            RadioStation(
              id: id,
              nameEn: nameEn,
              nameAr: nameAr,
              streamUrl: stream,
              description: text,
              featured: featured,
            ),
          );
        }
      }
      if (decoded.isEmpty) return null;
      return RadioCatalog(stations: decoded, refreshedUtcMs: refreshed);
    }
    return null;
  }

  static RadioDescription? _description(Object? json) => switch (json) {
    {'kind': 'curated', 'en': final String en, 'ar': final String ar} =>
      RadioCuratedDescription(en: en, ar: ar),
    {'kind': 'variant', 'variant': final String name} => switch (name) {
      'plain' => const RadioVariantDescription(RadioVariant.plain),
      'mujawwad' => const RadioVariantDescription(RadioVariant.mujawwad),
      'warsh' => const RadioVariantDescription(RadioVariant.warsh),
      _ => null,
    },
    _ => null,
  };
}
