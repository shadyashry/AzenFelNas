// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prayer_profile_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrayerProfileDocument {

/// `<iso2>.<authority>.<variant>` or `engine.default`.
 String get profileId;/// Schema version; 1.
 int get schemaVersion;/// Profile version `YYYY.M.N`.
 String get version;/// Lifecycle status.
 ProfileStatusCode get status;/// First day the profile applies, `YYYY-MM-DD`.
 String get effectiveFrom;/// Last day, or `null`; always written.
 String? get effectiveTo;/// Geographic scope.
 ProfileScopeDocument get scope;/// Authority.
 AuthorityDocument get authority;/// Reference mode.
 ReferenceModeCode get referenceMode;/// Reference points.
 List<ReferencePointDocument> get referencePoints;/// Rule per event.
 RulesDocument get rules;/// Horizon settings.
 HorizonDocument get horizon;/// High-latitude chain.
 HighLatitudeDocument get highLatitude;/// `default` plus per-event overrides.
 Map<String, RoundingModeCode> get rounding;/// Adjustments.
 AdjustmentsDocument get adjustments;/// Evidence.
 EvidenceDocument get evidence;/// Approvals.
 ApprovalsDocument get approvals;/// Compatibility.
 CompatibilityDocument get compatibility;
/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrayerProfileDocumentCopyWith<PrayerProfileDocument> get copyWith => _$PrayerProfileDocumentCopyWithImpl<PrayerProfileDocument>(this as PrayerProfileDocument, _$identity);

  /// Serializes this PrayerProfileDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PrayerProfileDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrayerProfileDocument&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.effectiveFrom, _this.effectiveFrom) || other.effectiveFrom == _this.effectiveFrom)&&(identical(other.effectiveTo, _this.effectiveTo) || other.effectiveTo == _this.effectiveTo)&&(identical(other.scope, _this.scope) || other.scope == _this.scope)&&(identical(other.authority, _this.authority) || other.authority == _this.authority)&&(identical(other.referenceMode, _this.referenceMode) || other.referenceMode == _this.referenceMode)&&const DeepCollectionEquality().equals(other.referencePoints, _this.referencePoints)&&(identical(other.rules, _this.rules) || other.rules == _this.rules)&&(identical(other.horizon, _this.horizon) || other.horizon == _this.horizon)&&(identical(other.highLatitude, _this.highLatitude) || other.highLatitude == _this.highLatitude)&&const DeepCollectionEquality().equals(other.rounding, _this.rounding)&&(identical(other.adjustments, _this.adjustments) || other.adjustments == _this.adjustments)&&(identical(other.evidence, _this.evidence) || other.evidence == _this.evidence)&&(identical(other.approvals, _this.approvals) || other.approvals == _this.approvals)&&(identical(other.compatibility, _this.compatibility) || other.compatibility == _this.compatibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PrayerProfileDocument;
  return Object.hash(runtimeType,_this.profileId,_this.schemaVersion,_this.version,_this.status,_this.effectiveFrom,_this.effectiveTo,_this.scope,_this.authority,_this.referenceMode,const DeepCollectionEquality().hash(_this.referencePoints),_this.rules,_this.horizon,_this.highLatitude,const DeepCollectionEquality().hash(_this.rounding),_this.adjustments,_this.evidence,_this.approvals,_this.compatibility);
}

@override
String toString() {
  final _this = this as PrayerProfileDocument;
  return 'PrayerProfileDocument(profileId: ${_this.profileId}, schemaVersion: ${_this.schemaVersion}, version: ${_this.version}, status: ${_this.status}, effectiveFrom: ${_this.effectiveFrom}, effectiveTo: ${_this.effectiveTo}, scope: ${_this.scope}, authority: ${_this.authority}, referenceMode: ${_this.referenceMode}, referencePoints: ${_this.referencePoints}, rules: ${_this.rules}, horizon: ${_this.horizon}, highLatitude: ${_this.highLatitude}, rounding: ${_this.rounding}, adjustments: ${_this.adjustments}, evidence: ${_this.evidence}, approvals: ${_this.approvals}, compatibility: ${_this.compatibility})';
}


}

