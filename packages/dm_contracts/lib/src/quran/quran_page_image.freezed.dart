// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quran_page_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuranPageImage {

/// `webp-lossless` in v1.
 String get format;/// Width in pixels.
 int get width;/// Height in pixels.
 int get height;/// Path of page N, e.g. `pages/{page:03}.webp`.
 String get pathPattern;
/// Create a copy of QuranPageImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuranPageImageCopyWith<QuranPageImage> get copyWith => _$QuranPageImageCopyWithImpl<QuranPageImage>(this as QuranPageImage, _$identity);

  /// Serializes this QuranPageImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QuranPageImage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuranPageImage&&(identical(other.format, _this.format) || other.format == _this.format)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.pathPattern, _this.pathPattern) || other.pathPattern == _this.pathPattern));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QuranPageImage;
  return Object.hash(runtimeType,_this.format,_this.width,_this.height,_this.pathPattern);
}

@override
String toString() {
  final _this = this as QuranPageImage;
  return 'QuranPageImage(format: ${_this.format}, width: ${_this.width}, height: ${_this.height}, pathPattern: ${_this.pathPattern})';
}


}

/// @nodoc
abstract mixin class $QuranPageImageCopyWith<$Res>  {
  factory $QuranPageImageCopyWith(QuranPageImage value, $Res Function(QuranPageImage) _then) = _$QuranPageImageCopyWithImpl;
@useResult
$Res call({
 String format, int width, int height, String pathPattern
});




}
/// @nodoc
class _$QuranPageImageCopyWithImpl<$Res>
    implements $QuranPageImageCopyWith<$Res> {
  _$QuranPageImageCopyWithImpl(this._self, this._then);

  final QuranPageImage _self;
  final $Res Function(QuranPageImage) _then;

/// Create a copy of QuranPageImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? format = null,Object? width = null,Object? height = null,Object? pathPattern = null,}) {
  return _then(QuranPageImage(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,pathPattern: null == pathPattern ? _self.pathPattern : pathPattern // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [QuranPageImage].
extension QuranPageImagePatterns on QuranPageImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuranPageImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuranPageImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuranPageImage value)  $default,){
final _that = this;
switch (_that) {
case _QuranPageImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuranPageImage value)?  $default,){
final _that = this;
switch (_that) {
case _QuranPageImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String format,  int width,  int height,  String pathPattern)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuranPageImage() when $default != null:
return $default(_that.format,_that.width,_that.height,_that.pathPattern);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String format,  int width,  int height,  String pathPattern)  $default,) {final _that = this;
switch (_that) {
case _QuranPageImage():
return $default(_that.format,_that.width,_that.height,_that.pathPattern);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String format,  int width,  int height,  String pathPattern)?  $default,) {final _that = this;
switch (_that) {
case _QuranPageImage() when $default != null:
return $default(_that.format,_that.width,_that.height,_that.pathPattern);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuranPageImage implements QuranPageImage {
  const _QuranPageImage({required this.format, required this.width, required this.height, required this.pathPattern});
  factory _QuranPageImage.fromJson(Map<String, dynamic> json) => _$QuranPageImageFromJson(json);

/// `webp-lossless` in v1.
@override final  String format;
/// Width in pixels.
@override final  int width;
/// Height in pixels.
@override final  int height;
/// Path of page N, e.g. `pages/{page:03}.webp`.
@override final  String pathPattern;

/// Create a copy of QuranPageImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuranPageImageCopyWith<_QuranPageImage> get copyWith => __$QuranPageImageCopyWithImpl<_QuranPageImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuranPageImageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuranPageImage&&(identical(other.format, format) || other.format == format)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.pathPattern, pathPattern) || other.pathPattern == pathPattern));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,format,width,height,pathPattern);
}

@override
String toString() {
    return 'QuranPageImage(format: $format, width: $width, height: $height, pathPattern: $pathPattern)';
}


}

/// @nodoc
abstract mixin class _$QuranPageImageCopyWith<$Res> implements $QuranPageImageCopyWith<$Res> {
  factory _$QuranPageImageCopyWith(_QuranPageImage value, $Res Function(_QuranPageImage) _then) = __$QuranPageImageCopyWithImpl;
@override @useResult
$Res call({
 String format, int width, int height, String pathPattern
});




}
/// @nodoc
class __$QuranPageImageCopyWithImpl<$Res>
    implements _$QuranPageImageCopyWith<$Res> {
  __$QuranPageImageCopyWithImpl(this._self, this._then);

  final _QuranPageImage _self;
  final $Res Function(_QuranPageImage) _then;

/// Create a copy of QuranPageImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? format = null,Object? width = null,Object? height = null,Object? pathPattern = null,}) {
  return _then(_QuranPageImage(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,pathPattern: null == pathPattern ? _self.pathPattern : pathPattern // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
