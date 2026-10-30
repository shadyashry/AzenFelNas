// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quran_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuranSource {

/// What the source supplies.
 QuranSourceRole get role;/// Where it was downloaded from (`https://`).
 String get url;/// Lowercase hex SHA-256 of the downloaded bytes.
 String get sha256;/// The source's own version.
 String get version;/// The licence or usage terms it is used under.
 String get license;
/// Create a copy of QuranSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuranSourceCopyWith<QuranSource> get copyWith => _$QuranSourceCopyWithImpl<QuranSource>(this as QuranSource, _$identity);

  /// Serializes this QuranSource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QuranSource;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuranSource&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.sha256, _this.sha256) || other.sha256 == _this.sha256)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.license, _this.license) || other.license == _this.license));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QuranSource;
  return Object.hash(runtimeType,_this.role,_this.url,_this.sha256,_this.version,_this.license);
}

@override
String toString() {
  final _this = this as QuranSource;
  return 'QuranSource(role: ${_this.role}, url: ${_this.url}, sha256: ${_this.sha256}, version: ${_this.version}, license: ${_this.license})';
}


}

/// @nodoc
abstract mixin class $QuranSourceCopyWith<$Res>  {
  factory $QuranSourceCopyWith(QuranSource value, $Res Function(QuranSource) _then) = _$QuranSourceCopyWithImpl;
@useResult
$Res call({
 QuranSourceRole role, String url, String sha256, String version, String license
});




}
/// @nodoc
class _$QuranSourceCopyWithImpl<$Res>
    implements $QuranSourceCopyWith<$Res> {
  _$QuranSourceCopyWithImpl(this._self, this._then);

  final QuranSource _self;
  final $Res Function(QuranSource) _then;

/// Create a copy of QuranSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? url = null,Object? sha256 = null,Object? version = null,Object? license = null,}) {
  return _then(QuranSource(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as QuranSourceRole,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,license: null == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [QuranSource].
extension QuranSourcePatterns on QuranSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuranSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuranSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuranSource value)  $default,){
final _that = this;
switch (_that) {
case _QuranSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuranSource value)?  $default,){
final _that = this;
switch (_that) {
case _QuranSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( QuranSourceRole role,  String url,  String sha256,  String version,  String license)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuranSource() when $default != null:
return $default(_that.role,_that.url,_that.sha256,_that.version,_that.license);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( QuranSourceRole role,  String url,  String sha256,  String version,  String license)  $default,) {final _that = this;
switch (_that) {
case _QuranSource():
return $default(_that.role,_that.url,_that.sha256,_that.version,_that.license);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( QuranSourceRole role,  String url,  String sha256,  String version,  String license)?  $default,) {final _that = this;
switch (_that) {
case _QuranSource() when $default != null:
return $default(_that.role,_that.url,_that.sha256,_that.version,_that.license);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuranSource implements QuranSource {
  const _QuranSource({required this.role, required this.url, required this.sha256, required this.version, required this.license});
  factory _QuranSource.fromJson(Map<String, dynamic> json) => _$QuranSourceFromJson(json);

/// What the source supplies.
@override final  QuranSourceRole role;
/// Where it was downloaded from (`https://`).
@override final  String url;
/// Lowercase hex SHA-256 of the downloaded bytes.
@override final  String sha256;
/// The source's own version.
@override final  String version;
/// The licence or usage terms it is used under.
@override final  String license;

/// Create a copy of QuranSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuranSourceCopyWith<_QuranSource> get copyWith => __$QuranSourceCopyWithImpl<_QuranSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuranSourceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuranSource&&(identical(other.role, role) || other.role == role)&&(identical(other.url, url) || other.url == url)&&(identical(other.sha256, sha256) || other.sha256 == sha256)&&(identical(other.version, version) || other.version == version)&&(identical(other.license, license) || other.license == license));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,role,url,sha256,version,license);
}

@override
String toString() {
    return 'QuranSource(role: $role, url: $url, sha256: $sha256, version: $version, license: $license)';
}


}

/// @nodoc
abstract mixin class _$QuranSourceCopyWith<$Res> implements $QuranSourceCopyWith<$Res> {
  factory _$QuranSourceCopyWith(_QuranSource value, $Res Function(_QuranSource) _then) = __$QuranSourceCopyWithImpl;
@override @useResult
$Res call({
 QuranSourceRole role, String url, String sha256, String version, String license
});




}
/// @nodoc
class __$QuranSourceCopyWithImpl<$Res>
    implements _$QuranSourceCopyWith<$Res> {
  __$QuranSourceCopyWithImpl(this._self, this._then);

  final _QuranSource _self;
  final $Res Function(_QuranSource) _then;

/// Create a copy of QuranSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? url = null,Object? sha256 = null,Object? version = null,Object? license = null,}) {
  return _then(_QuranSource(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as QuranSourceRole,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,license: null == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
