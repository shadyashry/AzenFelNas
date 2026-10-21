// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tuf_compat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TufCompat {

/// Minimum app version.
 String get minApp;/// Minimum engine schema.
 int get minEngineSchema;
/// Create a copy of TufCompat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufCompatCopyWith<TufCompat> get copyWith => _$TufCompatCopyWithImpl<TufCompat>(this as TufCompat, _$identity);

  /// Serializes this TufCompat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TufCompat;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TufCompat&&(identical(other.minApp, _this.minApp) || other.minApp == _this.minApp)&&(identical(other.minEngineSchema, _this.minEngineSchema) || other.minEngineSchema == _this.minEngineSchema));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TufCompat;
  return Object.hash(runtimeType,_this.minApp,_this.minEngineSchema);
}

@override
String toString() {
  final _this = this as TufCompat;
  return 'TufCompat(minApp: ${_this.minApp}, minEngineSchema: ${_this.minEngineSchema})';
}


}

/// @nodoc
abstract mixin class $TufCompatCopyWith<$Res>  {
  factory $TufCompatCopyWith(TufCompat value, $Res Function(TufCompat) _then) = _$TufCompatCopyWithImpl;
@useResult
$Res call({
 String minApp, int minEngineSchema
});




}
/// @nodoc
class _$TufCompatCopyWithImpl<$Res>
    implements $TufCompatCopyWith<$Res> {
  _$TufCompatCopyWithImpl(this._self, this._then);

  final TufCompat _self;
  final $Res Function(TufCompat) _then;

/// Create a copy of TufCompat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minApp = null,Object? minEngineSchema = null,}) {
  return _then(TufCompat(
minApp: null == minApp ? _self.minApp : minApp // ignore: cast_nullable_to_non_nullable
as String,minEngineSchema: null == minEngineSchema ? _self.minEngineSchema : minEngineSchema // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TufCompat].
extension TufCompatPatterns on TufCompat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TufCompat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TufCompat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TufCompat value)  $default,){
final _that = this;
switch (_that) {
case _TufCompat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TufCompat value)?  $default,){
final _that = this;
switch (_that) {
case _TufCompat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String minApp,  int minEngineSchema)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TufCompat() when $default != null:
return $default(_that.minApp,_that.minEngineSchema);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String minApp,  int minEngineSchema)  $default,) {final _that = this;
switch (_that) {
case _TufCompat():
return $default(_that.minApp,_that.minEngineSchema);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String minApp,  int minEngineSchema)?  $default,) {final _that = this;
switch (_that) {
case _TufCompat() when $default != null:
return $default(_that.minApp,_that.minEngineSchema);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TufCompat implements TufCompat {
  const _TufCompat({required this.minApp, required this.minEngineSchema});
  factory _TufCompat.fromJson(Map<String, dynamic> json) => _$TufCompatFromJson(json);

/// Minimum app version.
@override final  String minApp;
/// Minimum engine schema.
@override final  int minEngineSchema;

/// Create a copy of TufCompat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TufCompatCopyWith<_TufCompat> get copyWith => __$TufCompatCopyWithImpl<_TufCompat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufCompatToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TufCompat&&(identical(other.minApp, minApp) || other.minApp == minApp)&&(identical(other.minEngineSchema, minEngineSchema) || other.minEngineSchema == minEngineSchema));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,minApp,minEngineSchema);
}

@override
String toString() {
    return 'TufCompat(minApp: $minApp, minEngineSchema: $minEngineSchema)';
}


}

/// @nodoc
abstract mixin class _$TufCompatCopyWith<$Res> implements $TufCompatCopyWith<$Res> {
  factory _$TufCompatCopyWith(_TufCompat value, $Res Function(_TufCompat) _then) = __$TufCompatCopyWithImpl;
@override @useResult
$Res call({
 String minApp, int minEngineSchema
});




}
/// @nodoc
class __$TufCompatCopyWithImpl<$Res>
    implements _$TufCompatCopyWith<$Res> {
  __$TufCompatCopyWithImpl(this._self, this._then);

  final _TufCompat _self;
  final $Res Function(_TufCompat) _then;

/// Create a copy of TufCompat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minApp = null,Object? minEngineSchema = null,}) {
  return _then(_TufCompat(
minApp: null == minApp ? _self.minApp : minApp // ignore: cast_nullable_to_non_nullable
as String,minEngineSchema: null == minEngineSchema ? _self.minEngineSchema : minEngineSchema // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
