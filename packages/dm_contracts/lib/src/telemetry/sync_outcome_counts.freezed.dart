// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_outcome_counts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncOutcomeCounts {

/// Succeeded.
 int get ok;/// Succeeded with a warning.
 int get warn;/// Failed.
 int get fail;
/// Create a copy of SyncOutcomeCounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncOutcomeCountsCopyWith<SyncOutcomeCounts> get copyWith => _$SyncOutcomeCountsCopyWithImpl<SyncOutcomeCounts>(this as SyncOutcomeCounts, _$identity);

  /// Serializes this SyncOutcomeCounts to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SyncOutcomeCounts;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncOutcomeCounts&&(identical(other.ok, _this.ok) || other.ok == _this.ok)&&(identical(other.warn, _this.warn) || other.warn == _this.warn)&&(identical(other.fail, _this.fail) || other.fail == _this.fail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SyncOutcomeCounts;
  return Object.hash(runtimeType,_this.ok,_this.warn,_this.fail);
}

@override
String toString() {
  final _this = this as SyncOutcomeCounts;
  return 'SyncOutcomeCounts(ok: ${_this.ok}, warn: ${_this.warn}, fail: ${_this.fail})';
}


}

/// @nodoc
abstract mixin class $SyncOutcomeCountsCopyWith<$Res>  {
  factory $SyncOutcomeCountsCopyWith(SyncOutcomeCounts value, $Res Function(SyncOutcomeCounts) _then) = _$SyncOutcomeCountsCopyWithImpl;
@useResult
$Res call({
 int ok, int warn, int fail
});




}
/// @nodoc
class _$SyncOutcomeCountsCopyWithImpl<$Res>
    implements $SyncOutcomeCountsCopyWith<$Res> {
  _$SyncOutcomeCountsCopyWithImpl(this._self, this._then);

  final SyncOutcomeCounts _self;
  final $Res Function(SyncOutcomeCounts) _then;

/// Create a copy of SyncOutcomeCounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ok = null,Object? warn = null,Object? fail = null,}) {
  return _then(SyncOutcomeCounts(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as int,warn: null == warn ? _self.warn : warn // ignore: cast_nullable_to_non_nullable
as int,fail: null == fail ? _self.fail : fail // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncOutcomeCounts].
extension SyncOutcomeCountsPatterns on SyncOutcomeCounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncOutcomeCounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncOutcomeCounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncOutcomeCounts value)  $default,){
final _that = this;
switch (_that) {
case _SyncOutcomeCounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncOutcomeCounts value)?  $default,){
final _that = this;
switch (_that) {
case _SyncOutcomeCounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int ok,  int warn,  int fail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncOutcomeCounts() when $default != null:
return $default(_that.ok,_that.warn,_that.fail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int ok,  int warn,  int fail)  $default,) {final _that = this;
switch (_that) {
case _SyncOutcomeCounts():
return $default(_that.ok,_that.warn,_that.fail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int ok,  int warn,  int fail)?  $default,) {final _that = this;
switch (_that) {
case _SyncOutcomeCounts() when $default != null:
return $default(_that.ok,_that.warn,_that.fail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncOutcomeCounts implements SyncOutcomeCounts {
  const _SyncOutcomeCounts({required this.ok, required this.warn, required this.fail});
  factory _SyncOutcomeCounts.fromJson(Map<String, dynamic> json) => _$SyncOutcomeCountsFromJson(json);

/// Succeeded.
@override final  int ok;
/// Succeeded with a warning.
@override final  int warn;
/// Failed.
@override final  int fail;

/// Create a copy of SyncOutcomeCounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncOutcomeCountsCopyWith<_SyncOutcomeCounts> get copyWith => __$SyncOutcomeCountsCopyWithImpl<_SyncOutcomeCounts>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncOutcomeCountsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncOutcomeCounts&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.warn, warn) || other.warn == warn)&&(identical(other.fail, fail) || other.fail == fail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ok,warn,fail);
}

@override
String toString() {
    return 'SyncOutcomeCounts(ok: $ok, warn: $warn, fail: $fail)';
}


}

/// @nodoc
abstract mixin class _$SyncOutcomeCountsCopyWith<$Res> implements $SyncOutcomeCountsCopyWith<$Res> {
  factory _$SyncOutcomeCountsCopyWith(_SyncOutcomeCounts value, $Res Function(_SyncOutcomeCounts) _then) = __$SyncOutcomeCountsCopyWithImpl;
@override @useResult
$Res call({
 int ok, int warn, int fail
});




}
/// @nodoc
class __$SyncOutcomeCountsCopyWithImpl<$Res>
    implements _$SyncOutcomeCountsCopyWith<$Res> {
  __$SyncOutcomeCountsCopyWithImpl(this._self, this._then);

  final _SyncOutcomeCounts _self;
  final $Res Function(_SyncOutcomeCounts) _then;

/// Create a copy of SyncOutcomeCounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ok = null,Object? warn = null,Object? fail = null,}) {
  return _then(_SyncOutcomeCounts(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as int,warn: null == warn ? _self.warn : warn // ignore: cast_nullable_to_non_nullable
as int,fail: null == fail ? _self.fail : fail // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
