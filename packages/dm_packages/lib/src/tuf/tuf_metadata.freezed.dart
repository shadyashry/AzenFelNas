// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tuf_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TufMetadata {

/// The signed role document.
 TufSigned get signed;/// Signatures over JCS(`signed`).
 List<TufSignature> get signatures;
/// Create a copy of TufMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufMetadataCopyWith<TufMetadata> get copyWith => _$TufMetadataCopyWithImpl<TufMetadata>(this as TufMetadata, _$identity);

  /// Serializes this TufMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TufMetadata;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TufMetadata&&(identical(other.signed, _this.signed) || other.signed == _this.signed)&&const DeepCollectionEquality().equals(other.signatures, _this.signatures));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TufMetadata;
  return Object.hash(runtimeType,_this.signed,const DeepCollectionEquality().hash(_this.signatures));
}

@override
String toString() {
  final _this = this as TufMetadata;
  return 'TufMetadata(signed: ${_this.signed}, signatures: ${_this.signatures})';
}


}

/// @nodoc
abstract mixin class $TufMetadataCopyWith<$Res>  {
  factory $TufMetadataCopyWith(TufMetadata value, $Res Function(TufMetadata) _then) = _$TufMetadataCopyWithImpl;
@useResult
$Res call({
 TufSigned signed, List<TufSignature> signatures
});


$TufSignedCopyWith<$Res> get signed;

}
/// @nodoc
class _$TufMetadataCopyWithImpl<$Res>
    implements $TufMetadataCopyWith<$Res> {
  _$TufMetadataCopyWithImpl(this._self, this._then);

  final TufMetadata _self;
  final $Res Function(TufMetadata) _then;

/// Create a copy of TufMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? signed = null,Object? signatures = null,}) {
  return _then(TufMetadata(
signed: null == signed ? _self.signed : signed // ignore: cast_nullable_to_non_nullable
as TufSigned,signatures: null == signatures ? _self.signatures : signatures // ignore: cast_nullable_to_non_nullable
as List<TufSignature>,
  ));
}
/// Create a copy of TufMetadata
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufSignedCopyWith<$Res> get signed {
  
  return $TufSignedCopyWith<$Res>(_self.signed, (value) {
    return _then(_self.copyWith(signed: value));
  });
}
}


/// Adds pattern-matching-related methods to [TufMetadata].
extension TufMetadataPatterns on TufMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TufMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TufMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TufMetadata value)  $default,){
final _that = this;
switch (_that) {
case _TufMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TufMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _TufMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TufSigned signed,  List<TufSignature> signatures)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TufMetadata() when $default != null:
return $default(_that.signed,_that.signatures);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TufSigned signed,  List<TufSignature> signatures)  $default,) {final _that = this;
switch (_that) {
case _TufMetadata():
return $default(_that.signed,_that.signatures);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TufSigned signed,  List<TufSignature> signatures)?  $default,) {final _that = this;
switch (_that) {
case _TufMetadata() when $default != null:
return $default(_that.signed,_that.signatures);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TufMetadata implements TufMetadata {
  const _TufMetadata({required this.signed, required  List<TufSignature> signatures}): _signatures = signatures;
  factory _TufMetadata.fromJson(Map<String, dynamic> json) => _$TufMetadataFromJson(json);

/// The signed role document.
@override final  TufSigned signed;
/// Signatures over JCS(`signed`).
 final  List<TufSignature> _signatures;
/// Signatures over JCS(`signed`).
@override List<TufSignature> get signatures {
  if (_signatures is EqualUnmodifiableListView) return _signatures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_signatures);
}


/// Create a copy of TufMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TufMetadataCopyWith<_TufMetadata> get copyWith => __$TufMetadataCopyWithImpl<_TufMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TufMetadata&&(identical(other.signed, signed) || other.signed == signed)&&const DeepCollectionEquality().equals(other.signatures, _signatures));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,signed,const DeepCollectionEquality().hash(_signatures));
}

@override
String toString() {
    return 'TufMetadata(signed: $signed, signatures: $signatures)';
}


}

/// @nodoc
abstract mixin class _$TufMetadataCopyWith<$Res> implements $TufMetadataCopyWith<$Res> {
  factory _$TufMetadataCopyWith(_TufMetadata value, $Res Function(_TufMetadata) _then) = __$TufMetadataCopyWithImpl;
@override @useResult
$Res call({
 TufSigned signed, List<TufSignature> signatures
});


@override $TufSignedCopyWith<$Res> get signed;

}
/// @nodoc
class __$TufMetadataCopyWithImpl<$Res>
    implements _$TufMetadataCopyWith<$Res> {
  __$TufMetadataCopyWithImpl(this._self, this._then);

  final _TufMetadata _self;
  final $Res Function(_TufMetadata) _then;

/// Create a copy of TufMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? signed = null,Object? signatures = null,}) {
  return _then(_TufMetadata(
signed: null == signed ? _self.signed : signed // ignore: cast_nullable_to_non_nullable
as TufSigned,signatures: null == signatures ? _self._signatures : signatures // ignore: cast_nullable_to_non_nullable
as List<TufSignature>,
  ));
}

/// Create a copy of TufMetadata
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufSignedCopyWith<$Res> get signed {
  
  return $TufSignedCopyWith<$Res>(_self.signed, (value) {
    return _then(_self.copyWith(signed: value));
  });
}
}

// dart format on
