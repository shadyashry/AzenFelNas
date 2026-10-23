// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'athan_ios_clip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AthanIosClip {

/// Path under `assets/`.
 String get file;/// Duration, at most 29 000.
 int get durationMs;/// Lowercase hex SHA-256.
 String get sha256;
/// Create a copy of AthanIosClip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AthanIosClipCopyWith<AthanIosClip> get copyWith => _$AthanIosClipCopyWithImpl<AthanIosClip>(this as AthanIosClip, _$identity);

  /// Serializes this AthanIosClip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AthanIosClip;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AthanIosClip&&(identical(other.file, _this.file) || other.file == _this.file)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.sha256, _this.sha256) || other.sha256 == _this.sha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AthanIosClip;
  return Object.hash(runtimeType,_this.file,_this.durationMs,_this.sha256);
}

@override
String toString() {
  final _this = this as AthanIosClip;
  return 'AthanIosClip(file: ${_this.file}, durationMs: ${_this.durationMs}, sha256: ${_this.sha256})';
}


}

/// @nodoc
abstract mixin class $AthanIosClipCopyWith<$Res>  {
  factory $AthanIosClipCopyWith(AthanIosClip value, $Res Function(AthanIosClip) _then) = _$AthanIosClipCopyWithImpl;
@useResult
$Res call({
 String file, int durationMs, String sha256
});




}
/// @nodoc
class _$AthanIosClipCopyWithImpl<$Res>
    implements $AthanIosClipCopyWith<$Res> {
  _$AthanIosClipCopyWithImpl(this._self, this._then);

  final AthanIosClip _self;
  final $Res Function(AthanIosClip) _then;

/// Create a copy of AthanIosClip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? file = null,Object? durationMs = null,Object? sha256 = null,}) {
  return _then(AthanIosClip(
file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AthanIosClip].
extension AthanIosClipPatterns on AthanIosClip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AthanIosClip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AthanIosClip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AthanIosClip value)  $default,){
final _that = this;
switch (_that) {
case _AthanIosClip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AthanIosClip value)?  $default,){
final _that = this;
switch (_that) {
case _AthanIosClip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String file,  int durationMs,  String sha256)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AthanIosClip() when $default != null:
return $default(_that.file,_that.durationMs,_that.sha256);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String file,  int durationMs,  String sha256)  $default,) {final _that = this;
switch (_that) {
case _AthanIosClip():
return $default(_that.file,_that.durationMs,_that.sha256);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String file,  int durationMs,  String sha256)?  $default,) {final _that = this;
switch (_that) {
case _AthanIosClip() when $default != null:
return $default(_that.file,_that.durationMs,_that.sha256);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AthanIosClip implements AthanIosClip {
  const _AthanIosClip({required this.file, required this.durationMs, required this.sha256});
  factory _AthanIosClip.fromJson(Map<String, dynamic> json) => _$AthanIosClipFromJson(json);

/// Path under `assets/`.
@override final  String file;
/// Duration, at most 29 000.
@override final  int durationMs;
/// Lowercase hex SHA-256.
@override final  String sha256;

/// Create a copy of AthanIosClip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AthanIosClipCopyWith<_AthanIosClip> get copyWith => __$AthanIosClipCopyWithImpl<_AthanIosClip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AthanIosClipToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AthanIosClip&&(identical(other.file, file) || other.file == file)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.sha256, sha256) || other.sha256 == sha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,file,durationMs,sha256);
}

@override
String toString() {
    return 'AthanIosClip(file: $file, durationMs: $durationMs, sha256: $sha256)';
}


}

/// @nodoc
abstract mixin class _$AthanIosClipCopyWith<$Res> implements $AthanIosClipCopyWith<$Res> {
  factory _$AthanIosClipCopyWith(_AthanIosClip value, $Res Function(_AthanIosClip) _then) = __$AthanIosClipCopyWithImpl;
@override @useResult
$Res call({
 String file, int durationMs, String sha256
});




}
/// @nodoc
class __$AthanIosClipCopyWithImpl<$Res>
    implements _$AthanIosClipCopyWith<$Res> {
  __$AthanIosClipCopyWithImpl(this._self, this._then);

  final _AthanIosClip _self;
  final $Res Function(_AthanIosClip) _then;

/// Create a copy of AthanIosClip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? file = null,Object? durationMs = null,Object? sha256 = null,}) {
  return _then(_AthanIosClip(
file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
