// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prayer_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PrayerProfile {

/// `<iso2>.<authority>.<variant>` or `engine.default` (Appendix A).
 String get profileId;/// Profile version, `YYYY.M.N` (Appendix A).
 String get version;/// Governance status (Appendix A `status`).
 ProfileStatus get status;/// First day the profile applies.
 CivilDate get effectiveFrom;/// Countries in scope (ISO 3166-1 alpha-2), or `*` for every country
/// (`engine.default` only).
 List<String> get countries;/// The authority's name (Appendix A `authority.name`).
 String get authorityName;/// Who stands behind the profile (Appendix A `authority.type`).
 AuthorityType get authorityType;/// Where the times are calculated (ADR-006).
 ReferenceMode get referenceMode;/// The rule of each calculated event.
 Map<PrayerEvent, EventRule> get rules;/// The ordered high-latitude chain (§6.4 ¶7).
 List<HighLatitudeMethod> get highLatitudeChain;/// Rounding of every event without an override (Appendix A
/// `rounding.default`).
 RoundingMode get roundingDefault;/// Largest allowed `|perEventMinutes|` (Appendix A
/// `adjustments.maxAbsMinutes`); an offset beyond it is
/// `EngineFailure.invalidProfile`.
 int get maxAbsMinutes;/// Whether `approvals.religious` is present (ADR-008).
 bool get hasReligiousApproval;/// Oldest engine schema that can evaluate the profile (Appendix A
/// `compatibility.minEngineSchema`).
 int get minEngineSchema;/// Last day the profile applies, or `null` when open-ended.
 CivilDate? get effectiveTo;/// The authority's calculation points, per area (ADR-006). The resolver
/// narrows them to the observer's area, so the engine sees one.
 List<ReferencePoint> get referencePoints;/// Per-event rounding overrides (Appendix A `rounding.<event>`).
 Map<PrayerEvent, RoundingMode> get roundingOverrides;/// Additive whole-minute offsets per event (Appendix A
/// `adjustments.perEventMinutes`, §6.4 ¶8).
 Map<PrayerEvent, int> get perEventMinutes;/// Rules that replace an event's rule during Ramadan (Appendix A
/// `adjustments.ramadan`, §6.4 ¶6; applied from S08).
 Map<PrayerEvent, EventRule> get ramadanRules;/// How elevation enters horizon events.
 HorizonElevationPolicy get elevationPolicy;/// The benchmark report an `Authority aligned` label cites (Appendix A
/// `evidence.benchmarkReportId`).
 String? get benchmarkReportId;
/// Create a copy of PrayerProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrayerProfileCopyWith<PrayerProfile> get copyWith => _$PrayerProfileCopyWithImpl<PrayerProfile>(this as PrayerProfile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PrayerProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrayerProfile&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.effectiveFrom, _this.effectiveFrom) || other.effectiveFrom == _this.effectiveFrom)&&const DeepCollectionEquality().equals(other.countries, _this.countries)&&(identical(other.authorityName, _this.authorityName) || other.authorityName == _this.authorityName)&&(identical(other.authorityType, _this.authorityType) || other.authorityType == _this.authorityType)&&(identical(other.referenceMode, _this.referenceMode) || other.referenceMode == _this.referenceMode)&&const DeepCollectionEquality().equals(other.rules, _this.rules)&&const DeepCollectionEquality().equals(other.highLatitudeChain, _this.highLatitudeChain)&&(identical(other.roundingDefault, _this.roundingDefault) || other.roundingDefault == _this.roundingDefault)&&(identical(other.maxAbsMinutes, _this.maxAbsMinutes) || other.maxAbsMinutes == _this.maxAbsMinutes)&&(identical(other.hasReligiousApproval, _this.hasReligiousApproval) || other.hasReligiousApproval == _this.hasReligiousApproval)&&(identical(other.minEngineSchema, _this.minEngineSchema) || other.minEngineSchema == _this.minEngineSchema)&&(identical(other.effectiveTo, _this.effectiveTo) || other.effectiveTo == _this.effectiveTo)&&const DeepCollectionEquality().equals(other.referencePoints, _this.referencePoints)&&const DeepCollectionEquality().equals(other.roundingOverrides, _this.roundingOverrides)&&const DeepCollectionEquality().equals(other.perEventMinutes, _this.perEventMinutes)&&const DeepCollectionEquality().equals(other.ramadanRules, _this.ramadanRules)&&(identical(other.elevationPolicy, _this.elevationPolicy) || other.elevationPolicy == _this.elevationPolicy)&&(identical(other.benchmarkReportId, _this.benchmarkReportId) || other.benchmarkReportId == _this.benchmarkReportId));
}


