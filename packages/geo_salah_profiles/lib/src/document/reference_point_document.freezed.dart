// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reference_point_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReferencePointDocument {

/// ISO 3166-1 alpha-2 or ISO 3166-2 area code.
 String get area;/// Latitude in degrees.
 double get lat;/// Longitude in degrees.
 double get lon;
/// Create a copy of ReferencePointDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReferencePointDocumentCopyWith<ReferencePointDocument> get copyWith => _$ReferencePointDocumentCopyWithImpl<ReferencePointDocument>(this as ReferencePointDocument, _$identity);

  /// Serializes this ReferencePointDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReferencePointDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReferencePointDocument&&(identical(other.area, _this.area) || other.area == _this.area)&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lon, _this.lon) || other.lon == _this.lon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReferencePointDocument;
  return Object.hash(runtimeType,_this.area,_this.lat,_this.lon);
}

@override
String toString() {
  final _this = this as ReferencePointDocument;
  return 'ReferencePointDocument(area: ${_this.area}, lat: ${_this.lat}, lon: ${_this.lon})';
}


}

/// @nodoc
abstract mixin class $ReferencePointDocumentCopyWith<$Res>  {
  factory $ReferencePointDocumentCopyWith(ReferencePointDocument value, $Res Function(ReferencePointDocument) _then) = _$ReferencePointDocumentCopyWithImpl;
@useResult
$Res call({
 String area, double lat, double lon
});




}
/// @nodoc
class _$ReferencePointDocumentCopyWithImpl<$Res>
    implements $ReferencePointDocumentCopyWith<$Res> {
  _$ReferencePointDocumentCopyWithImpl(this._self, this._then);

  final ReferencePointDocument _self;
  final $Res Function(ReferencePointDocument) _then;

/// Create a copy of ReferencePointDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? area = null,Object? lat = null,Object? lon = null,}) {
  return _then(ReferencePointDocument(
area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lon: null == lon ? _self.lon : lon // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ReferencePointDocument].
extension ReferencePointDocumentPatterns on ReferencePointDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReferencePointDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReferencePointDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReferencePointDocument value)  $default,){
final _that = this;
switch (_that) {
case _ReferencePointDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReferencePointDocument value)?  $default,){
final _that = this;
switch (_that) {
case _ReferencePointDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String area,  double lat,  double lon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReferencePointDocument() when $default != null:
return $default(_that.area,_that.lat,_that.lon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String area,  double lat,  double lon)  $default,) {final _that = this;
switch (_that) {
case _ReferencePointDocument():
return $default(_that.area,_that.lat,_that.lon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String area,  double lat,  double lon)?  $default,) {final _that = this;
switch (_that) {
case _ReferencePointDocument() when $default != null:
return $default(_that.area,_that.lat,_that.lon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReferencePointDocument implements ReferencePointDocument {
  const _ReferencePointDocument({required this.area, required this.lat, required this.lon});
  factory _ReferencePointDocument.fromJson(Map<String, dynamic> json) => _$ReferencePointDocumentFromJson(json);

/// ISO 3166-1 alpha-2 or ISO 3166-2 area code.
@override final  String area;
/// Latitude in degrees.
@override final  double lat;
/// Longitude in degrees.
@override final  double lon;

/// Create a copy of ReferencePointDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReferencePointDocumentCopyWith<_ReferencePointDocument> get copyWith => __$ReferencePointDocumentCopyWithImpl<_ReferencePointDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReferencePointDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReferencePointDocument&&(identical(other.area, area) || other.area == area)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lon, lon) || other.lon == lon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,area,lat,lon);
}

@override
String toString() {
    return 'ReferencePointDocument(area: $area, lat: $lat, lon: $lon)';
}


}

/// @nodoc
abstract mixin class _$ReferencePointDocumentCopyWith<$Res> implements $ReferencePointDocumentCopyWith<$Res> {
  factory _$ReferencePointDocumentCopyWith(_ReferencePointDocument value, $Res Function(_ReferencePointDocument) _then) = __$ReferencePointDocumentCopyWithImpl;
@override @useResult
$Res call({
 String area, double lat, double lon
});




}
/// @nodoc
class __$ReferencePointDocumentCopyWithImpl<$Res>
    implements _$ReferencePointDocumentCopyWith<$Res> {
  __$ReferencePointDocumentCopyWithImpl(this._self, this._then);

  final _ReferencePointDocument _self;
  final $Res Function(_ReferencePointDocument) _then;

/// Create a copy of ReferencePointDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? area = null,Object? lat = null,Object? lon = null,}) {
  return _then(_ReferencePointDocument(
area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lon: null == lon ? _self.lon : lon // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
