// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tuf_key.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TufKey {

/// Scheme.
 TufKeyScheme get scheme;/// Lowercase hex raw public key.
 String get public;
/// Create a copy of TufKey
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufKeyCopyWith<TufKey> get copyWith => _$TufKeyCopyWithImpl<TufKey>(this as TufKey, _$identity);

  /// Serializes this TufKey to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TufKey;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TufKey&&(identical(other.scheme, _this.scheme) || other.scheme == _this.scheme)&&(identical(other.public, _this.public) || other.public == _this.public));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TufKey;
  return Object.hash(runtimeType,_this.scheme,_this.public);
}

@override
String toString() {
  final _this = this as TufKey;
  return 'TufKey(scheme: ${_this.scheme}, public: ${_this.public})';
}


}

/// @nodoc
abstract mixin class $TufKeyCopyWith<$Res>  {
  factory $TufKeyCopyWith(TufKey value, $Res Function(TufKey) _then) = _$TufKeyCopyWithImpl;
@useResult
$Res call({
 TufKeyScheme scheme, String public
});




}
/// @nodoc
class _$TufKeyCopyWithImpl<$Res>
    implements $TufKeyCopyWith<$Res> {
  _$TufKeyCopyWithImpl(this._self, this._then);

  final TufKey _self;
  final $Res Function(TufKey) _then;

/// Create a copy of TufKey
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scheme = null,Object? public = null,}) {
  return _then(TufKey(
scheme: null == scheme ? _self.scheme : scheme // ignore: cast_nullable_to_non_nullable
as TufKeyScheme,public: null == public ? _self.public : public // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TufKey].
extension TufKeyPatterns on TufKey {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TufKey value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TufKey() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TufKey value)  $default,){
final _that = this;
switch (_that) {
case _TufKey():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TufKey value)?  $default,){
final _that = this;
switch (_that) {
case _TufKey() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TufKeyScheme scheme,  String public)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TufKey() when $default != null:
return $default(_that.scheme,_that.public);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TufKeyScheme scheme,  String public)  $default,) {final _that = this;
switch (_that) {
case _TufKey():
return $default(_that.scheme,_that.public);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TufKeyScheme scheme,  String public)?  $default,) {final _that = this;
switch (_that) {
case _TufKey() when $default != null:
return $default(_that.scheme,_that.public);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TufKey implements TufKey {
  const _TufKey({required this.scheme, required this.public});
  factory _TufKey.fromJson(Map<String, dynamic> json) => _$TufKeyFromJson(json);

/// Scheme.
@override final  TufKeyScheme scheme;
/// Lowercase hex raw public key.
@override final  String public;

/// Create a copy of TufKey
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TufKeyCopyWith<_TufKey> get copyWith => __$TufKeyCopyWithImpl<_TufKey>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufKeyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TufKey&&(identical(other.scheme, scheme) || other.scheme == scheme)&&(identical(other.public, public) || other.public == public));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,scheme,public);
}

@override
String toString() {
    return 'TufKey(scheme: $scheme, public: $public)';
}


}

/// @nodoc
abstract mixin class _$TufKeyCopyWith<$Res> implements $TufKeyCopyWith<$Res> {
  factory _$TufKeyCopyWith(_TufKey value, $Res Function(_TufKey) _then) = __$TufKeyCopyWithImpl;
@override @useResult
$Res call({
 TufKeyScheme scheme, String public
});




}
/// @nodoc
class __$TufKeyCopyWithImpl<$Res>
    implements _$TufKeyCopyWith<$Res> {
  __$TufKeyCopyWithImpl(this._self, this._then);

  final _TufKey _self;
  final $Res Function(_TufKey) _then;

/// Create a copy of TufKey
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scheme = null,Object? public = null,}) {
  return _then(_TufKey(
scheme: null == scheme ? _self.scheme : scheme // ignore: cast_nullable_to_non_nullable
as TufKeyScheme,public: null == public ? _self.public : public // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