@override
int get hashCode {
  final _this = this as PrayerProfile;
  return Object.hashAll([runtimeType,_this.profileId,_this.version,_this.status,_this.effectiveFrom,const DeepCollectionEquality().hash(_this.countries),_this.authorityName,_this.authorityType,_this.referenceMode,const DeepCollectionEquality().hash(_this.rules),const DeepCollectionEquality().hash(_this.highLatitudeChain),_this.roundingDefault,_this.maxAbsMinutes,_this.hasReligiousApproval,_this.minEngineSchema,_this.effectiveTo,const DeepCollectionEquality().hash(_this.referencePoints),const DeepCollectionEquality().hash(_this.roundingOverrides),const DeepCollectionEquality().hash(_this.perEventMinutes),const DeepCollectionEquality().hash(_this.ramadanRules),_this.elevationPolicy,_this.benchmarkReportId]);
}

@override
String toString() {
  final _this = this as PrayerProfile;
  return 'PrayerProfile(profileId: ${_this.profileId}, version: ${_this.version}, status: ${_this.status}, effectiveFrom: ${_this.effectiveFrom}, countries: ${_this.countries}, authorityName: ${_this.authorityName}, authorityType: ${_this.authorityType}, referenceMode: ${_this.referenceMode}, rules: ${_this.rules}, highLatitudeChain: ${_this.highLatitudeChain}, roundingDefault: ${_this.roundingDefault}, maxAbsMinutes: ${_this.maxAbsMinutes}, hasReligiousApproval: ${_this.hasReligiousApproval}, minEngineSchema: ${_this.minEngineSchema}, effectiveTo: ${_this.effectiveTo}, referencePoints: ${_this.referencePoints}, roundingOverrides: ${_this.roundingOverrides}, perEventMinutes: ${_this.perEventMinutes}, ramadanRules: ${_this.ramadanRules}, elevationPolicy: ${_this.elevationPolicy}, benchmarkReportId: ${_this.benchmarkReportId})';
}


}

