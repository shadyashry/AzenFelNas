import 'package:dm_contracts/src/gazetteer/gazetteer_alt_names.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gazetteer_place.freezed.dart';
part 'gazetteer_place.g.dart';

/// One entry of the `gazetteer` package payload (`gazetteer_package.v1`, §9.5).
@freezed
abstract class GazetteerPlace with _$GazetteerPlace {
  /// Creates a [GazetteerPlace].
  const factory({
    /// GeoNames id.
    required int id,

    /// Name.
    required String name,

    /// ASCII name.
    required String asciiName,

    /// Alternate names.
    required GazetteerAltNames altNames,

    /// ISO 3166-1 alpha-2.
    required String country,

    /// Admin-1 code; empty when unknown.
    required String admin1,

    /// Latitude.
    required double lat,

    /// Longitude.
    required double lon,

    /// Population.
    required int population,

    /// IANA zone.
    required String zoneId,
  }) = _GazetteerPlace;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$GazetteerPlaceFromJson(json);
}
