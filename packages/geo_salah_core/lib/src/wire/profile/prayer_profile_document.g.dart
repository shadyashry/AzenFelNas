// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_profile_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrayerProfileDocument _$PrayerProfileDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_PrayerProfileDocument', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'profileId',
      'schemaVersion',
      'version',
      'status',
      'effectiveFrom',
      'effectiveTo',
      'scope',
      'authority',
      'referenceMode',
      'referencePoints',
      'rules',
      'horizon',
      'highLatitude',
      'rounding',
      'adjustments',
      'evidence',
      'approvals',
      'compatibility',
    ],
  );
  final val = _PrayerProfileDocument(
    profileId: $checkedConvert('profileId', (v) => v as String),
    schemaVersion: $checkedConvert('schemaVersion', (v) => (v as num).toInt()),
    version: $checkedConvert('version', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$ProfileStatusCodeEnumMap, v),
    ),
    effectiveFrom: $checkedConvert('effectiveFrom', (v) => v as String),
    effectiveTo: $checkedConvert('effectiveTo', (v) => v as String?),
    scope: $checkedConvert(
      'scope',
      (v) => ProfileScopeDocument.fromJson(v as Map<String, dynamic>),
    ),
    authority: $checkedConvert(
      'authority',
      (v) => AuthorityDocument.fromJson(v as Map<String, dynamic>),
    ),
    referenceMode: $checkedConvert(
      'referenceMode',
      (v) => $enumDecode(_$ReferenceModeCodeEnumMap, v),
    ),
    referencePoints: $checkedConvert(
      'referencePoints',
      (v) => (v as List<dynamic>)
          .map(
            (e) => ReferencePointDocument.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
    rules: $checkedConvert(
      'rules',
      (v) => RulesDocument.fromJson(v as Map<String, dynamic>),
    ),
    horizon: $checkedConvert(
      'horizon',
      (v) => HorizonDocument.fromJson(v as Map<String, dynamic>),
    ),
    highLatitude: $checkedConvert(
      'highLatitude',
      (v) => HighLatitudeDocument.fromJson(v as Map<String, dynamic>),
    ),
    rounding: $checkedConvert(
      'rounding',
      (v) => (v as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, $enumDecode(_$RoundingModeCodeEnumMap, e)),
      ),
    ),
    adjustments: $checkedConvert(
      'adjustments',
      (v) => AdjustmentsDocument.fromJson(v as Map<String, dynamic>),
    ),
    evidence: $checkedConvert(
      'evidence',
      (v) => EvidenceDocument.fromJson(v as Map<String, dynamic>),
    ),
    approvals: $checkedConvert(
      'approvals',
      (v) => ApprovalsDocument.fromJson(v as Map<String, dynamic>),
    ),
    compatibility: $checkedConvert(
      'compatibility',
      (v) => CompatibilityDocument.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$PrayerProfileDocumentToJson(
  _PrayerProfileDocument instance,
) => <String, dynamic>{
  'profileId': instance.profileId,
  'schemaVersion': instance.schemaVersion,
  'version': instance.version,
  'status': _$ProfileStatusCodeEnumMap[instance.status]!,
  'effectiveFrom': instance.effectiveFrom,
  'effectiveTo': instance.effectiveTo,
  'scope': instance.scope.toJson(),
  'authority': instance.authority.toJson(),
  'referenceMode': _$ReferenceModeCodeEnumMap[instance.referenceMode]!,
  'referencePoints': instance.referencePoints.map((e) => e.toJson()).toList(),
  'rules': instance.rules.toJson(),
  'horizon': instance.horizon.toJson(),
  'highLatitude': instance.highLatitude.toJson(),
  'rounding': instance.rounding.map(
    (k, e) => MapEntry(k, _$RoundingModeCodeEnumMap[e]!),
  ),
  'adjustments': instance.adjustments.toJson(),
  'evidence': instance.evidence.toJson(),
  'approvals': instance.approvals.toJson(),
  'compatibility': instance.compatibility.toJson(),
};

const _$ProfileStatusCodeEnumMap = {
  ProfileStatusCode.draftUnverified: 'DRAFT_UNVERIFIED',
  ProfileStatusCode.candidate: 'CANDIDATE',
  ProfileStatusCode.approved: 'APPROVED',
  ProfileStatusCode.retired: 'RETIRED',
};

const _$ReferenceModeCodeEnumMap = {
  ReferenceModeCode.exactCoordinate: 'EXACT_COORDINATE',
  ReferenceModeCode.authorityReferencePoint: 'AUTHORITY_REFERENCE_POINT',
};

const _$RoundingModeCodeEnumMap = {
  RoundingModeCode.ceil: 'ceil',
  RoundingModeCode.floor: 'floor',
  RoundingModeCode.nearest: 'nearest',
};