/// @nodoc
abstract mixin class $PrayerProfileCopyWith<$Res>  {
  factory $PrayerProfileCopyWith(PrayerProfile value, $Res Function(PrayerProfile) _then) = _$PrayerProfileCopyWithImpl;
@useResult
$Res call({
 String profileId, String version, ProfileStatus status, CivilDate effectiveFrom, List<String> countries, String authorityName, AuthorityType authorityType, ReferenceMode referenceMode, Map<PrayerEvent, EventRule> rules, List<HighLatitudeMethod> highLatitudeChain, RoundingMode roundingDefault, int maxAbsMinutes, bool hasReligiousApproval, int minEngineSchema, CivilDate? effectiveTo, List<ReferencePoint> referencePoints, Map<PrayerEvent, RoundingMode> roundingOverrides, Map<PrayerEvent, int> perEventMinutes, Map<PrayerEvent, EventRule> ramadanRules, HorizonElevationPolicy elevationPolicy, String? benchmarkReportId
});




}
/// @nodoc
class _$PrayerProfileCopyWithImpl<$Res>
    implements $PrayerProfileCopyWith<$Res> {
  _$PrayerProfileCopyWithImpl(this._self, this._then);

  final PrayerProfile _self;
  final $Res Function(PrayerProfile) _then;

/// Create a copy of PrayerProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = null,Object? version = null,Object? status = null,Object? effectiveFrom = null,Object? countries = null,Object? authorityName = null,Object? authorityType = null,Object? referenceMode = null,Object? rules = null,Object? highLatitudeChain = null,Object? roundingDefault = null,Object? maxAbsMinutes = null,Object? hasReligiousApproval = null,Object? minEngineSchema = null,Object? effectiveTo = freezed,Object? referencePoints = null,Object? roundingOverrides = null,Object? perEventMinutes = null,Object? ramadanRules = null,Object? elevationPolicy = null,Object? benchmarkReportId = freezed,}) {
  return _then(PrayerProfile(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatus,effectiveFrom: null == effectiveFrom ? _self.effectiveFrom : effectiveFrom // ignore: cast_nullable_to_non_nullable
as CivilDate,countries: null == countries ? _self.countries : countries // ignore: cast_nullable_to_non_nullable
as List<String>,authorityName: null == authorityName ? _self.authorityName : authorityName // ignore: cast_nullable_to_non_nullable
as String,authorityType: null == authorityType ? _self.authorityType : authorityType // ignore: cast_nullable_to_non_nullable
as AuthorityType,referenceMode: null == referenceMode ? _self.referenceMode : referenceMode // ignore: cast_nullable_to_non_nullable
as ReferenceMode,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, EventRule>,highLatitudeChain: null == highLatitudeChain ? _self.highLatitudeChain : highLatitudeChain // ignore: cast_nullable_to_non_nullable
as List<HighLatitudeMethod>,roundingDefault: null == roundingDefault ? _self.roundingDefault : roundingDefault // ignore: cast_nullable_to_non_nullable
as RoundingMode,maxAbsMinutes: null == maxAbsMinutes ? _self.maxAbsMinutes : maxAbsMinutes // ignore: cast_nullable_to_non_nullable
as int,hasReligiousApproval: null == hasReligiousApproval ? _self.hasReligiousApproval : hasReligiousApproval // ignore: cast_nullable_to_non_nullable
as bool,minEngineSchema: null == minEngineSchema ? _self.minEngineSchema : minEngineSchema // ignore: cast_nullable_to_non_nullable
as int,effectiveTo: freezed == effectiveTo ? _self.effectiveTo : effectiveTo // ignore: cast_nullable_to_non_nullable
as CivilDate?,referencePoints: null == referencePoints ? _self.referencePoints : referencePoints // ignore: cast_nullable_to_non_nullable
as List<ReferencePoint>,roundingOverrides: null == roundingOverrides ? _self.roundingOverrides : roundingOverrides // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, RoundingMode>,perEventMinutes: null == perEventMinutes ? _self.perEventMinutes : perEventMinutes // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, int>,ramadanRules: null == ramadanRules ? _self.ramadanRules : ramadanRules // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, EventRule>,elevationPolicy: null == elevationPolicy ? _self.elevationPolicy : elevationPolicy // ignore: cast_nullable_to_non_nullable
as HorizonElevationPolicy,benchmarkReportId: freezed == benchmarkReportId ? _self.benchmarkReportId : benchmarkReportId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PrayerProfile].
extension PrayerProfilePatterns on PrayerProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrayerProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrayerProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrayerProfile value)  $default,){
final _that = this;
switch (_that) {
case _PrayerProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrayerProfile value)?  $default,){
final _that = this;
switch (_that) {
case _PrayerProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String profileId,  String version,  ProfileStatus status,  CivilDate effectiveFrom,  List<String> countries,  String authorityName,  AuthorityType authorityType,  ReferenceMode referenceMode,  Map<PrayerEvent, EventRule> rules,  List<HighLatitudeMethod> highLatitudeChain,  RoundingMode roundingDefault,  int maxAbsMinutes,  bool hasReligiousApproval,  int minEngineSchema,  CivilDate? effectiveTo,  List<ReferencePoint> referencePoints,  Map<PrayerEvent, RoundingMode> roundingOverrides,  Map<PrayerEvent, int> perEventMinutes,  Map<PrayerEvent, EventRule> ramadanRules,  HorizonElevationPolicy elevationPolicy,  String? benchmarkReportId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrayerProfile() when $default != null:
return $default(_that.profileId,_that.version,_that.status,_that.effectiveFrom,_that.countries,_that.authorityName,_that.authorityType,_that.referenceMode,_that.rules,_that.highLatitudeChain,_that.roundingDefault,_that.maxAbsMinutes,_that.hasReligiousApproval,_that.minEngineSchema,_that.effectiveTo,_that.referencePoints,_that.roundingOverrides,_that.perEventMinutes,_that.ramadanRules,_that.elevationPolicy,_that.benchmarkReportId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String profileId,  String version,  ProfileStatus status,  CivilDate effectiveFrom,  List<String> countries,  String authorityName,  AuthorityType authorityType,  ReferenceMode referenceMode,  Map<PrayerEvent, EventRule> rules,  List<HighLatitudeMethod> highLatitudeChain,  RoundingMode roundingDefault,  int maxAbsMinutes,  bool hasReligiousApproval,  int minEngineSchema,  CivilDate? effectiveTo,  List<ReferencePoint> referencePoints,  Map<PrayerEvent, RoundingMode> roundingOverrides,  Map<PrayerEvent, int> perEventMinutes,  Map<PrayerEvent, EventRule> ramadanRules,  HorizonElevationPolicy elevationPolicy,  String? benchmarkReportId)  $default,) {final _that = this;
switch (_that) {
case _PrayerProfile():
return $default(_that.profileId,_that.version,_that.status,_that.effectiveFrom,_that.countries,_that.authorityName,_that.authorityType,_that.referenceMode,_that.rules,_that.highLatitudeChain,_that.roundingDefault,_that.maxAbsMinutes,_that.hasReligiousApproval,_that.minEngineSchema,_that.effectiveTo,_that.referencePoints,_that.roundingOverrides,_that.perEventMinutes,_that.ramadanRules,_that.elevationPolicy,_that.benchmarkReportId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String profileId,  String version,  ProfileStatus status,  CivilDate effectiveFrom,  List<String> countries,  String authorityName,  AuthorityType authorityType,  ReferenceMode referenceMode,  Map<PrayerEvent, EventRule> rules,  List<HighLatitudeMethod> highLatitudeChain,  RoundingMode roundingDefault,  int maxAbsMinutes,  bool hasReligiousApproval,  int minEngineSchema,  CivilDate? effectiveTo,  List<ReferencePoint> referencePoints,  Map<PrayerEvent, RoundingMode> roundingOverrides,  Map<PrayerEvent, int> perEventMinutes,  Map<PrayerEvent, EventRule> ramadanRules,  HorizonElevationPolicy elevationPolicy,  String? benchmarkReportId)?  $default,) {final _that = this;
switch (_that) {
case _PrayerProfile() when $default != null:
return $default(_that.profileId,_that.version,_that.status,_that.effectiveFrom,_that.countries,_that.authorityName,_that.authorityType,_that.referenceMode,_that.rules,_that.highLatitudeChain,_that.roundingDefault,_that.maxAbsMinutes,_that.hasReligiousApproval,_that.minEngineSchema,_that.effectiveTo,_that.referencePoints,_that.roundingOverrides,_that.perEventMinutes,_that.ramadanRules,_that.elevationPolicy,_that.benchmarkReportId);case _:
  return null;

}
}

}

/// @nodoc


class _PrayerProfile implements PrayerProfile {
  const _PrayerProfile({required this.profileId, required this.version, required this.status, required this.effectiveFrom, required  List<String> countries, required this.authorityName, required this.authorityType, required this.referenceMode, required  Map<PrayerEvent, EventRule> rules, required  List<HighLatitudeMethod> highLatitudeChain, required this.roundingDefault, required this.maxAbsMinutes, required this.hasReligiousApproval, required this.minEngineSchema, this.effectiveTo,  List<ReferencePoint> referencePoints = const [],  Map<PrayerEvent, RoundingMode> roundingOverrides = const {},  Map<PrayerEvent, int> perEventMinutes = const {},  Map<PrayerEvent, EventRule> ramadanRules = const {}, this.elevationPolicy = HorizonElevationPolicy.none, this.benchmarkReportId}): _countries = countries,_rules = rules,_highLatitudeChain = highLatitudeChain,_referencePoints = referencePoints,_roundingOverrides = roundingOverrides,_perEventMinutes = perEventMinutes,_ramadanRules = ramadanRules;
  

/// `<iso2>.<authority>.<variant>` or `engine.default` (Appendix A).
@override final  String profileId;
/// Profile version, `YYYY.M.N` (Appendix A).
@override final  String version;
/// Governance status (Appendix A `status`).
@override final  ProfileStatus status;
/// First day the profile applies.
@override final  CivilDate effectiveFrom;
/// Countries in scope (ISO 3166-1 alpha-2), or `*` for every country
/// (`engine.default` only).
 final  List<String> _countries;
/// Countries in scope (ISO 3166-1 alpha-2), or `*` for every country
/// (`engine.default` only).
@override List<String> get countries {
  if (_countries is EqualUnmodifiableListView) return _countries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_countries);
}

/// The authority's name (Appendix A `authority.name`).
@override final  String authorityName;
/// Who stands behind the profile (Appendix A `authority.type`).
@override final  AuthorityType authorityType;
/// Where the times are calculated (ADR-006).
@override final  ReferenceMode referenceMode;
/// The rule of each calculated event.
 final  Map<PrayerEvent, EventRule> _rules;
/// The rule of each calculated event.
@override Map<PrayerEvent, EventRule> get rules {
  if (_rules is EqualUnmodifiableMapView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rules);
}

/// The ordered high-latitude chain (§6.4 ¶7).
 final  List<HighLatitudeMethod> _highLatitudeChain;
/// The ordered high-latitude chain (§6.4 ¶7).
@override List<HighLatitudeMethod> get highLatitudeChain {
  if (_highLatitudeChain is EqualUnmodifiableListView) return _highLatitudeChain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_highLatitudeChain);
}

