// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hijri_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HijriState {

/// Hijri date of `D`.
 HijriDate get dateAtDawn;/// Hijri date of `D + 1`.
 HijriDate get dateAtNight;/// How the dates were obtained.
 HijriConfidence get confidence;/// Version of the `hijri` package the dates came from, when any.
 String? get packageVersion;
/// Create a copy of HijriState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HijriStateCopyWith<HijriState> get copyWith => _$HijriStateCopyWithImpl<HijriState>(this as HijriState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HijriState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HijriState&&(identical(other.dateAtDawn, _this.dateAtDawn) || other.dateAtDawn == _this.dateAtDawn)&&(identical(other.dateAtNight, _this.dateAtNight) || other.dateAtNight == _this.dateAtNight)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.packageVersion, _this.packageVersion) || other.packageVersion == _this.packageVersion));
}


@override
int get hashCode {
  final _this = this as HijriState;
  return Object.hash(runtimeType,_this.dateAtDawn,_this.dateAtNight,_this.confidence,_this.packageVersion);
}

@override
String toString() {
  final _this = this as HijriState;
  return 'HijriState(dateAtDawn: ${_this.dateAtDawn}, dateAtNight: ${_this.dateAtNight}, confidence: ${_this.confidence}, packageVersion: ${_this.packageVersion})';
}


}

/// @nodoc
abstract mixin class $HijriStateCopyWith<$Res>  {
  factory $HijriStateCopyWith(HijriState value, $Res Function(HijriState) _then) = _$HijriStateCopyWithImpl;
@useResult
$Res call({
 HijriDate dateAtDawn, HijriDate dateAtNight, HijriConfidence confidence, String? packageVersion
});


$HijriDateCopyWith<$Res> get dateAtDawn;$HijriDateCopyWith<$Res> get dateAtNight;

}
/// @nodoc
class _$HijriStateCopyWithImpl<$Res>
    implements $HijriStateCopyWith<$Res> {
  _$HijriStateCopyWithImpl(this._self, this._then);

  final HijriState _self;
  final $Res Function(HijriState) _then;

/// Create a copy of HijriState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateAtDawn = null,Object? dateAtNight = null,Object? confidence = null,Object? packageVersion = freezed,}) {
  return _then(HijriState(
dateAtDawn: null == dateAtDawn ? _self.dateAtDawn : dateAtDawn // ignore: cast_nullable_to_non_nullable
as HijriDate,dateAtNight: null == dateAtNight ? _self.dateAtNight : dateAtNight // ignore: cast_nullable_to_non_nullable
as HijriDate,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as HijriConfidence,packageVersion: freezed == packageVersion ? _self.packageVersion : packageVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of HijriState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HijriDateCopyWith<$Res> get dateAtDawn {
  
  return $HijriDateCopyWith<$Res>(_self.dateAtDawn, (value) {
    return _then(_self.copyWith(dateAtDawn: value));
  });
}/// Create a copy of HijriState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HijriDateCopyWith<$Res> get dateAtNight {
  
  return $HijriDateCopyWith<$Res>(_self.dateAtNight, (value) {
    return _then(_self.copyWith(dateAtNight: value));
  });
}
}


/// Adds pattern-matching-related methods to [HijriState].
extension HijriStatePatterns on HijriState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HijriState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HijriState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HijriState value)  $default,){
final _that = this;
switch (_that) {
case _HijriState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HijriState value)?  $default,){
final _that = this;
switch (_that) {
case _HijriState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HijriDate dateAtDawn,  HijriDate dateAtNight,  HijriConfidence confidence,  String? packageVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HijriState() when $default != null:
return $default(_that.dateAtDawn,_that.dateAtNight,_that.confidence,_that.packageVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HijriDate dateAtDawn,  HijriDate dateAtNight,  HijriConfidence confidence,  String? packageVersion)  $default,) {final _that = this;
switch (_that) {
case _HijriState():
return $default(_that.dateAtDawn,_that.dateAtNight,_that.confidence,_that.packageVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HijriDate dateAtDawn,  HijriDate dateAtNight,  HijriConfidence confidence,  String? packageVersion)?  $default,) {final _that = this;
switch (_that) {
case _HijriState() when $default != null:
return $default(_that.dateAtDawn,_that.dateAtNight,_that.confidence,_that.packageVersion);case _:
  return null;

}
}

}

/// @nodoc


class _HijriState extends HijriState {
  const _HijriState({required this.dateAtDawn, required this.dateAtNight, required this.confidence, this.packageVersion}): super._();
  

/// Hijri date of `D`.
@override final  HijriDate dateAtDawn;
/// Hijri date of `D + 1`.
@override final  HijriDate dateAtNight;
/// How the dates were obtained.
@override final  HijriConfidence confidence;
/// Version of the `hijri` package the dates came from, when any.
@override final  String? packageVersion;

/// Create a copy of HijriState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HijriStateCopyWith<_HijriState> get copyWith => __$HijriStateCopyWithImpl<_HijriState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HijriState&&(identical(other.dateAtDawn, dateAtDawn) || other.dateAtDawn == dateAtDawn)&&(identical(other.dateAtNight, dateAtNight) || other.dateAtNight == dateAtNight)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.packageVersion, packageVersion) || other.packageVersion == packageVersion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,dateAtDawn,dateAtNight,confidence,packageVersion);
}

@override
String toString() {
    return 'HijriState(dateAtDawn: $dateAtDawn, dateAtNight: $dateAtNight, confidence: $confidence, packageVersion: $packageVersion)';
}


}

/// @nodoc
abstract mixin class _$HijriStateCopyWith<$Res> implements $HijriStateCopyWith<$Res> {
  factory _$HijriStateCopyWith(_HijriState value, $Res Function(_HijriState) _then) = __$HijriStateCopyWithImpl;
@override @useResult
$Res call({
 HijriDate dateAtDawn, HijriDate dateAtNight, HijriConfidence confidence, String? packageVersion
});


@override $HijriDateCopyWith<$Res> get dateAtDawn;@override $HijriDateCopyWith<$Res> get dateAtNight;

}
/// @nodoc
class __$HijriStateCopyWithImpl<$Res>
    implements _$HijriStateCopyWith<$Res> {
  __$HijriStateCopyWithImpl(this._self, this._then);

  final _HijriState _self;
  final $Res Function(_HijriState) _then;

/// Create a copy of HijriState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateAtDawn = null,Object? dateAtNight = null,Object? confidence = null,Object? packageVersion = freezed,}) {
  return _then(_HijriState(
dateAtDawn: null == dateAtDawn ? _self.dateAtDawn : dateAtDawn // ignore: cast_nullable_to_non_nullable
as HijriDate,dateAtNight: null == dateAtNight ? _self.dateAtNight : dateAtNight // ignore: cast_nullable_to_non_nullable
as HijriDate,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as HijriConfidence,packageVersion: freezed == packageVersion ? _self.packageVersion : packageVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of HijriState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HijriDateCopyWith<$Res> get dateAtDawn {
  
  return $HijriDateCopyWith<$Res>(_self.dateAtDawn, (value) {
    return _then(_self.copyWith(dateAtDawn: value));
  });
}/// Create a copy of HijriState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HijriDateCopyWith<$Res> get dateAtNight {
  
  return $HijriDateCopyWith<$Res>(_self.dateAtNight, (value) {
    return _then(_self.copyWith(dateAtNight: value));
  });
}
}

// dart format on
