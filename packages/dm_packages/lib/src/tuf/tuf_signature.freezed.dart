// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tuf_signature.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TufSignature {

/// Lowercase hex SHA-256 of the signing public key.
 String get keyId;/// Base64 Ed25519 signature.
 String get sig;
/// Create a copy of TufSignature
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufSignatureCopyWith<TufSignature> get copyWith => _$TufSignatureCopyWithImpl<TufSignature>(this as TufSignature, _$identity);

  /// Serializes this TufSignature to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TufSignature;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TufSignature&&(identical(other.keyId, _this.keyId) || other.keyId == _this.keyId)&&(identical(other.sig, _this.sig) || other.sig == _this.sig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TufSignature;
  return Object.hash(runtimeType,_this.keyId,_this.sig);
}

@override
String toString() {
  final _this = this as TufSignature;
  return 'TufSignature(keyId: ${_this.keyId}, sig: ${_this.sig})';
}


}

/// @nodoc
abstract mixin class $TufSignatureCopyWith<$Res>  {
  factory $TufSignatureCopyWith(TufSignature value, $Res Function(TufSignature) _then) = _$TufSignatureCopyWithImpl;
@useResult
$Res call({
 String keyId, String sig
});




}
/// @nodoc
class _$TufSignatureCopyWithImpl<$Res>
    implements $TufSignatureCopyWith<$Res> {
  _$TufSignatureCopyWithImpl(this._self, this._then);

  final TufSignature _self;
  final $Res Function(TufSignature) _then;

/// Create a copy of TufSignature
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? keyId = null,Object? sig = null,}) {
  return _then(TufSignature(
keyId: null == keyId ? _self.keyId : keyId // ignore: cast_nullable_to_non_nullable
as String,sig: null == sig ? _self.sig : sig // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TufSignature].
extension TufSignaturePatterns on TufSignature {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TufSignature value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TufSignature() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TufSignature value)  $default,){
final _that = this;
switch (_that) {
case _TufSignature():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TufSignature value)?  $default,){
final _that = this;
switch (_that) {
case _TufSignature() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String keyId,  String sig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TufSignature() when $default != null:
return $default(_that.keyId,_that.sig);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String keyId,  String sig)  $default,) {final _that = this;
switch (_that) {
case _TufSignature():
return $default(_that.keyId,_that.sig);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String keyId,  String sig)?  $default,) {final _that = this;
switch (_that) {
case _TufSignature() when $default != null:
return $default(_that.keyId,_that.sig);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TufSignature implements TufSignature {
  const _TufSignature({required this.keyId, required this.sig});
  factory _TufSignature.fromJson(Map<String, dynamic> json) => _$TufSignatureFromJson(json);

/// Lowercase hex SHA-256 of the signing public key.
@override final  String keyId;
/// Base64 Ed25519 signature.
@override final  String sig;

/// Create a copy of TufSignature
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TufSignatureCopyWith<_TufSignature> get copyWith => __$TufSignatureCopyWithImpl<_TufSignature>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufSignatureToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TufSignature&&(identical(other.keyId, keyId) || other.keyId == keyId)&&(identical(other.sig, sig) || other.sig == sig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,keyId,sig);
}

@override
String toString() {
    return 'TufSignature(keyId: $keyId, sig: $sig)';
}


}

/// @nodoc
abstract mixin class _$TufSignatureCopyWith<$Res> implements $TufSignatureCopyWith<$Res> {
  factory _$TufSignatureCopyWith(_TufSignature value, $Res Function(_TufSignature) _then) = __$TufSignatureCopyWithImpl;
@override @useResult
$Res call({
 String keyId, String sig
});




}
/// @nodoc
class __$TufSignatureCopyWithImpl<$Res>
    implements _$TufSignatureCopyWith<$Res> {
  __$TufSignatureCopyWithImpl(this._self, this._then);

  final _TufSignature _self;
  final $Res Function(_TufSignature) _then;

/// Create a copy of TufSignature
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? keyId = null,Object? sig = null,}) {
  return _then(_TufSignature(
keyId: null == keyId ? _self.keyId : keyId // ignore: cast_nullable_to_non_nullable
as String,sig: null == sig ? _self.sig : sig // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
