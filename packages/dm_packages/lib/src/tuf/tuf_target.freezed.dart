// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tuf_target.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TufTarget {

/// Size in bytes.
 int get length;/// Lowercase hex SHA-256.
 String get sha256;/// Package metadata.
 TufTargetCustom get custom;
/// Create a copy of TufTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufTargetCopyWith<TufTarget> get copyWith => _$TufTargetCopyWithImpl<TufTarget>(this as TufTarget, _$identity);

  /// Serializes this TufTarget to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TufTarget;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TufTarget&&(identical(other.length, _this.length) || other.length == _this.length)&&(identical(other.sha256, _this.sha256) || other.sha256 == _this.sha256)&&(identical(other.custom, _this.custom) || other.custom == _this.custom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TufTarget;
  return Object.hash(runtimeType,_this.length,_this.sha256,_this.custom);
}

@override
String toString() {
  final _this = this as TufTarget;
  return 'TufTarget(length: ${_this.length}, sha256: ${_this.sha256}, custom: ${_this.custom})';
}


}

/// @nodoc
abstract mixin class $TufTargetCopyWith<$Res>  {
  factory $TufTargetCopyWith(TufTarget value, $Res Function(TufTarget) _then) = _$TufTargetCopyWithImpl;
@useResult
$Res call({
 int length, String sha256, TufTargetCustom custom
});


$TufTargetCustomCopyWith<$Res> get custom;

}
/// @nodoc
class _$TufTargetCopyWithImpl<$Res>
    implements $TufTargetCopyWith<$Res> {
  _$TufTargetCopyWithImpl(this._self, this._then);

  final TufTarget _self;
  final $Res Function(TufTarget) _then;

/// Create a copy of TufTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? length = null,Object? sha256 = null,Object? custom = null,}) {
  return _then(TufTarget(
length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as int,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,custom: null == custom ? _self.custom : custom // ignore: cast_nullable_to_non_nullable
as TufTargetCustom,
  ));
}
/// Create a copy of TufTarget
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufTargetCustomCopyWith<$Res> get custom {
  
  return $TufTargetCustomCopyWith<$Res>(_self.custom, (value) {
    return _then(_self.copyWith(custom: value));
  });
}
}


/// Adds pattern-matching-related methods to [TufTarget].
extension TufTargetPatterns on TufTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TufTarget value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TufTarget() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TufTarget value)  $default,){
final _that = this;
switch (_that) {
case _TufTarget():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TufTarget value)?  $default,){
final _that = this;
switch (_that) {
case _TufTarget() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int length,  String sha256,  TufTargetCustom custom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TufTarget() when $default != null:
return $default(_that.length,_that.sha256,_that.custom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int length,  String sha256,  TufTargetCustom custom)  $default,) {final _that = this;
switch (_that) {
case _TufTarget():
return $default(_that.length,_that.sha256,_that.custom);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int length,  String sha256,  TufTargetCustom custom)?  $default,) {final _that = this;
switch (_that) {
case _TufTarget() when $default != null:
return $default(_that.length,_that.sha256,_that.custom);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TufTarget implements TufTarget {
  const _TufTarget({required this.length, required this.sha256, required this.custom});
  factory _TufTarget.fromJson(Map<String, dynamic> json) => _$TufTargetFromJson(json);

/// Size in bytes.
@override final  int length;
/// Lowercase hex SHA-256.
@override final  String sha256;
/// Package metadata.
@override final  TufTargetCustom custom;

/// Create a copy of TufTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TufTargetCopyWith<_TufTarget> get copyWith => __$TufTargetCopyWithImpl<_TufTarget>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufTargetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TufTarget&&(identical(other.length, length) || other.length == length)&&(identical(other.sha256, sha256) || other.sha256 == sha256)&&(identical(other.custom, custom) || other.custom == custom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,length,sha256,custom);
}

@override
String toString() {
    return 'TufTarget(length: $length, sha256: $sha256, custom: $custom)';
}


}

/// @nodoc
abstract mixin class _$TufTargetCopyWith<$Res> implements $TufTargetCopyWith<$Res> {
  factory _$TufTargetCopyWith(_TufTarget value, $Res Function(_TufTarget) _then) = __$TufTargetCopyWithImpl;
@override @useResult
$Res call({
 int length, String sha256, TufTargetCustom custom
});


@override $TufTargetCustomCopyWith<$Res> get custom;

}
/// @nodoc
class __$TufTargetCopyWithImpl<$Res>
    implements _$TufTargetCopyWith<$Res> {
  __$TufTargetCopyWithImpl(this._self, this._then);

  final _TufTarget _self;
  final $Res Function(_TufTarget) _then;

/// Create a copy of TufTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? length = null,Object? sha256 = null,Object? custom = null,}) {
  return _then(_TufTarget(
length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as int,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,custom: null == custom ? _self.custom : custom // ignore: cast_nullable_to_non_nullable
as TufTargetCustom,
  ));
}

/// Create a copy of TufTarget
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufTargetCustomCopyWith<$Res> get custom {
  
  return $TufTargetCustomCopyWith<$Res>(_self.custom, (value) {
    return _then(_self.copyWith(custom: value));
  });
}
}

// dart format on
