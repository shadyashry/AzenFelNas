// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_result_counts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TestResultCounts {

/// Heard.
 int get heard;/// Not heard.
 int get notHeard;/// Unknown.
 int get unknown;
/// Create a copy of TestResultCounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TestResultCountsCopyWith<TestResultCounts> get copyWith => _$TestResultCountsCopyWithImpl<TestResultCounts>(this as TestResultCounts, _$identity);

  /// Serializes this TestResultCounts to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TestResultCounts;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TestResultCounts&&(identical(other.heard, _this.heard) || other.heard == _this.heard)&&(identical(other.notHeard, _this.notHeard) || other.notHeard == _this.notHeard)&&(identical(other.unknown, _this.unknown) || other.unknown == _this.unknown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TestResultCounts;
  return Object.hash(runtimeType,_this.heard,_this.notHeard,_this.unknown);
}

@override
String toString() {
  final _this = this as TestResultCounts;
  return 'TestResultCounts(heard: ${_this.heard}, notHeard: ${_this.notHeard}, unknown: ${_this.unknown})';
}


}

/// @nodoc
abstract mixin class $TestResultCountsCopyWith<$Res>  {
  factory $TestResultCountsCopyWith(TestResultCounts value, $Res Function(TestResultCounts) _then) = _$TestResultCountsCopyWithImpl;
@useResult
$Res call({
 int heard, int notHeard, int unknown
});




}
/// @nodoc
class _$TestResultCountsCopyWithImpl<$Res>
    implements $TestResultCountsCopyWith<$Res> {
  _$TestResultCountsCopyWithImpl(this._self, this._then);

  final TestResultCounts _self;
  final $Res Function(TestResultCounts) _then;

/// Create a copy of TestResultCounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? heard = null,Object? notHeard = null,Object? unknown = null,}) {
  return _then(TestResultCounts(
heard: null == heard ? _self.heard : heard // ignore: cast_nullable_to_non_nullable
as int,notHeard: null == notHeard ? _self.notHeard : notHeard // ignore: cast_nullable_to_non_nullable
as int,unknown: null == unknown ? _self.unknown : unknown // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TestResultCounts].
extension TestResultCountsPatterns on TestResultCounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TestResultCounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TestResultCounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TestResultCounts value)  $default,){
final _that = this;
switch (_that) {
case _TestResultCounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TestResultCounts value)?  $default,){
final _that = this;
switch (_that) {
case _TestResultCounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int heard,  int notHeard,  int unknown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TestResultCounts() when $default != null:
return $default(_that.heard,_that.notHeard,_that.unknown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int heard,  int notHeard,  int unknown)  $default,) {final _that = this;
switch (_that) {
case _TestResultCounts():
return $default(_that.heard,_that.notHeard,_that.unknown);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int heard,  int notHeard,  int unknown)?  $default,) {final _that = this;
switch (_that) {
case _TestResultCounts() when $default != null:
return $default(_that.heard,_that.notHeard,_that.unknown);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TestResultCounts implements TestResultCounts {
  const _TestResultCounts({required this.heard, required this.notHeard, required this.unknown});
  factory _TestResultCounts.fromJson(Map<String, dynamic> json) => _$TestResultCountsFromJson(json);

/// Heard.
@override final  int heard;
/// Not heard.
@override final  int notHeard;
/// Unknown.
@override final  int unknown;

/// Create a copy of TestResultCounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TestResultCountsCopyWith<_TestResultCounts> get copyWith => __$TestResultCountsCopyWithImpl<_TestResultCounts>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TestResultCountsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TestResultCounts&&(identical(other.heard, heard) || other.heard == heard)&&(identical(other.notHeard, notHeard) || other.notHeard == notHeard)&&(identical(other.unknown, unknown) || other.unknown == unknown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,heard,notHeard,unknown);
}

@override
String toString() {
    return 'TestResultCounts(heard: $heard, notHeard: $notHeard, unknown: $unknown)';
}


}

/// @nodoc
abstract mixin class _$TestResultCountsCopyWith<$Res> implements $TestResultCountsCopyWith<$Res> {
  factory _$TestResultCountsCopyWith(_TestResultCounts value, $Res Function(_TestResultCounts) _then) = __$TestResultCountsCopyWithImpl;
@override @useResult
$Res call({
 int heard, int notHeard, int unknown
});




}
/// @nodoc
class __$TestResultCountsCopyWithImpl<$Res>
    implements _$TestResultCountsCopyWith<$Res> {
  __$TestResultCountsCopyWithImpl(this._self, this._then);

  final _TestResultCounts _self;
  final $Res Function(_TestResultCounts) _then;

/// Create a copy of TestResultCounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? heard = null,Object? notHeard = null,Object? unknown = null,}) {
  return _then(_TestResultCounts(
heard: null == heard ? _self.heard : heard // ignore: cast_nullable_to_non_nullable
as int,notHeard: null == notHeard ? _self.notHeard : notHeard // ignore: cast_nullable_to_non_nullable
as int,unknown: null == unknown ? _self.unknown : unknown // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
