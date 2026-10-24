// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagnostic_bundle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DiagnosticBundle {

/// Always [currentSchemaVersion].
 int get schemaVersion;/// When the bundle was assembled.
 int get createdUtcMs;/// The §7.2 members.
 DiagnosticFiles get files;
/// Create a copy of DiagnosticBundle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiagnosticBundleCopyWith<DiagnosticBundle> get copyWith => _$DiagnosticBundleCopyWithImpl<DiagnosticBundle>(this as DiagnosticBundle, _$identity);

  /// Serializes this DiagnosticBundle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DiagnosticBundle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiagnosticBundle&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.createdUtcMs, _this.createdUtcMs) || other.createdUtcMs == _this.createdUtcMs)&&(identical(other.files, _this.files) || other.files == _this.files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DiagnosticBundle;
  return Object.hash(runtimeType,_this.schemaVersion,_this.createdUtcMs,_this.files);
}

@override
String toString() {
  final _this = this as DiagnosticBundle;
  return 'DiagnosticBundle(schemaVersion: ${_this.schemaVersion}, createdUtcMs: ${_this.createdUtcMs}, files: ${_this.files})';
}


}

/// @nodoc
abstract mixin class $DiagnosticBundleCopyWith<$Res>  {
  factory $DiagnosticBundleCopyWith(DiagnosticBundle value, $Res Function(DiagnosticBundle) _then) = _$DiagnosticBundleCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, int createdUtcMs, DiagnosticFiles files
});


$DiagnosticFilesCopyWith<$Res> get files;

}
/// @nodoc
class _$DiagnosticBundleCopyWithImpl<$Res>
    implements $DiagnosticBundleCopyWith<$Res> {
  _$DiagnosticBundleCopyWithImpl(this._self, this._then);

  final DiagnosticBundle _self;
  final $Res Function(DiagnosticBundle) _then;

/// Create a copy of DiagnosticBundle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? createdUtcMs = null,Object? files = null,}) {
  return _then(DiagnosticBundle(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,createdUtcMs: null == createdUtcMs ? _self.createdUtcMs : createdUtcMs // ignore: cast_nullable_to_non_nullable
as int,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as DiagnosticFiles,
  ));
}
/// Create a copy of DiagnosticBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiagnosticFilesCopyWith<$Res> get files {
  
  return $DiagnosticFilesCopyWith<$Res>(_self.files, (value) {
    return _then(_self.copyWith(files: value));
  });
}
}


/// Adds pattern-matching-related methods to [DiagnosticBundle].
extension DiagnosticBundlePatterns on DiagnosticBundle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiagnosticBundle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiagnosticBundle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiagnosticBundle value)  $default,){
final _that = this;
switch (_that) {
case _DiagnosticBundle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiagnosticBundle value)?  $default,){
final _that = this;
switch (_that) {
case _DiagnosticBundle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  int createdUtcMs,  DiagnosticFiles files)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiagnosticBundle() when $default != null:
return $default(_that.schemaVersion,_that.createdUtcMs,_that.files);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  int createdUtcMs,  DiagnosticFiles files)  $default,) {final _that = this;
switch (_that) {
case _DiagnosticBundle():
return $default(_that.schemaVersion,_that.createdUtcMs,_that.files);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  int createdUtcMs,  DiagnosticFiles files)?  $default,) {final _that = this;
switch (_that) {
case _DiagnosticBundle() when $default != null:
return $default(_that.schemaVersion,_that.createdUtcMs,_that.files);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiagnosticBundle implements DiagnosticBundle {
  const _DiagnosticBundle({required this.schemaVersion, required this.createdUtcMs, required this.files});
  factory _DiagnosticBundle.fromJson(Map<String, dynamic> json) => _$DiagnosticBundleFromJson(json);

/// Always [currentSchemaVersion].
@override final  int schemaVersion;
/// When the bundle was assembled.
@override final  int createdUtcMs;
/// The §7.2 members.
@override final  DiagnosticFiles files;

/// Create a copy of DiagnosticBundle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiagnosticBundleCopyWith<_DiagnosticBundle> get copyWith => __$DiagnosticBundleCopyWithImpl<_DiagnosticBundle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiagnosticBundleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiagnosticBundle&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.createdUtcMs, createdUtcMs) || other.createdUtcMs == createdUtcMs)&&(identical(other.files, files) || other.files == files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,createdUtcMs,files);
}

@override
String toString() {
    return 'DiagnosticBundle(schemaVersion: $schemaVersion, createdUtcMs: $createdUtcMs, files: $files)';
}


}

/// @nodoc
abstract mixin class _$DiagnosticBundleCopyWith<$Res> implements $DiagnosticBundleCopyWith<$Res> {
  factory _$DiagnosticBundleCopyWith(_DiagnosticBundle value, $Res Function(_DiagnosticBundle) _then) = __$DiagnosticBundleCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, int createdUtcMs, DiagnosticFiles files
});


@override $DiagnosticFilesCopyWith<$Res> get files;

}
/// @nodoc
class __$DiagnosticBundleCopyWithImpl<$Res>
    implements _$DiagnosticBundleCopyWith<$Res> {
  __$DiagnosticBundleCopyWithImpl(this._self, this._then);

  final _DiagnosticBundle _self;
  final $Res Function(_DiagnosticBundle) _then;

/// Create a copy of DiagnosticBundle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? createdUtcMs = null,Object? files = null,}) {
  return _then(_DiagnosticBundle(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,createdUtcMs: null == createdUtcMs ? _self.createdUtcMs : createdUtcMs // ignore: cast_nullable_to_non_nullable
as int,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as DiagnosticFiles,
  ));
}

/// Create a copy of DiagnosticBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiagnosticFilesCopyWith<$Res> get files {
  
  return $DiagnosticFilesCopyWith<$Res>(_self.files, (value) {
    return _then(_self.copyWith(files: value));
  });
}
}

// dart format on
