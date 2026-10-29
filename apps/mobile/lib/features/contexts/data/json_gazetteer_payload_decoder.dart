import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_place.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:daily_muslim/features/packages/domain/run_payload_work.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_contracts/dm_contracts.dart' as wire;
import 'package:dm_core_types/dm_core_types.dart';
import 'package:json_annotation/json_annotation.dart';

/// Decodes `gazetteer_package.v1` (§9.5) with the `dm_contracts` wire model
/// and checks the constraints the model does not: ranges, patterns,
/// non-empty names and unique ids. [decode] runs through [RunPayloadWork],
/// a background isolate by default: the bundled payload is 8 MB (§15 D96).
final class JsonGazetteerPayloadDecoder implements DecodeGazetteerPayload {
  /// The decoder over [_run].
  const new({this._run = Isolate.run});

  final RunPayloadWork _run;

  static final _country = RegExp(r'^[A-Z]{2}$');
  static final _zone = RegExp(r'^[A-Za-z_]+(/[A-Za-z0-9_+-]+)*$');
  static const _zoneMaxLength = 64;

  @override
  Future<Result<List<GazetteerPlace>, GazetteerFailure>> decode(
    List<int> payload,
  ) {
    final bytes = Uint8List.fromList(payload);
    return _run(() => decodeNow(bytes));
  }

  /// [decode] on the calling isolate.
  static Result<List<GazetteerPlace>, GazetteerFailure> decodeNow(
    List<int> payload,
  ) {
    final Object? document;
    try {
      document = jsonDecode(utf8.decode(payload));
    } on FormatException catch (error) {
      return Err(GazetteerFailure.payloadInvalid('not UTF-8 JSON: $error'));
    }
    if (document is! List<Object?>) {
      return const Err(GazetteerFailure.payloadInvalid('not a JSON array'));
    }
    final places = <GazetteerPlace>[];
    final ids = <int>{};
    for (final (index, item) in document.indexed) {
      if (item is! Map<String, Object?>) {
        return Err(
          GazetteerFailure.payloadInvalid('item $index: not an object'),
        );
      }
      final wire.GazetteerPlace decoded;
      try {
        decoded = wire.GazetteerPlace.fromJson(item);
      } on CheckedFromJsonException catch (error) {
        return Err(
          GazetteerFailure.payloadInvalid(
            'item $index: ${error.key}: ${error.message}',
          ),
        );
      }
      final problem = _problem(decoded);
      if (problem != null) {
        return Err(GazetteerFailure.payloadInvalid('item $index: $problem'));
      }
      if (!ids.add(decoded.id)) {
        return Err(
          GazetteerFailure.payloadInvalid(
            'item $index: duplicate id ${decoded.id}',
          ),
        );
      }
      places.add(_place(decoded));
    }
    return Ok(places);
  }

  static String? _problem(wire.GazetteerPlace place) {
    if (place.id < 1) return 'id < 1';
    if (place.name.isEmpty || place.asciiName.isEmpty) return 'empty name';
    if ([...place.altNames.ar, ...place.altNames.en].any((n) => n.isEmpty)) {
      return 'empty alternate name';
    }
    if (!_country.hasMatch(place.country)) return 'country not ISO alpha-2';
    if (!(place.lat >= -90 && place.lat <= 90)) return 'lat out of range';
    if (!(place.lon >= -180 && place.lon <= 180)) return 'lon out of range';
    if (place.population < 0) return 'population < 0';
    if (place.zoneId.length > _zoneMaxLength || !_zone.hasMatch(place.zoneId)) {
      return 'zoneId is not a zone id';
    }
    return null;
  }

  static GazetteerPlace _place(wire.GazetteerPlace place) => GazetteerPlace(
    id: place.id,
    name: place.name,
    asciiName: place.asciiName,
    arabicNames: List.unmodifiable(place.altNames.ar),
    englishNames: List.unmodifiable(place.altNames.en),
    country: place.country,
    admin1: place.admin1,
    point: GeoPointE6.fromDegrees(place.lat, place.lon),
    population: place.population,
    zoneId: place.zoneId,
  );
}
