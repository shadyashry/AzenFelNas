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
 ProfileStatus get status;/// Who stands behind the profile (Appendix A `authority.type`).
 AuthorityType get authorityType;/// The rule of each calculated event.
 Map<PrayerEvent, EventRule> get rules;/// Rounding of every event without an override (Appendix A
/// `rounding.default`).
 RoundingMode get roundingDefault;/// Per-event rounding overrides (Appendix A `rounding.<event>`).
 Map<PrayerEvent, RoundingMode> get roundingOverrides;/// Additive whole-minute offsets per event (Appendix A
/// `adjustments.perEventMinutes`, §6.4 ¶8).
 Map<PrayerEvent, int> get perEventMinutes;/// Largest allowed `|perEventMinutes|` (Appendix A
/// `adjustments.maxAbsMinutes`); an offset beyond it is
/// `EngineFailure.invalidProfile`.
 int get maxAbsMinutes;/// How elevation enters horizon events.
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrayerProfile&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.authorityType, _this.authorityType) || other.authorityType == _this.authorityType)&&const DeepCollectionEquality().equals(other.rules, _this.rules)&&(identical(other.roundingDefault, _this.roundingDefault) || other.roundingDefault == _this.roundingDefault)&&const DeepCollectionEquality().equals(other.roundingOverrides, _this.roundingOverrides)&&const DeepCollectionEquality().equals(other.perEventMinutes, _this.perEventMinutes)&&(identical(other.maxAbsMinutes, _this.maxAbsMinutes) || other.maxAbsMinutes == _this.maxAbsMinutes)&&(identical(other.elevationPolicy, _this.elevationPolicy) || other.elevationPolicy == _this.elevationPolicy)&&(identical(other.benchmarkReportId, _this.benchmarkReportId) || other.benchmarkReportId == _this.benchmarkReportId));
}


@override
int get hashCode {
  final _this = this as PrayerProfile;
  return Object.hash(runtimeType,_this.profileId,_this.version,_this.status,_this.authorityType,const DeepCollectionEquality().hash(_this.rules),_this.roundingDefault,const DeepCollectionEquality().hash(_this.roundingOverrides),const DeepCollectionEquality().hash(_this.perEventMinutes),_this.maxAbsMinutes,_this.elevationPolicy,_this.benchmarkReportId);
}

@override
String toString() {
  final _this = this as PrayerProfile;
  return 'PrayerProfile(profileId: ${_this.profileId}, version: ${_this.version}, status: ${_this.status}, authorityType: ${_this.authorityType}, rules: ${_this.rules}, roundingDefault: ${_this.roundingDefault}, roundingOverrides: ${_this.roundingOverrides}, perEventMinutes: ${_this.perEventMinutes}, maxAbsMinutes: ${_this.maxAbsMinutes}, elevationPolicy: ${_this.elevationPolicy}, benchmarkReportId: ${_this.benchmarkReportId})';
}


}

