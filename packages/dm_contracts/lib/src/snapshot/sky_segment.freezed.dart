// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sky_segment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SkySegment {

/// Phase start.
 int get fromUtcMs;/// Phase.
 SkyPhaseCode get phase;
/// Create a copy of SkySegment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SkySegmentCopyWith<SkySegment> get copyWith => _$SkySegmentCopyWithImpl<SkySegment>(this as SkySegment, _$identity);

  /// Serializes this SkySegment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SkySegment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkySegment&&(identical(other.fromUtcMs, _this.fromUtcMs) || other.fromUtcMs == _this.fromUtcMs)&&(identical(other.phase, _this.phase) || other.phase == _this.phase));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SkySegment;
  return Object.hash(runtimeType,_this.fromUtcMs,_this.phase);
}

@override
String toString() {
  final _this = this as SkySegment;
  return 'SkySegment(fromUtcMs: ${_this.fromUtcMs}, phase: ${_this.phase})';
}


}

/// @nodoc
abstract mixin class $SkySegmentCopyWith<$Res>  {
  factory $SkySegmentCopyWith(SkySegment value, $Res Function(SkySegment) _then) = _$SkySegmentCopyWithImpl;
@useResult
$Res call({
 int fromUtcMs, SkyPhaseCode phase
});




}
/// @nodoc
class _$SkySegmentCopyWithImpl<$Res>
    implements $SkySegmentCopyWith<$Res> {
  _$SkySegmentCopyWithImpl(this._self, this._then);

  final SkySegment _self;
  final $Res Function(SkySegment) _then;

/// Create a copy of SkySegment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromUtcMs = null,Object? phase = null,}) {
  return _then(SkySegment(
fromUtcMs: null == fromUtcMs ? _self.fromUtcMs : fromUtcMs // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SkyPhaseCode,
  ));
}

}


/// Adds pattern-matching-related methods to [SkySegment].
extension SkySegmentPatterns on SkySegment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SkySegment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SkySegment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SkySegment value)  $default,){
final _that = this;
switch (_that) {
case _SkySegment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SkySegment value)?  $default,){
final _that = this;
switch (_that) {
case _SkySegment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int fromUtcMs,  SkyPhaseCode phase)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SkySegment() when $default != null:
return $default(_that.fromUtcMs,_that.phase);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int fromUtcMs,  SkyPhaseCode phase)  $default,) {final _that = this;
switch (_that) {
case _SkySegment():
return $default(_that.fromUtcMs,_that.phase);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int fromUtcMs,  SkyPhaseCode phase)?  $default,) {final _that = this;
switch (_that) {
case _SkySegment() when $default != null:
return $default(_that.fromUtcMs,_that.phase);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SkySegment implements SkySegment {
  const _SkySegment({required this.fromUtcMs, required this.phase});
  factory _SkySegment.fromJson(Map<String, dynamic> json) => _$SkySegmentFromJson(json);

/// Phase start.
@override final  int fromUtcMs;
/// Phase.
@override final  SkyPhaseCode phase;

/// Create a copy of SkySegment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SkySegmentCopyWith<_SkySegment> get copyWith => __$SkySegmentCopyWithImpl<_SkySegment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SkySegmentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SkySegment&&(identical(other.fromUtcMs, fromUtcMs) || other.fromUtcMs == fromUtcMs)&&(identical(other.phase, phase) || other.phase == phase));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,fromUtcMs,phase);
}

@override
String toString() {
    return 'SkySegment(fromUtcMs: $fromUtcMs, phase: $phase)';
}


}

/// @nodoc
abstract mixin class _$SkySegmentCopyWith<$Res> implements $SkySegmentCopyWith<$Res> {
  factory _$SkySegmentCopyWith(_SkySegment value, $Res Function(_SkySegment) _then) = __$SkySegmentCopyWithImpl;
@override @useResult
$Res call({
 int fromUtcMs, SkyPhaseCode phase
});




}
/// @nodoc
class __$SkySegmentCopyWithImpl<$Res>
    implements _$SkySegmentCopyWith<$Res> {
  __$SkySegmentCopyWithImpl(this._self, this._then);

  final _SkySegment _self;
  final $Res Function(_SkySegment) _then;

/// Create a copy of SkySegment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromUtcMs = null,Object? phase = null,}) {
  return _then(_SkySegment(
fromUtcMs: null == fromUtcMs ? _self.fromUtcMs : fromUtcMs // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SkyPhaseCode,
  ));
}


}

// dart format on