/// Rounding of every event without an override (Appendix A
/// `rounding.default`).
@override final  RoundingMode roundingDefault;
/// Largest allowed `|perEventMinutes|` (Appendix A
/// `adjustments.maxAbsMinutes`); an offset beyond it is
/// `EngineFailure.invalidProfile`.
@override final  int maxAbsMinutes;
/// Whether `approvals.religious` is present (ADR-008).
@override final  bool hasReligiousApproval;
/// Oldest engine schema that can evaluate the profile (Appendix A
/// `compatibility.minEngineSchema`).
@override final  int minEngineSchema;
/// Last day the profile applies, or `null` when open-ended.
@override final  CivilDate? effectiveTo;
/// The authority's calculation points, per area (ADR-006). The resolver
/// narrows them to the observer's area, so the engine sees one.
 final  List<ReferencePoint> _referencePoints;
/// The authority's calculation points, per area (ADR-006). The resolver
/// narrows them to the observer's area, so the engine sees one.
@override@JsonKey() List<ReferencePoint> get referencePoints {
  if (_referencePoints is EqualUnmodifiableListView) return _referencePoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_referencePoints);
}

/// Per-event rounding overrides (Appendix A `rounding.<event>`).
 final  Map<PrayerEvent, RoundingMode> _roundingOverrides;