/// @nodoc
abstract mixin class $PrayerProfileCopyWith<$Res>  {
  factory $PrayerProfileCopyWith(PrayerProfile value, $Res Function(PrayerProfile) _then) = _$PrayerProfileCopyWithImpl;
@useResult
$Res call({
 String profileId, String version, ProfileStatus status, AuthorityType authorityType, Map<PrayerEvent, EventRule> rules, RoundingMode roundingDefault, Map<PrayerEvent, RoundingMode> roundingOverrides, Map<PrayerEvent, int> perEventMinutes, int maxAbsMinutes, HorizonElevationPolicy elevationPolicy, String? benchmarkReportId
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
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = null,Object? version = null,Object? status = null,Object? authorityType = null,Object? rules = null,Object? roundingDefault = null,Object? roundingOverrides = null,Object? perEventMinutes = null,Object? maxAbsMinutes = null,Object? elevationPolicy = null,Object? benchmarkReportId = freezed,}) {
  return _then(PrayerProfile(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatus,authorityType: null == authorityType ? _self.authorityType : authorityType // ignore: cast_nullable_to_non_nullable
as AuthorityType,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, EventRule>,roundingDefault: null == roundingDefault ? _self.roundingDefault : roundingDefault // ignore: cast_nullable_to_non_nullable
as RoundingMode,roundingOverrides: null == roundingOverrides ? _self.roundingOverrides : roundingOverrides // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, RoundingMode>,perEventMinutes: null == perEventMinutes ? _self.perEventMinutes : perEventMinutes // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, int>,maxAbsMinutes: null == maxAbsMinutes ? _self.maxAbsMinutes : maxAbsMinutes // ignore: cast_nullable_to_non_nullable
as int,elevationPolicy: null == elevationPolicy ? _self.elevationPolicy : elevationPolicy // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String profileId,  String version,  ProfileStatus status,  AuthorityType authorityType,  Map<PrayerEvent, EventRule> rules,  RoundingMode roundingDefault,  Map<PrayerEvent, RoundingMode> roundingOverrides,  Map<PrayerEvent, int> perEventMinutes,  int maxAbsMinutes,  HorizonElevationPolicy elevationPolicy,  String? benchmarkReportId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrayerProfile() when $default != null:
return $default(_that.profileId,_that.version,_that.status,_that.authorityType,_that.rules,_that.roundingDefault,_that.roundingOverrides,_that.perEventMinutes,_that.maxAbsMinutes,_that.elevationPolicy,_that.benchmarkReportId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String profileId,  String version,  ProfileStatus status,  AuthorityType authorityType,  Map<PrayerEvent, EventRule> rules,  RoundingMode roundingDefault,  Map<PrayerEvent, RoundingMode> roundingOverrides,  Map<PrayerEvent, int> perEventMinutes,  int maxAbsMinutes,  HorizonElevationPolicy elevationPolicy,  String? benchmarkReportId)  $default,) {final _that = this;
switch (_that) {
case _PrayerProfile():
return $default(_that.profileId,_that.version,_that.status,_that.authorityType,_that.rules,_that.roundingDefault,_that.roundingOverrides,_that.perEventMinutes,_that.maxAbsMinutes,_that.elevationPolicy,_that.benchmarkReportId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String profileId,  String version,  ProfileStatus status,  AuthorityType authorityType,  Map<PrayerEvent, EventRule> rules,  RoundingMode roundingDefault,  Map<PrayerEvent, RoundingMode> roundingOverrides,  Map<PrayerEvent, int> perEventMinutes,  int maxAbsMinutes,  HorizonElevationPolicy elevationPolicy,  String? benchmarkReportId)?  $default,) {final _that = this;
switch (_that) {
case _PrayerProfile() when $default != null:
return $default(_that.profileId,_that.version,_that.status,_that.authorityType,_that.rules,_that.roundingDefault,_that.roundingOverrides,_that.perEventMinutes,_that.maxAbsMinutes,_that.elevationPolicy,_that.benchmarkReportId);case _:
  return null;

}
}

}

/// @nodoc


class _PrayerProfile implements PrayerProfile {
  const _PrayerProfile({required this.profileId, required this.version, required this.status, required this.authorityType, required  Map<PrayerEvent, EventRule> rules, required this.roundingDefault,  Map<PrayerEvent, RoundingMode> roundingOverrides = const {},  Map<PrayerEvent, int> perEventMinutes = const {}, this.maxAbsMinutes = 0, this.elevationPolicy = HorizonElevationPolicy.none, this.benchmarkReportId}): _rules = rules,_roundingOverrides = roundingOverrides,_perEventMinutes = perEventMinutes;
  

/// `<iso2>.<authority>.<variant>` or `engine.default` (Appendix A).
@override final  String profileId;
/// Profile version, `YYYY.M.N` (Appendix A).
@override final  String version;
/// Governance status (Appendix A `status`).
@override final  ProfileStatus status;
/// Who stands behind the profile (Appendix A `authority.type`).
@override final  AuthorityType authorityType;
/// The rule of each calculated event.
 final  Map<PrayerEvent, EventRule> _rules;
/// The rule of each calculated event.
@override Map<PrayerEvent, EventRule> get rules {
  if (_rules is EqualUnmodifiableMapView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rules);
}

/// Rounding of every event without an override (Appendix A
/// `rounding.default`).
@override final  RoundingMode roundingDefault;
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

/// Largest allowed `|perEventMinutes|` (Appendix A
/// `adjustments.maxAbsMinutes`); an offset beyond it is
/// `EngineFailure.invalidProfile`.
@override@JsonKey() final  int maxAbsMinutes;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrayerProfile&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.version, version) || other.version == version)&&(identical(other.status, status) || other.status == status)&&(identical(other.authorityType, authorityType) || other.authorityType == authorityType)&&const DeepCollectionEquality().equals(other.rules, _rules)&&(identical(other.roundingDefault, roundingDefault) || other.roundingDefault == roundingDefault)&&const DeepCollectionEquality().equals(other.roundingOverrides, _roundingOverrides)&&const DeepCollectionEquality().equals(other.perEventMinutes, _perEventMinutes)&&(identical(other.maxAbsMinutes, maxAbsMinutes) || other.maxAbsMinutes == maxAbsMinutes)&&(identical(other.elevationPolicy, elevationPolicy) || other.elevationPolicy == elevationPolicy)&&(identical(other.benchmarkReportId, benchmarkReportId) || other.benchmarkReportId == benchmarkReportId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,profileId,version,status,authorityType,const DeepCollectionEquality().hash(_rules),roundingDefault,const DeepCollectionEquality().hash(_roundingOverrides),const DeepCollectionEquality().hash(_perEventMinutes),maxAbsMinutes,elevationPolicy,benchmarkReportId);
}

@override
String toString() {
    return 'PrayerProfile(profileId: $profileId, version: $version, status: $status, authorityType: $authorityType, rules: $rules, roundingDefault: $roundingDefault, roundingOverrides: $roundingOverrides, perEventMinutes: $perEventMinutes, maxAbsMinutes: $maxAbsMinutes, elevationPolicy: $elevationPolicy, benchmarkReportId: $benchmarkReportId)';
}


}

