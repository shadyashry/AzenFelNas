import 'dart:convert';

import 'package:daily_muslim/features/radio/domain/radio_ports.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:flutter/services.dart';

/// [ReadFeaturedStations] from the bundled `radio_featured.v1` file
/// (§15 D122). A file that does not decode, or an entry that breaks the
/// schema, leaves that part out; the radio still works without it.
final class AssetFeaturedStations implements ReadFeaturedStations {
  /// The file in [_assets].
  const new(this._assets);

  /// The bundled file.
  static const String path = 'assets/radio/featured_stations.json';

  final AssetBundle _assets;

  @override
  Future<List<FeaturedStation>> call() async {
    try {
      return decode(jsonDecode(await _assets.loadString(path)));
    } on FormatException {
      return const [];
    }
  }

  /// The entries of [json]; empty unless it is a `radio_featured.v1`
  /// document of MP3Quran stations.
  static List<FeaturedStation> decode(Object? json) {
    if (json case {
      'schemaVersion': 1,
      'provider': RadioStationId.mp3quran,
      'stations': final List<Object?> stations,
    }) {
      return [
        for (final s in stations)
          if (s
              case {
                'id': final int id,
                'streamPath': final String path,
              }
              when id > 0 && _path.hasMatch(path))
            FeaturedStation(
              providerId: id,
              streamPath: path,
              nameEn: _text(s, 'name')?.en,
              nameAr: _text(s, 'name')?.ar,
              description: _text(s, 'description'),
            ),
      ];
    }
    return const [];
  }

  static final _path = RegExp(r'^/radio/[A-Za-z0-9_-]+$');

  static RadioCuratedDescription? _text(Map<Object?, Object?> s, String key) =>
      switch (s[key]) {
        {'en': final String en, 'ar': final String ar}
            when en.isNotEmpty && ar.isNotEmpty =>
          RadioCuratedDescription(en: en, ar: ar),
        _ => null,
      };
}
