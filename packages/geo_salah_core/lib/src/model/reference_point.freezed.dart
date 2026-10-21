// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reference_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReferencePoint {

/// ISO 3166-1 alpha-2 (MVP) or ISO 3166-2 area code.
 String get area;/// Geodetic latitude, degrees north.
 double get lat;/// Longitude, degrees east.
 double get lon;
/// Create a copy of ReferencePoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReferencePointCopyWith<ReferencePoint> get copyWith => _$ReferencePointCopyWithImpl<ReferencePoint>(this as ReferencePoint, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReferencePoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReferencePoint&&(identical(other.area, _this.area) || other.area == _this.area)&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lon, _this.lon) || other.lon == _this.lon));
}


@override
int get hashCode {
  final _this = this as ReferencePoint;
  return Object.hash(runtimeType,_this.area,_this.lat,_this.lon);
}

@override
String toString() {
  final _this = this as ReferencePoint;
  return 'ReferencePoint(area: ${_this.area}, lat: ${_this.lat}, lon: ${_this.lon})';
}


}

/// @nodoc
abstract mixin class $ReferencePointCopyWith<$Res>  {
  factory $ReferencePointCopyWith(ReferencePoint value, $Res Function(ReferencePoint) _then) = _$ReferencePointCopyWithImpl;
@useResult
$Res call({
 String area, double lat, double lon
});




}
/// @nodoc
class _$ReferencePointCopyWithImpl<$Res>
    implements $ReferencePointCopyWith<$Res> {
  _$ReferencePointCopyWithImpl(this._self, this._then);

  final ReferencePoint _self;
  final $Res Function(ReferencePoint) _then;

/// Create a copy of ReferencePoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? area = null,Object? lat = null,Object? lon = null,}) {
  return _then(ReferencePoint(
area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lon: null == lon ? _self.lon : lon // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ReferencePoint].
extension ReferencePointPatterns on ReferencePoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReferencePoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReferencePoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReferencePoint value)  $default,){
final _that = this;
switch (_that) {
case _ReferencePoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReferencePoint value)?  $default,){
final _that = this;
switch (_that) {
case _ReferencePoint() when $default != null:
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
case _ReferencePoint() when $default != null:
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
case _ReferencePoint():
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
case _ReferencePoint() when $default != null:
return $default(_that.area,_that.lat,_that.lon);case _:
  return null;

}
}

}

/// @nodoc


class _ReferencePoint implements ReferencePoint {
  const _ReferencePoint({required this.area, required this.lat, required this.lon});
  

/// ISO 3166-1 alpha-2 (MVP) or ISO 3166-2 area code.
@override final  String area;
/// Geodetic latitude, degrees north.
@override final  double lat;
/// Longitude, degrees east.
@override final  double lon;

/// Create a copy of ReferencePoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReferencePointCopyWith<_ReferencePoint> get copyWith => __$ReferencePointCopyWithImpl<_ReferencePoint>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReferencePoint&&(identical(other.area, area) || other.area == area)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lon, lon) || other.lon == lon));
}


@override
int get hashCode {
    return Object.hash(runtimeType,area,lat,lon);
}

@override
String toString() {
    return 'ReferencePoint(area: $area, lat: $lat, lon: $lon)';
}


}

/// @nodoc
abstract mixin class _$ReferencePointCopyWith<$Res> implements $ReferencePointCopyWith<$Res> {
  factory _$ReferencePointCopyWith(_ReferencePoint value, $Res Function(_ReferencePoint) _then) = __$ReferencePointCopyWithImpl;
@override @useResult
$Res call({
 String area, double lat, double lon
});




}
/// @nodoc
class __$ReferencePointCopyWithImpl<$Res>
    implements _$ReferencePointCopyWith<$Res> {
  __$ReferencePointCopyWithImpl(this._self, this._then);

  final _ReferencePoint _self;
  final $Res Function(_ReferencePoint) _then;

/// Create a copy of ReferencePoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? area = null,Object? lat = null,Object? lon = null,}) {
  return _then(_ReferencePoint(
area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lon: null == lon ? _self.lon : lon // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
