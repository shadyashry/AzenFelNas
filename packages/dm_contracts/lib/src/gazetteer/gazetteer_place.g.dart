// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gazetteer_place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GazetteerPlace _$GazetteerPlaceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_GazetteerPlace', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'id',
          'name',
          'asciiName',
          'altNames',
          'country',
          'admin1',
          'lat',
          'lon',
          'population',
          'zoneId',
        ],
      );
      final val = _GazetteerPlace(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        asciiName: $checkedConvert('asciiName', (v) => v as String),
        altNames: $checkedConvert(
          'altNames',
          (v) => GazetteerAltNames.fromJson(v as Map<String, dynamic>),
        ),
        country: $checkedConvert('country', (v) => v as String),
        admin1: $checkedConvert('admin1', (v) => v as String),
        lat: $checkedConvert('lat', (v) => (v as num).toDouble()),
        lon: $checkedConvert('lon', (v) => (v as num).toDouble()),
        population: $checkedConvert('population', (v) => (v as num).toInt()),
        zoneId: $checkedConvert('zoneId', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$GazetteerPlaceToJson(_GazetteerPlace instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'asciiName': instance.asciiName,
      'altNames': instance.altNames.toJson(),
      'country': instance.country,
      'admin1': instance.admin1,
      'lat': instance.lat,
      'lon': instance.lon,
      'population': instance.population,
      'zoneId': instance.zoneId,
    };