/// Per-event rounding overrides (Appendix A `rounding.<event>`).
@override@JsonKey() Map<PrayerEvent, RoundingMode> get roundingOverrides {
  if (_roundingOverrides is EqualUnmodifiableMapView) return _roundingOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_roundingOverrides);
}

/// Additive whole-minute offsets per event (Appendix A
/// `adjustments.perEventMinutes`, §6.4 ¶8).
 final  Map<PrayerEvent, int> _perEventMinutes;
/// Additive whole-minute offsets per event (Appendix A
/// `adjustments.perEventMinutes`, §6.4 ¶8).
@override@JsonKey() Map<PrayerEvent, int> get perEventMinutes {
  if (_perEventMinutes is EqualUnmodifiableMapView) return _perEventMinutes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_perEventMinutes);
}

/// Rules that replace an event's rule during Ramadan (Appendix A
/// `adjustments.ramadan`, §6.4 ¶6; applied from S08).
 final  Map<PrayerEvent, EventRule> _ramadanRules;
/// Rules that replace an event's rule during Ramadan (Appendix A
/// `adjustments.ramadan`, §6.4 ¶6; applied from S08).
@override@JsonKey() Map<PrayerEvent, EventRule> get ramadanRules {
  if (_ramadanRules is EqualUnmodifiableMapView) return _ramadanRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ramadanRules);
}

