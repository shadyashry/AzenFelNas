// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'solar_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SolarState {

/// Geometric topocentric altitude, degrees, no refraction (§6.4 ¶3).
 double get altitudeDeg;/// Topocentric azimuth, degrees east of north, `[0, 360)`.
 double get azimuthDeg;/// Whether the Sun is east of the meridian (before upper culmination).
 bool get rising;/// The Appendix G phase of [altitudeDeg] and [rising].
 SkyPhase get phase;/// Progress through [phase]'s band, `[0, 1]` (`SkyPhase.progressAt`).
 double get phaseProgress;
/// Create a copy of SolarState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SolarStateCopyWith<SolarState> get copyWith => _$SolarStateCopyWithImpl<SolarState>(this as SolarState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SolarState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SolarState&&(identical(other.altitudeDeg, _this.altitudeDeg) || other.altitudeDeg == _this.altitudeDeg)&&(identical(other.azimuthDeg, _this.azimuthDeg) || other.azimuthDeg == _this.azimuthDeg)&&(identical(other.rising, _this.rising) || other.rising == _this.rising)&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.phaseProgress, _this.phaseProgress) || other.phaseProgress == _this.phaseProgress));
}


@override
int get hashCode {
  final _this = this as SolarState;
  return Object.hash(runtimeType,_this.altitudeDeg,_this.azimuthDeg,_this.rising,_this.phase,_this.phaseProgress);
}

@override
String toString() {
  final _this = this as SolarState;
  return 'SolarState(altitudeDeg: ${_this.altitudeDeg}, azimuthDeg: ${_this.azimuthDeg}, rising: ${_this.rising}, phase: ${_this.phase}, phaseProgress: ${_this.phaseProgress})';
}


}

/// @nodoc
abstract mixin class $SolarStateCopyWith<$Res>  {
  factory $SolarStateCopyWith(SolarState value, $Res Function(SolarState) _then) = _$SolarStateCopyWithImpl;
@useResult
$Res call({
 double altitudeDeg, double azimuthDeg, bool rising, SkyPhase phase, double phaseProgress
});




}
/// @nodoc
class _$SolarStateCopyWithImpl<$Res>
    implements $SolarStateCopyWith<$Res> {
  _$SolarStateCopyWithImpl(this._self, this._then);

  final SolarState _self;
  final $Res Function(SolarState) _then;

/// Create a copy of SolarState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? altitudeDeg = null,Object? azimuthDeg = null,Object? rising = null,Object? phase = null,Object? phaseProgress = null,}) {
  return _then(SolarState(
altitudeDeg: null == altitudeDeg ? _self.altitudeDeg : altitudeDeg // ignore: cast_nullable_to_non_nullable
as double,azimuthDeg: null == azimuthDeg ? _self.azimuthDeg : azimuthDeg // ignore: cast_nullable_to_non_nullable
as double,rising: null == rising ? _self.rising : rising // ignore: cast_nullable_to_non_nullable
as bool,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SkyPhase,phaseProgress: null == phaseProgress ? _self.phaseProgress : phaseProgress // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SolarState].
extension SolarStatePatterns on SolarState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SolarState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SolarState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SolarState value)  $default,){
final _that = this;
switch (_that) {
case _SolarState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SolarState value)?  $default,){
final _that = this;
switch (_that) {
case _SolarState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double altitudeDeg,  double azimuthDeg,  bool rising,  SkyPhase phase,  double phaseProgress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SolarState() when $default != null:
return $default(_that.altitudeDeg,_that.azimuthDeg,_that.rising,_that.phase,_that.phaseProgress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double altitudeDeg,  double azimuthDeg,  bool rising,  SkyPhase phase,  double phaseProgress)  $default,) {final _that = this;
switch (_that) {
case _SolarState():
return $default(_that.altitudeDeg,_that.azimuthDeg,_that.rising,_that.phase,_that.phaseProgress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double altitudeDeg,  double azimuthDeg,  bool rising,  SkyPhase phase,  double phaseProgress)?  $default,) {final _that = this;
switch (_that) {
case _SolarState() when $default != null:
return $default(_that.altitudeDeg,_that.azimuthDeg,_that.rising,_that.phase,_that.phaseProgress);case _:
  return null;

}
}

}

/// @nodoc


class _SolarState implements SolarState {
  const _SolarState({required this.altitudeDeg, required this.azimuthDeg, required this.rising, required this.phase, required this.phaseProgress});
  

/// Geometric topocentric altitude, degrees, no refraction (§6.4 ¶3).
@override final  double altitudeDeg;
/// Topocentric azimuth, degrees east of north, `[0, 360)`.
@override final  double azimuthDeg;
/// Whether the Sun is east of the meridian (before upper culmination).
@override final  bool rising;
/// The Appendix G phase of [altitudeDeg] and [rising].
@override final  SkyPhase phase;
/// Progress through [phase]'s band, `[0, 1]` (`SkyPhase.progressAt`).
@override final  double phaseProgress;

/// Create a copy of SolarState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SolarStateCopyWith<_SolarState> get copyWith => __$SolarStateCopyWithImpl<_SolarState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SolarState&&(identical(other.altitudeDeg, altitudeDeg) || other.altitudeDeg == altitudeDeg)&&(identical(other.azimuthDeg, azimuthDeg) || other.azimuthDeg == azimuthDeg)&&(identical(other.rising, rising) || other.rising == rising)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.phaseProgress, phaseProgress) || other.phaseProgress == phaseProgress));
}


@override
int get hashCode {
    return Object.hash(runtimeType,altitudeDeg,azimuthDeg,rising,phase,phaseProgress);
}

@override
String toString() {
    return 'SolarState(altitudeDeg: $altitudeDeg, azimuthDeg: $azimuthDeg, rising: $rising, phase: $phase, phaseProgress: $phaseProgress)';
}


}

/// @nodoc
abstract mixin class _$SolarStateCopyWith<$Res> implements $SolarStateCopyWith<$Res> {
  factory _$SolarStateCopyWith(_SolarState value, $Res Function(_SolarState) _then) = __$SolarStateCopyWithImpl;
@override @useResult
$Res call({
 double altitudeDeg, double azimuthDeg, bool rising, SkyPhase phase, double phaseProgress
});




}
/// @nodoc
class __$SolarStateCopyWithImpl<$Res>
    implements _$SolarStateCopyWith<$Res> {
  __$SolarStateCopyWithImpl(this._self, this._then);

  final _SolarState _self;
  final $Res Function(_SolarState) _then;

/// Create a copy of SolarState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? altitudeDeg = null,Object? azimuthDeg = null,Object? rising = null,Object? phase = null,Object? phaseProgress = null,}) {
  return _then(_SolarState(
altitudeDeg: null == altitudeDeg ? _self.altitudeDeg : altitudeDeg // ignore: cast_nullable_to_non_nullable
as double,azimuthDeg: null == azimuthDeg ? _self.azimuthDeg : azimuthDeg // ignore: cast_nullable_to_non_nullable
as double,rising: null == rising ? _self.rising : rising // ignore: cast_nullable_to_non_nullable
as bool,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SkyPhase,phaseProgress: null == phaseProgress ? _self.phaseProgress : phaseProgress // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