/// @nodoc
abstract mixin class $PrayerProfileDocumentCopyWith<$Res>  {
  factory $PrayerProfileDocumentCopyWith(PrayerProfileDocument value, $Res Function(PrayerProfileDocument) _then) = _$PrayerProfileDocumentCopyWithImpl;
@useResult
$Res call({
 String profileId, int schemaVersion, String version, ProfileStatusCode status, String effectiveFrom, String? effectiveTo, ProfileScopeDocument scope, AuthorityDocument authority, ReferenceModeCode referenceMode, List<ReferencePointDocument> referencePoints, RulesDocument rules, HorizonDocument horizon, HighLatitudeDocument highLatitude, Map<String, RoundingModeCode> rounding, AdjustmentsDocument adjustments, EvidenceDocument evidence, ApprovalsDocument approvals, CompatibilityDocument compatibility
});


$ProfileScopeDocumentCopyWith<$Res> get scope;$AuthorityDocumentCopyWith<$Res> get authority;$RulesDocumentCopyWith<$Res> get rules;$HorizonDocumentCopyWith<$Res> get horizon;$HighLatitudeDocumentCopyWith<$Res> get highLatitude;$AdjustmentsDocumentCopyWith<$Res> get adjustments;$EvidenceDocumentCopyWith<$Res> get evidence;$ApprovalsDocumentCopyWith<$Res> get approvals;$CompatibilityDocumentCopyWith<$Res> get compatibility;

}
/// @nodoc
class _$PrayerProfileDocumentCopyWithImpl<$Res>
    implements $PrayerProfileDocumentCopyWith<$Res> {
  _$PrayerProfileDocumentCopyWithImpl(this._self, this._then);

  final PrayerProfileDocument _self;
  final $Res Function(PrayerProfileDocument) _then;

/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = null,Object? schemaVersion = null,Object? version = null,Object? status = null,Object? effectiveFrom = null,Object? effectiveTo = freezed,Object? scope = null,Object? authority = null,Object? referenceMode = null,Object? referencePoints = null,Object? rules = null,Object? horizon = null,Object? highLatitude = null,Object? rounding = null,Object? adjustments = null,Object? evidence = null,Object? approvals = null,Object? compatibility = null,}) {
  return _then(PrayerProfileDocument(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatusCode,effectiveFrom: null == effectiveFrom ? _self.effectiveFrom : effectiveFrom // ignore: cast_nullable_to_non_nullable
as String,effectiveTo: freezed == effectiveTo ? _self.effectiveTo : effectiveTo // ignore: cast_nullable_to_non_nullable
as String?,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ProfileScopeDocument,authority: null == authority ? _self.authority : authority // ignore: cast_nullable_to_non_nullable
as AuthorityDocument,referenceMode: null == referenceMode ? _self.referenceMode : referenceMode // ignore: cast_nullable_to_non_nullable
as ReferenceModeCode,referencePoints: null == referencePoints ? _self.referencePoints : referencePoints // ignore: cast_nullable_to_non_nullable
as List<ReferencePointDocument>,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as RulesDocument,horizon: null == horizon ? _self.horizon : horizon // ignore: cast_nullable_to_non_nullable
as HorizonDocument,highLatitude: null == highLatitude ? _self.highLatitude : highLatitude // ignore: cast_nullable_to_non_nullable
as HighLatitudeDocument,rounding: null == rounding ? _self.rounding : rounding // ignore: cast_nullable_to_non_nullable
as Map<String, RoundingModeCode>,adjustments: null == adjustments ? _self.adjustments : adjustments // ignore: cast_nullable_to_non_nullable
as AdjustmentsDocument,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as EvidenceDocument,approvals: null == approvals ? _self.approvals : approvals // ignore: cast_nullable_to_non_nullable
as ApprovalsDocument,compatibility: null == compatibility ? _self.compatibility : compatibility // ignore: cast_nullable_to_non_nullable
as CompatibilityDocument,
  ));
}
/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileScopeDocumentCopyWith<$Res> get scope {
  
  return $ProfileScopeDocumentCopyWith<$Res>(_self.scope, (value) {
    return _then(_self.copyWith(scope: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorityDocumentCopyWith<$Res> get authority {
  
  return $AuthorityDocumentCopyWith<$Res>(_self.authority, (value) {
    return _then(_self.copyWith(authority: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RulesDocumentCopyWith<$Res> get rules {
  
  return $RulesDocumentCopyWith<$Res>(_self.rules, (value) {
    return _then(_self.copyWith(rules: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HorizonDocumentCopyWith<$Res> get horizon {
  
  return $HorizonDocumentCopyWith<$Res>(_self.horizon, (value) {
    return _then(_self.copyWith(horizon: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HighLatitudeDocumentCopyWith<$Res> get highLatitude {
  
  return $HighLatitudeDocumentCopyWith<$Res>(_self.highLatitude, (value) {
    return _then(_self.copyWith(highLatitude: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdjustmentsDocumentCopyWith<$Res> get adjustments {
  
  return $AdjustmentsDocumentCopyWith<$Res>(_self.adjustments, (value) {
    return _then(_self.copyWith(adjustments: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EvidenceDocumentCopyWith<$Res> get evidence {
  
  return $EvidenceDocumentCopyWith<$Res>(_self.evidence, (value) {
    return _then(_self.copyWith(evidence: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApprovalsDocumentCopyWith<$Res> get approvals {
  
  return $ApprovalsDocumentCopyWith<$Res>(_self.approvals, (value) {
    return _then(_self.copyWith(approvals: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompatibilityDocumentCopyWith<$Res> get compatibility {
  
  return $CompatibilityDocumentCopyWith<$Res>(_self.compatibility, (value) {
    return _then(_self.copyWith(compatibility: value));
  });
}
}


/// Adds pattern-matching-related methods to [PrayerProfileDocument].
extension PrayerProfileDocumentPatterns on PrayerProfileDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrayerProfileDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrayerProfileDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrayerProfileDocument value)  $default,){
final _that = this;
switch (_that) {
case _PrayerProfileDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrayerProfileDocument value)?  $default,){
final _that = this;
switch (_that) {
case _PrayerProfileDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String profileId,  int schemaVersion,  String version,  ProfileStatusCode status,  String effectiveFrom,  String? effectiveTo,  ProfileScopeDocument scope,  AuthorityDocument authority,  ReferenceModeCode referenceMode,  List<ReferencePointDocument> referencePoints,  RulesDocument rules,  HorizonDocument horizon,  HighLatitudeDocument highLatitude,  Map<String, RoundingModeCode> rounding,  AdjustmentsDocument adjustments,  EvidenceDocument evidence,  ApprovalsDocument approvals,  CompatibilityDocument compatibility)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrayerProfileDocument() when $default != null:
return $default(_that.profileId,_that.schemaVersion,_that.version,_that.status,_that.effectiveFrom,_that.effectiveTo,_that.scope,_that.authority,_that.referenceMode,_that.referencePoints,_that.rules,_that.horizon,_that.highLatitude,_that.rounding,_that.adjustments,_that.evidence,_that.approvals,_that.compatibility);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String profileId,  int schemaVersion,  String version,  ProfileStatusCode status,  String effectiveFrom,  String? effectiveTo,  ProfileScopeDocument scope,  AuthorityDocument authority,  ReferenceModeCode referenceMode,  List<ReferencePointDocument> referencePoints,  RulesDocument rules,  HorizonDocument horizon,  HighLatitudeDocument highLatitude,  Map<String, RoundingModeCode> rounding,  AdjustmentsDocument adjustments,  EvidenceDocument evidence,  ApprovalsDocument approvals,  CompatibilityDocument compatibility)  $default,) {final _that = this;
switch (_that) {
case _PrayerProfileDocument():
return $default(_that.profileId,_that.schemaVersion,_that.version,_that.status,_that.effectiveFrom,_that.effectiveTo,_that.scope,_that.authority,_that.referenceMode,_that.referencePoints,_that.rules,_that.horizon,_that.highLatitude,_that.rounding,_that.adjustments,_that.evidence,_that.approvals,_that.compatibility);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String profileId,  int schemaVersion,  String version,  ProfileStatusCode status,  String effectiveFrom,  String? effectiveTo,  ProfileScopeDocument scope,  AuthorityDocument authority,  ReferenceModeCode referenceMode,  List<ReferencePointDocument> referencePoints,  RulesDocument rules,  HorizonDocument horizon,  HighLatitudeDocument highLatitude,  Map<String, RoundingModeCode> rounding,  AdjustmentsDocument adjustments,  EvidenceDocument evidence,  ApprovalsDocument approvals,  CompatibilityDocument compatibility)?  $default,) {final _that = this;
switch (_that) {
case _PrayerProfileDocument() when $default != null:
return $default(_that.profileId,_that.schemaVersion,_that.version,_that.status,_that.effectiveFrom,_that.effectiveTo,_that.scope,_that.authority,_that.referenceMode,_that.referencePoints,_that.rules,_that.horizon,_that.highLatitude,_that.rounding,_that.adjustments,_that.evidence,_that.approvals,_that.compatibility);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrayerProfileDocument implements PrayerProfileDocument {
  const _PrayerProfileDocument({required this.profileId, required this.schemaVersion, required this.version, required this.status, required this.effectiveFrom, required this.effectiveTo, required this.scope, required this.authority, required this.referenceMode, required  List<ReferencePointDocument> referencePoints, required this.rules, required this.horizon, required this.highLatitude, required  Map<String, RoundingModeCode> rounding, required this.adjustments, required this.evidence, required this.approvals, required this.compatibility}): _referencePoints = referencePoints,_rounding = rounding;
  factory _PrayerProfileDocument.fromJson(Map<String, dynamic> json) => _$PrayerProfileDocumentFromJson(json);

/// `<iso2>.<authority>.<variant>` or `engine.default`.
@override final  String profileId;
/// Schema version; 1.
@override final  int schemaVersion;
/// Profile version `YYYY.M.N`.
@override final  String version;
/// Lifecycle status.
@override final  ProfileStatusCode status;
/// First day the profile applies, `YYYY-MM-DD`.
@override final  String effectiveFrom;
/// Last day, or `null`; always written.
@override final  String? effectiveTo;
/// Geographic scope.
@override final  ProfileScopeDocument scope;
/// Authority.
@override final  AuthorityDocument authority;
/// Reference mode.
@override final  ReferenceModeCode referenceMode;
/// Reference points.
 final  List<ReferencePointDocument> _referencePoints;
/// Reference points.
@override List<ReferencePointDocument> get referencePoints {
  if (_referencePoints is EqualUnmodifiableListView) return _referencePoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_referencePoints);
}

/// Rule per event.
@override final  RulesDocument rules;
/// Horizon settings.
@override final  HorizonDocument horizon;
/// High-latitude chain.
@override final  HighLatitudeDocument highLatitude;
/// `default` plus per-event overrides.
 final  Map<String, RoundingModeCode> _rounding;
/// `default` plus per-event overrides.
@override Map<String, RoundingModeCode> get rounding {
  if (_rounding is EqualUnmodifiableMapView) return _rounding;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rounding);
}

/// Adjustments.
@override final  AdjustmentsDocument adjustments;
/// Evidence.
@override final  EvidenceDocument evidence;
/// Approvals.
@override final  ApprovalsDocument approvals;
/// Compatibility.
@override final  CompatibilityDocument compatibility;

/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrayerProfileDocumentCopyWith<_PrayerProfileDocument> get copyWith => __$PrayerProfileDocumentCopyWithImpl<_PrayerProfileDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrayerProfileDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrayerProfileDocument&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.version, version) || other.version == version)&&(identical(other.status, status) || other.status == status)&&(identical(other.effectiveFrom, effectiveFrom) || other.effectiveFrom == effectiveFrom)&&(identical(other.effectiveTo, effectiveTo) || other.effectiveTo == effectiveTo)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.authority, authority) || other.authority == authority)&&(identical(other.referenceMode, referenceMode) || other.referenceMode == referenceMode)&&const DeepCollectionEquality().equals(other.referencePoints, _referencePoints)&&(identical(other.rules, rules) || other.rules == rules)&&(identical(other.horizon, horizon) || other.horizon == horizon)&&(identical(other.highLatitude, highLatitude) || other.highLatitude == highLatitude)&&const DeepCollectionEquality().equals(other.rounding, _rounding)&&(identical(other.adjustments, adjustments) || other.adjustments == adjustments)&&(identical(other.evidence, evidence) || other.evidence == evidence)&&(identical(other.approvals, approvals) || other.approvals == approvals)&&(identical(other.compatibility, compatibility) || other.compatibility == compatibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,profileId,schemaVersion,version,status,effectiveFrom,effectiveTo,scope,authority,referenceMode,const DeepCollectionEquality().hash(_referencePoints),rules,horizon,highLatitude,const DeepCollectionEquality().hash(_rounding),adjustments,evidence,approvals,compatibility);
}

@override
String toString() {
    return 'PrayerProfileDocument(profileId: $profileId, schemaVersion: $schemaVersion, version: $version, status: $status, effectiveFrom: $effectiveFrom, effectiveTo: $effectiveTo, scope: $scope, authority: $authority, referenceMode: $referenceMode, referencePoints: $referencePoints, rules: $rules, horizon: $horizon, highLatitude: $highLatitude, rounding: $rounding, adjustments: $adjustments, evidence: $evidence, approvals: $approvals, compatibility: $compatibility)';
}


}

/// @nodoc
abstract mixin class _$PrayerProfileDocumentCopyWith<$Res> implements $PrayerProfileDocumentCopyWith<$Res> {
  factory _$PrayerProfileDocumentCopyWith(_PrayerProfileDocument value, $Res Function(_PrayerProfileDocument) _then) = __$PrayerProfileDocumentCopyWithImpl;
@override @useResult
$Res call({
 String profileId, int schemaVersion, String version, ProfileStatusCode status, String effectiveFrom, String? effectiveTo, ProfileScopeDocument scope, AuthorityDocument authority, ReferenceModeCode referenceMode, List<ReferencePointDocument> referencePoints, RulesDocument rules, HorizonDocument horizon, HighLatitudeDocument highLatitude, Map<String, RoundingModeCode> rounding, AdjustmentsDocument adjustments, EvidenceDocument evidence, ApprovalsDocument approvals, CompatibilityDocument compatibility
});


@override $ProfileScopeDocumentCopyWith<$Res> get scope;@override $AuthorityDocumentCopyWith<$Res> get authority;@override $RulesDocumentCopyWith<$Res> get rules;@override $HorizonDocumentCopyWith<$Res> get horizon;@override $HighLatitudeDocumentCopyWith<$Res> get highLatitude;@override $AdjustmentsDocumentCopyWith<$Res> get adjustments;@override $EvidenceDocumentCopyWith<$Res> get evidence;@override $ApprovalsDocumentCopyWith<$Res> get approvals;@override $CompatibilityDocumentCopyWith<$Res> get compatibility;

}
/// @nodoc
class __$PrayerProfileDocumentCopyWithImpl<$Res>
    implements _$PrayerProfileDocumentCopyWith<$Res> {
  __$PrayerProfileDocumentCopyWithImpl(this._self, this._then);

  final _PrayerProfileDocument _self;
  final $Res Function(_PrayerProfileDocument) _then;

/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = null,Object? schemaVersion = null,Object? version = null,Object? status = null,Object? effectiveFrom = null,Object? effectiveTo = freezed,Object? scope = null,Object? authority = null,Object? referenceMode = null,Object? referencePoints = null,Object? rules = null,Object? horizon = null,Object? highLatitude = null,Object? rounding = null,Object? adjustments = null,Object? evidence = null,Object? approvals = null,Object? compatibility = null,}) {
  return _then(_PrayerProfileDocument(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatusCode,effectiveFrom: null == effectiveFrom ? _self.effectiveFrom : effectiveFrom // ignore: cast_nullable_to_non_nullable
as String,effectiveTo: freezed == effectiveTo ? _self.effectiveTo : effectiveTo // ignore: cast_nullable_to_non_nullable
as String?,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ProfileScopeDocument,authority: null == authority ? _self.authority : authority // ignore: cast_nullable_to_non_nullable
as AuthorityDocument,referenceMode: null == referenceMode ? _self.referenceMode : referenceMode // ignore: cast_nullable_to_non_nullable
as ReferenceModeCode,referencePoints: null == referencePoints ? _self._referencePoints : referencePoints // ignore: cast_nullable_to_non_nullable
as List<ReferencePointDocument>,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as RulesDocument,horizon: null == horizon ? _self.horizon : horizon // ignore: cast_nullable_to_non_nullable
as HorizonDocument,highLatitude: null == highLatitude ? _self.highLatitude : highLatitude // ignore: cast_nullable_to_non_nullable
as HighLatitudeDocument,rounding: null == rounding ? _self._rounding : rounding // ignore: cast_nullable_to_non_nullable
as Map<String, RoundingModeCode>,adjustments: null == adjustments ? _self.adjustments : adjustments // ignore: cast_nullable_to_non_nullable
as AdjustmentsDocument,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as EvidenceDocument,approvals: null == approvals ? _self.approvals : approvals // ignore: cast_nullable_to_non_nullable
as ApprovalsDocument,compatibility: null == compatibility ? _self.compatibility : compatibility // ignore: cast_nullable_to_non_nullable
as CompatibilityDocument,
  ));
}

/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileScopeDocumentCopyWith<$Res> get scope {
  
  return $ProfileScopeDocumentCopyWith<$Res>(_self.scope, (value) {
    return _then(_self.copyWith(scope: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorityDocumentCopyWith<$Res> get authority {
  
  return $AuthorityDocumentCopyWith<$Res>(_self.authority, (value) {
    return _then(_self.copyWith(authority: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RulesDocumentCopyWith<$Res> get rules {
  
  return $RulesDocumentCopyWith<$Res>(_self.rules, (value) {
    return _then(_self.copyWith(rules: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HorizonDocumentCopyWith<$Res> get horizon {
  
  return $HorizonDocumentCopyWith<$Res>(_self.horizon, (value) {
    return _then(_self.copyWith(horizon: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HighLatitudeDocumentCopyWith<$Res> get highLatitude {
  
  return $HighLatitudeDocumentCopyWith<$Res>(_self.highLatitude, (value) {
    return _then(_self.copyWith(highLatitude: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdjustmentsDocumentCopyWith<$Res> get adjustments {
  
  return $AdjustmentsDocumentCopyWith<$Res>(_self.adjustments, (value) {
    return _then(_self.copyWith(adjustments: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EvidenceDocumentCopyWith<$Res> get evidence {
  
  return $EvidenceDocumentCopyWith<$Res>(_self.evidence, (value) {
    return _then(_self.copyWith(evidence: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApprovalsDocumentCopyWith<$Res> get approvals {
  
  return $ApprovalsDocumentCopyWith<$Res>(_self.approvals, (value) {
    return _then(_self.copyWith(approvals: value));
  });
}/// Create a copy of PrayerProfileDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompatibilityDocumentCopyWith<$Res> get compatibility {
  
  return $CompatibilityDocumentCopyWith<$Res>(_self.compatibility, (value) {
    return _then(_self.copyWith(compatibility: value));
  });
}
}

// dart format on