/// How elevation enters horizon events.
@override@JsonKey() final  HorizonElevationPolicy elevationPolicy;
/// The benchmark report an `Authority aligned` label cites (Appendix A
/// `evidence.benchmarkReportId`).
@override final  String? benchmarkReportId;

/// Create a copy of PrayerProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrayerProfileCopyWith<_PrayerProfile> get copyWith => __$PrayerProfileCopyWithImpl<_PrayerProfile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrayerProfile&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.version, version) || other.version == version)&&(identical(other.status, status) || other.status == status)&&(identical(other.effectiveFrom, effectiveFrom) || other.effectiveFrom == effectiveFrom)&&const DeepCollectionEquality().equals(other.countries, _countries)&&(identical(other.authorityName, authorityName) || other.authorityName == authorityName)&&(identical(other.authorityType, authorityType) || other.authorityType == authorityType)&&(identical(other.referenceMode, referenceMode) || other.referenceMode == referenceMode)&&const DeepCollectionEquality().equals(other.rules, _rules)&&const DeepCollectionEquality().equals(other.highLatitudeChain, _highLatitudeChain)&&(identical(other.roundingDefault, roundingDefault) || other.roundingDefault == roundingDefault)&&(identical(other.maxAbsMinutes, maxAbsMinutes) || other.maxAbsMinutes == maxAbsMinutes)&&(identical(other.hasReligiousApproval, hasReligiousApproval) || other.hasReligiousApproval == hasReligiousApproval)&&(identical(other.minEngineSchema, minEngineSchema) || other.minEngineSchema == minEngineSchema)&&(identical(other.effectiveTo, effectiveTo) || other.effectiveTo == effectiveTo)&&const DeepCollectionEquality().equals(other.referencePoints, _referencePoints)&&const DeepCollectionEquality().equals(other.roundingOverrides, _roundingOverrides)&&const DeepCollectionEquality().equals(other.perEventMinutes, _perEventMinutes)&&const DeepCollectionEquality().equals(other.ramadanRules, _ramadanRules)&&(identical(other.elevationPolicy, elevationPolicy) || other.elevationPolicy == elevationPolicy)&&(identical(other.benchmarkReportId, benchmarkReportId) || other.benchmarkReportId == benchmarkReportId));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,profileId,version,status,effectiveFrom,const DeepCollectionEquality().hash(_countries),authorityName,authorityType,referenceMode,const DeepCollectionEquality().hash(_rules),const DeepCollectionEquality().hash(_highLatitudeChain),roundingDefault,maxAbsMinutes,hasReligiousApproval,minEngineSchema,effectiveTo,const DeepCollectionEquality().hash(_referencePoints),const DeepCollectionEquality().hash(_roundingOverrides),const DeepCollectionEquality().hash(_perEventMinutes),const DeepCollectionEquality().hash(_ramadanRules),elevationPolicy,benchmarkReportId]);
}

@override
String toString() {
    return 'PrayerProfile(profileId: $profileId, version: $version, status: $status, effectiveFrom: $effectiveFrom, countries: $countries, authorityName: $authorityName, authorityType: $authorityType, referenceMode: $referenceMode, rules: $rules, highLatitudeChain: $highLatitudeChain, roundingDefault: $roundingDefault, maxAbsMinutes: $maxAbsMinutes, hasReligiousApproval: $hasReligiousApproval, minEngineSchema: $minEngineSchema, effectiveTo: $effectiveTo, referencePoints: $referencePoints, roundingOverrides: $roundingOverrides, perEventMinutes: $perEventMinutes, ramadanRules: $ramadanRules, elevationPolicy: $elevationPolicy, benchmarkReportId: $benchmarkReportId)';
}


}

