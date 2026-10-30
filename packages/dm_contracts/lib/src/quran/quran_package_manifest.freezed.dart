// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quran_package_manifest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuranPackageManifest {

/// Always 1.
 int get schemaVersion;/// e.g. `hafs-madinah-1441`.
 String get packageId;/// Package build, e.g. `1441.1`.
 String get version;/// Page layout identity; annotations are stored against it.
 String get layoutId;/// The edition and its sources.
 QuranEdition get edition;/// Page image geometry.
 QuranPageImage get pageImage;/// Every file with its size and SHA-256.
 List<QuranPackageFile> get files;
/// Create a copy of QuranPackageManifest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuranPackageManifestCopyWith<QuranPackageManifest> get copyWith => _$QuranPackageManifestCopyWithImpl<QuranPackageManifest>(this as QuranPackageManifest, _$identity);

  /// Serializes this QuranPackageManifest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QuranPackageManifest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuranPackageManifest&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.packageId, _this.packageId) || other.packageId == _this.packageId)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.layoutId, _this.layoutId) || other.layoutId == _this.layoutId)&&(identical(other.edition, _this.edition) || other.edition == _this.edition)&&(identical(other.pageImage, _this.pageImage) || other.pageImage == _this.pageImage)&&const DeepCollectionEquality().equals(other.files, _this.files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QuranPackageManifest;
  return Object.hash(runtimeType,_this.schemaVersion,_this.packageId,_this.version,_this.layoutId,_this.edition,_this.pageImage,const DeepCollectionEquality().hash(_this.files));
}

@override
String toString() {
  final _this = this as QuranPackageManifest;
  return 'QuranPackageManifest(schemaVersion: ${_this.schemaVersion}, packageId: ${_this.packageId}, version: ${_this.version}, layoutId: ${_this.layoutId}, edition: ${_this.edition}, pageImage: ${_this.pageImage}, files: ${_this.files})';
}


}

/// @nodoc
abstract mixin class $QuranPackageManifestCopyWith<$Res>  {
  factory $QuranPackageManifestCopyWith(QuranPackageManifest value, $Res Function(QuranPackageManifest) _then) = _$QuranPackageManifestCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String packageId, String version, String layoutId, QuranEdition edition, QuranPageImage pageImage, List<QuranPackageFile> files
});


$QuranEditionCopyWith<$Res> get edition;$QuranPageImageCopyWith<$Res> get pageImage;

}
/// @nodoc
class _$QuranPackageManifestCopyWithImpl<$Res>
    implements $QuranPackageManifestCopyWith<$Res> {
  _$QuranPackageManifestCopyWithImpl(this._self, this._then);

  final QuranPackageManifest _self;
  final $Res Function(QuranPackageManifest) _then;

/// Create a copy of QuranPackageManifest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? packageId = null,Object? version = null,Object? layoutId = null,Object? edition = null,Object? pageImage = null,Object? files = null,}) {
  return _then(QuranPackageManifest(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,layoutId: null == layoutId ? _self.layoutId : layoutId // ignore: cast_nullable_to_non_nullable
as String,edition: null == edition ? _self.edition : edition // ignore: cast_nullable_to_non_nullable
as QuranEdition,pageImage: null == pageImage ? _self.pageImage : pageImage // ignore: cast_nullable_to_non_nullable
as QuranPageImage,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<QuranPackageFile>,
  ));
}
/// Create a copy of QuranPackageManifest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuranEditionCopyWith<$Res> get edition {
  
  return $QuranEditionCopyWith<$Res>(_self.edition, (value) {
    return _then(_self.copyWith(edition: value));
  });
}/// Create a copy of QuranPackageManifest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuranPageImageCopyWith<$Res> get pageImage {
  
  return $QuranPageImageCopyWith<$Res>(_self.pageImage, (value) {
    return _then(_self.copyWith(pageImage: value));
  });
}
}


