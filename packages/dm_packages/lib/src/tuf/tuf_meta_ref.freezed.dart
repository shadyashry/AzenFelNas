// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tuf_meta_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TufMetaRef {

/// Referenced sequence.
 int get version;/// Lowercase hex SHA-256 of the file.
 String get sha256;
/// Create a copy of TufMetaRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufMetaRefCopyWith<TufMetaRef> get copyWith => _$TufMetaRefCopyWithImpl<TufMetaRef>(this as TufMetaRef, _$identity);

  /// Serializes this TufMetaRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TufMetaRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TufMetaRef&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.sha256, _this.sha256) || other.sha256 == _this.sha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TufMetaRef;
  return Object.hash(runtimeType,_this.version,_this.sha256);
}

@override
String toString() {
  final _this = this as TufMetaRef;
  return 'TufMetaRef(version: ${_this.version}, sha256: ${_this.sha256})';
}


}

/// @nodoc
abstract mixin class $TufMetaRefCopyWith<$Res>  {
  factory $TufMetaRefCopyWith(TufMetaRef value, $Res Function(TufMetaRef) _then) = _$TufMetaRefCopyWithImpl;
@useResult
$Res call({
 int version, String sha256
});




}
/// @nodoc
class _$TufMetaRefCopyWithImpl<$Res>
    implements $TufMetaRefCopyWith<$Res> {
  _$TufMetaRefCopyWithImpl(this._self, this._then);

  final TufMetaRef _self;
  final $Res Function(TufMetaRef) _then;

/// Create a copy of TufMetaRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? sha256 = null,}) {
  return _then(TufMetaRef(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TufMetaRef].
extension TufMetaRefPatterns on TufMetaRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TufMetaRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TufMetaRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TufMetaRef value)  $default,){
final _that = this;
switch (_that) {
case _TufMetaRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TufMetaRef value)?  $default,){
final _that = this;
switch (_that) {
case _TufMetaRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int version,  String sha256)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TufMetaRef() when $default != null:
return $default(_that.version,_that.sha256);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int version,  String sha256)  $default,) {final _that = this;
switch (_that) {
case _TufMetaRef():
return $default(_that.version,_that.sha256);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int version,  String sha256)?  $default,) {final _that = this;
switch (_that) {
case _TufMetaRef() when $default != null:
return $default(_that.version,_that.sha256);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TufMetaRef implements TufMetaRef {
  const _TufMetaRef({required this.version, required this.sha256});
  factory _TufMetaRef.fromJson(Map<String, dynamic> json) => _$TufMetaRefFromJson(json);

/// Referenced sequence.
@override final  int version;
/// Lowercase hex SHA-256 of the file.
@override final  String sha256;

/// Create a copy of TufMetaRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TufMetaRefCopyWith<_TufMetaRef> get copyWith => __$TufMetaRefCopyWithImpl<_TufMetaRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufMetaRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TufMetaRef&&(identical(other.version, version) || other.version == version)&&(identical(other.sha256, sha256) || other.sha256 == sha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,version,sha256);
}

@override
String toString() {
    return 'TufMetaRef(version: $version, sha256: $sha256)';
}


}

/// @nodoc
abstract mixin class _$TufMetaRefCopyWith<$Res> implements $TufMetaRefCopyWith<$Res> {
  factory _$TufMetaRefCopyWith(_TufMetaRef value, $Res Function(_TufMetaRef) _then) = __$TufMetaRefCopyWithImpl;
@override @useResult
$Res call({
 int version, String sha256
});




}
/// @nodoc
class __$TufMetaRefCopyWithImpl<$Res>
    implements _$TufMetaRefCopyWith<$Res> {
  __$TufMetaRefCopyWithImpl(this._self, this._then);

  final _TufMetaRef _self;
  final $Res Function(_TufMetaRef) _then;

/// Create a copy of TufMetaRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? sha256 = null,}) {
  return _then(_TufMetaRef(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