/// @nodoc
abstract mixin class _$PrayerProfileCopyWith<$Res> implements $PrayerProfileCopyWith<$Res> {
  factory _$PrayerProfileCopyWith(_PrayerProfile value, $Res Function(_PrayerProfile) _then) = __$PrayerProfileCopyWithImpl;
@override @useResult
$Res call({
 String profileId, String version, ProfileStatus status, CivilDate effectiveFrom, List<String> countries, String authorityName, AuthorityType authorityType, ReferenceMode referenceMode, Map<PrayerEvent, EventRule> rules, List<HighLatitudeMethod> highLatitudeChain, RoundingMode roundingDefault, int maxAbsMinutes, bool hasReligiousApproval, int minEngineSchema, CivilDate? effectiveTo, List<ReferencePoint> referencePoints, Map<PrayerEvent, RoundingMode> roundingOverrides, Map<PrayerEvent, int> perEventMinutes, Map<PrayerEvent, EventRule> ramadanRules, HorizonElevationPolicy elevationPolicy, String? benchmarkReportId
});




}
/// @nodoc
class __$PrayerProfileCopyWithImpl<$Res>
    implements _$PrayerProfileCopyWith<$Res> {
  __$PrayerProfileCopyWithImpl(this._self, this._then);

  final _PrayerProfile _self;
  final $Res Function(_PrayerProfile) _then;

/// Create a copy of PrayerProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = null,Object? version = null,Object? status = null,Object? effectiveFrom = null,Object? countries = null,Object? authorityName = null,Object? authorityType = null,Object? referenceMode = null,Object? rules = null,Object? highLatitudeChain = null,Object? roundingDefault = null,Object? maxAbsMinutes = null,Object? hasReligiousApproval = null,Object? minEngineSchema = null,Object? effectiveTo = freezed,Object? referencePoints = null,Object? roundingOverrides = null,Object? perEventMinutes = null,Object? ramadanRules = null,Object? elevationPolicy = null,Object? benchmarkReportId = freezed,}) {
  return _then(_PrayerProfile(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatus,effectiveFrom: null == effectiveFrom ? _self.effectiveFrom : effectiveFrom // ignore: cast_nullable_to_non_nullable
as CivilDate,countries: null == countries ? _self._countries : countries // ignore: cast_nullable_to_non_nullable
as List<String>,authorityName: null == authorityName ? _self.authorityName : authorityName // ignore: cast_nullable_to_non_nullable
as String,authorityType: null == authorityType ? _self.authorityType : authorityType // ignore: cast_nullable_to_non_nullable
as AuthorityType,referenceMode: null == referenceMode ? _self.referenceMode : referenceMode // ignore: cast_nullable_to_non_nullable
as ReferenceMode,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, EventRule>,highLatitudeChain: null == highLatitudeChain ? _self._highLatitudeChain : highLatitudeChain // ignore: cast_nullable_to_non_nullable
as List<HighLatitudeMethod>,roundingDefault: null == roundingDefault ? _self.roundingDefault : roundingDefault // ignore: cast_nullable_to_non_nullable
as RoundingMode,maxAbsMinutes: null == maxAbsMinutes ? _self.maxAbsMinutes : maxAbsMinutes // ignore: cast_nullable_to_non_nullable
as int,hasReligiousApproval: null == hasReligiousApproval ? _self.hasReligiousApproval : hasReligiousApproval // ignore: cast_nullable_to_non_nullable
as bool,minEngineSchema: null == minEngineSchema ? _self.minEngineSchema : minEngineSchema // ignore: cast_nullable_to_non_nullable
as int,effectiveTo: freezed == effectiveTo ? _self.effectiveTo : effectiveTo // ignore: cast_nullable_to_non_nullable
as CivilDate?,referencePoints: null == referencePoints ? _self._referencePoints : referencePoints // ignore: cast_nullable_to_non_nullable
as List<ReferencePoint>,roundingOverrides: null == roundingOverrides ? _self._roundingOverrides : roundingOverrides // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, RoundingMode>,perEventMinutes: null == perEventMinutes ? _self._perEventMinutes : perEventMinutes // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, int>,ramadanRules: null == ramadanRules ? _self._ramadanRules : ramadanRules // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, EventRule>,elevationPolicy: null == elevationPolicy ? _self.elevationPolicy : elevationPolicy // ignore: cast_nullable_to_non_nullable
as HorizonElevationPolicy,benchmarkReportId: freezed == benchmarkReportId ? _self.benchmarkReportId : benchmarkReportId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
