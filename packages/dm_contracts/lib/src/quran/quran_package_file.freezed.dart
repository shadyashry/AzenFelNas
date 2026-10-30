// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quran_package_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuranPackageFile {

/// Path relative to the package directory (lowercase, no `..`).
 String get path;/// Size in bytes.
 int get bytes;/// Lowercase hex SHA-256.
 String get sha256;
/// Create a copy of QuranPackageFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuranPackageFileCopyWith<QuranPackageFile> get copyWith => _$QuranPackageFileCopyWithImpl<QuranPackageFile>(this as QuranPackageFile, _$identity);

  /// Serializes this QuranPackageFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QuranPackageFile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuranPackageFile&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.bytes, _this.bytes) || other.bytes == _this.bytes)&&(identical(other.sha256, _this.sha256) || other.sha256 == _this.sha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QuranPackageFile;
  return Object.hash(runtimeType,_this.path,_this.bytes,_this.sha256);
}

@override
String toString() {
  final _this = this as QuranPackageFile;
  return 'QuranPackageFile(path: ${_this.path}, bytes: ${_this.bytes}, sha256: ${_this.sha256})';
}


}

/// @nodoc
abstract mixin class $QuranPackageFileCopyWith<$Res>  {
  factory $QuranPackageFileCopyWith(QuranPackageFile value, $Res Function(QuranPackageFile) _then) = _$QuranPackageFileCopyWithImpl;
@useResult
$Res call({
 String path, int bytes, String sha256
});




}
/// @nodoc
class _$QuranPackageFileCopyWithImpl<$Res>
    implements $QuranPackageFileCopyWith<$Res> {
  _$QuranPackageFileCopyWithImpl(this._self, this._then);

  final QuranPackageFile _self;
  final $Res Function(QuranPackageFile) _then;

/// Create a copy of QuranPackageFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? bytes = null,Object? sha256 = null,}) {
  return _then(QuranPackageFile(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [QuranPackageFile].
extension QuranPackageFilePatterns on QuranPackageFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuranPackageFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuranPackageFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuranPackageFile value)  $default,){
final _that = this;
switch (_that) {
case _QuranPackageFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuranPackageFile value)?  $default,){
final _that = this;
switch (_that) {
case _QuranPackageFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  int bytes,  String sha256)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuranPackageFile() when $default != null:
return $default(_that.path,_that.bytes,_that.sha256);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  int bytes,  String sha256)  $default,) {final _that = this;
switch (_that) {
case _QuranPackageFile():
return $default(_that.path,_that.bytes,_that.sha256);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  int bytes,  String sha256)?  $default,) {final _that = this;
switch (_that) {
case _QuranPackageFile() when $default != null:
return $default(_that.path,_that.bytes,_that.sha256);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuranPackageFile implements QuranPackageFile {
  const _QuranPackageFile({required this.path, required this.bytes, required this.sha256});
  factory _QuranPackageFile.fromJson(Map<String, dynamic> json) => _$QuranPackageFileFromJson(json);

/// Path relative to the package directory (lowercase, no `..`).
@override final  String path;
/// Size in bytes.
@override final  int bytes;
/// Lowercase hex SHA-256.
@override final  String sha256;

/// Create a copy of QuranPackageFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuranPackageFileCopyWith<_QuranPackageFile> get copyWith => __$QuranPackageFileCopyWithImpl<_QuranPackageFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuranPackageFileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuranPackageFile&&(identical(other.path, path) || other.path == path)&&(identical(other.bytes, bytes) || other.bytes == bytes)&&(identical(other.sha256, sha256) || other.sha256 == sha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,path,bytes,sha256);
}

@override
String toString() {
    return 'QuranPackageFile(path: $path, bytes: $bytes, sha256: $sha256)';
}


}

/// @nodoc
abstract mixin class _$QuranPackageFileCopyWith<$Res> implements $QuranPackageFileCopyWith<$Res> {
  factory _$QuranPackageFileCopyWith(_QuranPackageFile value, $Res Function(_QuranPackageFile) _then) = __$QuranPackageFileCopyWithImpl;
@override @useResult
$Res call({
 String path, int bytes, String sha256
});




}
/// @nodoc
class __$QuranPackageFileCopyWithImpl<$Res>
    implements _$QuranPackageFileCopyWith<$Res> {
  __$QuranPackageFileCopyWithImpl(this._self, this._then);

  final _QuranPackageFile _self;
  final $Res Function(_QuranPackageFile) _then;

/// Create a copy of QuranPackageFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? bytes = null,Object? sha256 = null,}) {
  return _then(_QuranPackageFile(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
