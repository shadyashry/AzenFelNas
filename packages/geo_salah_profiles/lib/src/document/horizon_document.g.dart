// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horizon_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HorizonDocument _$HorizonDocumentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_HorizonDocument', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['elevationPolicy']);
      final val = _HorizonDocument(
        elevationPolicy: $checkedConvert(
          'elevationPolicy',
          (v) => $enumDecode(_$ElevationPolicyCodeEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$HorizonDocumentToJson(
  _HorizonDocument instance,
) => <String, dynamic>{
  'elevationPolicy': _$ElevationPolicyCodeEnumMap[instance.elevationPolicy]!,
};

const _$ElevationPolicyCodeEnumMap = {
  ElevationPolicyCode.none: 'NONE',
  ElevationPolicyCode.aboveLocalTerrain: 'ABOVE_LOCAL_TERRAIN',
  ElevationPolicyCode.authorityTable: 'AUTHORITY_TABLE',
};
