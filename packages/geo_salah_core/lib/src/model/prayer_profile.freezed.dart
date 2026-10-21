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
 String get version;/// The rule of each calculated event.
 Map<PrayerEvent, EventRule> get rules;/// How elevation enters horizon events.
 HorizonElevationPolicy get elevationPolicy;
/// Create a copy of PrayerProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrayerProfileCopyWith<PrayerProfile> get copyWith => _$PrayerProfileCopyWithImpl<PrayerProfile>(this as PrayerProfile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PrayerProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrayerProfile&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.version, _this.version) || other.version == _this.version)&&const DeepCollectionEquality().equals(other.rules, _this.rules)&&(identical(other.elevationPolicy, _this.elevationPolicy) || other.elevationPolicy == _this.elevationPolicy));
}


@override
int get hashCode {
  final _this = this as PrayerProfile;
  return Object.hash(runtimeType,_this.profileId,_this.version,const DeepCollectionEquality().hash(_this.rules),_this.elevationPolicy);
}

@override
String toString() {
  final _this = this as PrayerProfile;
  return 'PrayerProfile(profileId: ${_this.profileId}, version: ${_this.version}, rules: ${_this.rules}, elevationPolicy: ${_this.elevationPolicy})';
}


}

/// @nodoc
abstract mixin class $PrayerProfileCopyWith<$Res>  {
  factory $PrayerProfileCopyWith(PrayerProfile value, $Res Function(PrayerProfile) _then) = _$PrayerProfileCopyWithImpl;
@useResult
$Res call({
 String profileId, String version, Map<PrayerEvent, EventRule> rules, HorizonElevationPolicy elevationPolicy
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
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = null,Object? version = null,Object? rules = null,Object? elevationPolicy = null,}) {
  return _then(PrayerProfile(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, EventRule>,elevationPolicy: null == elevationPolicy ? _self.elevationPolicy : elevationPolicy // ignore: cast_nullable_to_non_nullable
as HorizonElevationPolicy,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String profileId,  String version,  Map<PrayerEvent, EventRule> rules,  HorizonElevationPolicy elevationPolicy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrayerProfile() when $default != null:
return $default(_that.profileId,_that.version,_that.rules,_that.elevationPolicy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String profileId,  String version,  Map<PrayerEvent, EventRule> rules,  HorizonElevationPolicy elevationPolicy)  $default,) {final _that = this;
switch (_that) {
case _PrayerProfile():
return $default(_that.profileId,_that.version,_that.rules,_that.elevationPolicy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String profileId,  String version,  Map<PrayerEvent, EventRule> rules,  HorizonElevationPolicy elevationPolicy)?  $default,) {final _that = this;
switch (_that) {
case _PrayerProfile() when $default != null:
return $default(_that.profileId,_that.version,_that.rules,_that.elevationPolicy);case _:
  return null;

}
}

}

/// @nodoc


class _PrayerProfile implements PrayerProfile {
  const _PrayerProfile({required this.profileId, required this.version, required  Map<PrayerEvent, EventRule> rules, this.elevationPolicy = HorizonElevationPolicy.none}): _rules = rules;
  

/// `<iso2>.<authority>.<variant>` or `engine.default` (Appendix A).
@override final  String profileId;
/// Profile version, `YYYY.M.N` (Appendix A).
@override final  String version;
/// The rule of each calculated event.
 final  Map<PrayerEvent, EventRule> _rules;
/// The rule of each calculated event.
@override Map<PrayerEvent, EventRule> get rules {
  if (_rules is EqualUnmodifiableMapView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rules);
}

/// How elevation enters horizon events.
@override@JsonKey() final  HorizonElevationPolicy elevationPolicy;

/// Create a copy of PrayerProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrayerProfileCopyWith<_PrayerProfile> get copyWith => __$PrayerProfileCopyWithImpl<_PrayerProfile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrayerProfile&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.rules, _rules)&&(identical(other.elevationPolicy, elevationPolicy) || other.elevationPolicy == elevationPolicy));
}


@override
int get hashCode {
    return Object.hash(runtimeType,profileId,version,const DeepCollectionEquality().hash(_rules),elevationPolicy);
}

@override
String toString() {
    return 'PrayerProfile(profileId: $profileId, version: $version, rules: $rules, elevationPolicy: $elevationPolicy)';
}


}

/// @nodoc
abstract mixin class _$PrayerProfileCopyWith<$Res> implements $PrayerProfileCopyWith<$Res> {
  factory _$PrayerProfileCopyWith(_PrayerProfile value, $Res Function(_PrayerProfile) _then) = __$PrayerProfileCopyWithImpl;
@override @useResult
$Res call({
 String profileId, String version, Map<PrayerEvent, EventRule> rules, HorizonElevationPolicy elevationPolicy
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
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = null,Object? version = null,Object? rules = null,Object? elevationPolicy = null,}) {
  return _then(_PrayerProfile(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as Map<PrayerEvent, EventRule>,elevationPolicy: null == elevationPolicy ? _self.elevationPolicy : elevationPolicy // ignore: cast_nullable_to_non_nullable
as HorizonElevationPolicy,
  ));
}


}

// dart format on