/// Adds pattern-matching-related methods to [QuranPackageManifest].
extension QuranPackageManifestPatterns on QuranPackageManifest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuranPackageManifest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuranPackageManifest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuranPackageManifest value)  $default,){
final _that = this;
switch (_that) {
case _QuranPackageManifest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuranPackageManifest value)?  $default,){
final _that = this;
switch (_that) {
case _QuranPackageManifest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String packageId,  String version,  String layoutId,  QuranEdition edition,  QuranPageImage pageImage,  List<QuranPackageFile> files)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuranPackageManifest() when $default != null:
return $default(_that.schemaVersion,_that.packageId,_that.version,_that.layoutId,_that.edition,_that.pageImage,_that.files);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String packageId,  String version,  String layoutId,  QuranEdition edition,  QuranPageImage pageImage,  List<QuranPackageFile> files)  $default,) {final _that = this;
switch (_that) {
case _QuranPackageManifest():
return $default(_that.schemaVersion,_that.packageId,_that.version,_that.layoutId,_that.edition,_that.pageImage,_that.files);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String packageId,  String version,  String layoutId,  QuranEdition edition,  QuranPageImage pageImage,  List<QuranPackageFile> files)?  $default,) {final _that = this;
switch (_that) {
case _QuranPackageManifest() when $default != null:
return $default(_that.schemaVersion,_that.packageId,_that.version,_that.layoutId,_that.edition,_that.pageImage,_that.files);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuranPackageManifest implements QuranPackageManifest {
  const _QuranPackageManifest({required this.schemaVersion, required this.packageId, required this.version, required this.layoutId, required this.edition, required this.pageImage, required  List<QuranPackageFile> files}): _files = files;
  factory _QuranPackageManifest.fromJson(Map<String, dynamic> json) => _$QuranPackageManifestFromJson(json);

/// Always 1.
@override final  int schemaVersion;
/// e.g. `hafs-madinah-1441`.
@override final  String packageId;
/// Package build, e.g. `1441.1`.
@override final  String version;
/// Page layout identity; annotations are stored against it.
@override final  String layoutId;
/// The edition and its sources.
@override final  QuranEdition edition;
/// Page image geometry.
@override final  QuranPageImage pageImage;
/// Every file with its size and SHA-256.
 final  List<QuranPackageFile> _files;
/// Every file with its size and SHA-256.
@override List<QuranPackageFile> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}


/// Create a copy of QuranPackageManifest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuranPackageManifestCopyWith<_QuranPackageManifest> get copyWith => __$QuranPackageManifestCopyWithImpl<_QuranPackageManifest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuranPackageManifestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuranPackageManifest&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.version, version) || other.version == version)&&(identical(other.layoutId, layoutId) || other.layoutId == layoutId)&&(identical(other.edition, edition) || other.edition == edition)&&(identical(other.pageImage, pageImage) || other.pageImage == pageImage)&&const DeepCollectionEquality().equals(other.files, _files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,packageId,version,layoutId,edition,pageImage,const DeepCollectionEquality().hash(_files));
}

@override
String toString() {
    return 'QuranPackageManifest(schemaVersion: $schemaVersion, packageId: $packageId, version: $version, layoutId: $layoutId, edition: $edition, pageImage: $pageImage, files: $files)';
}


}

/// @nodoc
abstract mixin class _$QuranPackageManifestCopyWith<$Res> implements $QuranPackageManifestCopyWith<$Res> {
  factory _$QuranPackageManifestCopyWith(_QuranPackageManifest value, $Res Function(_QuranPackageManifest) _then) = __$QuranPackageManifestCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String packageId, String version, String layoutId, QuranEdition edition, QuranPageImage pageImage, List<QuranPackageFile> files
});


@override $QuranEditionCopyWith<$Res> get edition;@override $QuranPageImageCopyWith<$Res> get pageImage;

}
/// @nodoc
class __$QuranPackageManifestCopyWithImpl<$Res>
    implements _$QuranPackageManifestCopyWith<$Res> {
  __$QuranPackageManifestCopyWithImpl(this._self, this._then);

  final _QuranPackageManifest _self;
  final $Res Function(_QuranPackageManifest) _then;

/// Create a copy of QuranPackageManifest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? packageId = null,Object? version = null,Object? layoutId = null,Object? edition = null,Object? pageImage = null,Object? files = null,}) {
  return _then(_QuranPackageManifest(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,layoutId: null == layoutId ? _self.layoutId : layoutId // ignore: cast_nullable_to_non_nullable
as String,edition: null == edition ? _self.edition : edition // ignore: cast_nullable_to_non_nullable
as QuranEdition,pageImage: null == pageImage ? _self.pageImage : pageImage // ignore: cast_nullable_to_non_nullable
as QuranPageImage,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<QuranPackageFile>,
  ));
}

/// Create a copy of QuranPackageManifest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuranEditionCopyWith<$Res> get edition {
  
  return $QuranEditionCopyWith<$Res>(_self.edition, (value) {
    return _then(_self.copyWith(edition: value));
  });
}/// Create a copy of QuranPackageManifest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuranPageImageCopyWith<$Res> get pageImage {
  
  return $QuranPageImageCopyWith<$Res>(_self.pageImage, (value) {
    return _then(_self.copyWith(pageImage: value));
  });
}
}

// dart format on