/// @nodoc
abstract mixin class _$PrayerProfileCopyWith<$Res> implements $PrayerProfileCopyWith<$Res> {
  factory _$PrayerProfileCopyWith(_PrayerProfile value, $Res Function(_PrayerProfile) _then) = __$PrayerProfileCopyWithImpl;
@override @useResult
$Res call({
 String profileId, String version, ProfileStatus status, AuthorityType authorityType, Map<PrayerEvent, EventRule> rules, RoundingMode roundingDefault, Map<PrayerEvent, RoundingMode> roundingOverrides, Map<PrayerEvent, int> perEventMinutes, int maxAbsMinutes, HorizonElevationPolicy elevationPolicy, String? benchmarkReportId
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
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = null,Object? version = null,Object? status = null,Object? authorityType = null,Object? rules = null,Object? roundingDefault = null,Object? roundingOverrides = null,Object? perEventMinutes = null,Object? maxAbsMinutes = null,Object? elevationPolicy = null,Object? benchmarkReportId = freezed,}) {
  return _then(_PrayerProfile(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatus,authorityType: null == authorityType ? _self.authorityType : authorityType // ignore: cast_nullable_to_non_nullable
as AuthorityType,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, EventRule>,roundingDefault: null == roundingDefault ? _self.roundingDefault : roundingDefault // ignore: cast_nullable_to_non_nullable
as RoundingMode,roundingOverrides: null == roundingOverrides ? _self._roundingOverrides : roundingOverrides // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, RoundingMode>,perEventMinutes: null == perEventMinutes ? _self._perEventMinutes : perEventMinutes // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, int>,maxAbsMinutes: null == maxAbsMinutes ? _self.maxAbsMinutes : maxAbsMinutes // ignore: cast_nullable_to_non_nullable
as int,elevationPolicy: null == elevationPolicy ? _self.elevationPolicy : elevationPolicy // ignore: cast_nullable_to_non_nullable
as HorizonElevationPolicy,benchmarkReportId: freezed == benchmarkReportId ? _self.benchmarkReportId : benchmarkReportId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
