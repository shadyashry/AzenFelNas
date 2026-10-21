// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'snapshot_health.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnapshotHealth {

/// State.
 HealthStateCode get state;/// Number of reasons.
 int get reasonsCount;
/// Create a copy of SnapshotHealth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnapshotHealthCopyWith<SnapshotHealth> get copyWith => _$SnapshotHealthCopyWithImpl<SnapshotHealth>(this as SnapshotHealth, _$identity);

  /// Serializes this SnapshotHealth to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnapshotHealth;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnapshotHealth&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.reasonsCount, _this.reasonsCount) || other.reasonsCount == _this.reasonsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnapshotHealth;
  return Object.hash(runtimeType,_this.state,_this.reasonsCount);
}

@override
String toString() {
  final _this = this as SnapshotHealth;
  return 'SnapshotHealth(state: ${_this.state}, reasonsCount: ${_this.reasonsCount})';
}


}

/// @nodoc
abstract mixin class $SnapshotHealthCopyWith<$Res>  {
  factory $SnapshotHealthCopyWith(SnapshotHealth value, $Res Function(SnapshotHealth) _then) = _$SnapshotHealthCopyWithImpl;
@useResult
$Res call({
 HealthStateCode state, int reasonsCount
});




}
/// @nodoc
class _$SnapshotHealthCopyWithImpl<$Res>
    implements $SnapshotHealthCopyWith<$Res> {
  _$SnapshotHealthCopyWithImpl(this._self, this._then);

  final SnapshotHealth _self;
  final $Res Function(SnapshotHealth) _then;

/// Create a copy of SnapshotHealth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? state = null,Object? reasonsCount = null,}) {
  return _then(SnapshotHealth(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as HealthStateCode,reasonsCount: null == reasonsCount ? _self.reasonsCount : reasonsCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SnapshotHealth].
extension SnapshotHealthPatterns on SnapshotHealth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnapshotHealth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnapshotHealth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnapshotHealth value)  $default,){
final _that = this;
switch (_that) {
case _SnapshotHealth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnapshotHealth value)?  $default,){
final _that = this;
switch (_that) {
case _SnapshotHealth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HealthStateCode state,  int reasonsCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnapshotHealth() when $default != null:
return $default(_that.state,_that.reasonsCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HealthStateCode state,  int reasonsCount)  $default,) {final _that = this;
switch (_that) {
case _SnapshotHealth():
return $default(_that.state,_that.reasonsCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HealthStateCode state,  int reasonsCount)?  $default,) {final _that = this;
switch (_that) {
case _SnapshotHealth() when $default != null:
return $default(_that.state,_that.reasonsCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnapshotHealth implements SnapshotHealth {
  const _SnapshotHealth({required this.state, required this.reasonsCount});
  factory _SnapshotHealth.fromJson(Map<String, dynamic> json) => _$SnapshotHealthFromJson(json);

/// State.
@override final  HealthStateCode state;
/// Number of reasons.
@override final  int reasonsCount;

/// Create a copy of SnapshotHealth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnapshotHealthCopyWith<_SnapshotHealth> get copyWith => __$SnapshotHealthCopyWithImpl<_SnapshotHealth>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnapshotHealthToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnapshotHealth&&(identical(other.state, state) || other.state == state)&&(identical(other.reasonsCount, reasonsCount) || other.reasonsCount == reasonsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,state,reasonsCount);
}

@override
String toString() {
    return 'SnapshotHealth(state: $state, reasonsCount: $reasonsCount)';
}


}

/// @nodoc
abstract mixin class _$SnapshotHealthCopyWith<$Res> implements $SnapshotHealthCopyWith<$Res> {
  factory _$SnapshotHealthCopyWith(_SnapshotHealth value, $Res Function(_SnapshotHealth) _then) = __$SnapshotHealthCopyWithImpl;
@override @useResult
$Res call({
 HealthStateCode state, int reasonsCount
});




}
/// @nodoc
class __$SnapshotHealthCopyWithImpl<$Res>
    implements _$SnapshotHealthCopyWith<$Res> {
  __$SnapshotHealthCopyWithImpl(this._self, this._then);

  final _SnapshotHealth _self;
  final $Res Function(_SnapshotHealth) _then;

/// Create a copy of SnapshotHealth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? state = null,Object? reasonsCount = null,}) {
  return _then(_SnapshotHealth(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as HealthStateCode,reasonsCount: null == reasonsCount ? _self.reasonsCount : reasonsCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
