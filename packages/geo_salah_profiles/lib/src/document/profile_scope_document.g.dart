// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_scope_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileScopeDocument _$ProfileScopeDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ProfileScopeDocument', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const ['countries', 'polygonsRef', 'adminAreas'],
  );
  final val = _ProfileScopeDocument(
    countries: $checkedConvert(
      'countries',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    polygonsRef: $checkedConvert('polygonsRef', (v) => v as String?),
    adminAreas: $checkedConvert(
      'adminAreas',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
    ),
  );
  return val;
});

Map<String, dynamic> _$ProfileScopeDocumentToJson(
  _ProfileScopeDocument instance,
) => <String, dynamic>{
  'countries': instance.countries,
  'polygonsRef': instance.polygonsRef,
  'adminAreas': instance.adminAreas,
};
