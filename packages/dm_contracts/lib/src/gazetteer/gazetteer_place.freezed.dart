// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gazetteer_place.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GazetteerPlace {

/// GeoNames id.
 int get id;/// Name.
 String get name;/// ASCII name.
 String get asciiName;/// Alternate names.
 GazetteerAltNames get altNames;/// ISO 3166-1 alpha-2.
 String get country;/// Admin-1 code; empty when unknown.
 String get admin1;/// Latitude.
 double get lat;/// Longitude.
 double get lon;/// Population.
 int get population;/// IANA zone.
 String get zoneId;
/// Create a copy of GazetteerPlace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GazetteerPlaceCopyWith<GazetteerPlace> get copyWith => _$GazetteerPlaceCopyWithImpl<GazetteerPlace>(this as GazetteerPlace, _$identity);

  /// Serializes this GazetteerPlace to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GazetteerPlace;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GazetteerPlace&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.asciiName, _this.asciiName) || other.asciiName == _this.asciiName)&&(identical(other.altNames, _this.altNames) || other.altNames == _this.altNames)&&(identical(other.country, _this.country) || other.country == _this.country)&&(identical(other.admin1, _this.admin1) || other.admin1 == _this.admin1)&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lon, _this.lon) || other.lon == _this.lon)&&(identical(other.population, _this.population) || other.population == _this.population)&&(identical(other.zoneId, _this.zoneId) || other.zoneId == _this.zoneId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GazetteerPlace;
  return Object.hash(runtimeType,_this.id,_this.name,_this.asciiName,_this.altNames,_this.country,_this.admin1,_this.lat,_this.lon,_this.population,_this.zoneId);
}

@override
String toString() {
  final _this = this as GazetteerPlace;
  return 'GazetteerPlace(id: ${_this.id}, name: ${_this.name}, asciiName: ${_this.asciiName}, altNames: ${_this.altNames}, country: ${_this.country}, admin1: ${_this.admin1}, lat: ${_this.lat}, lon: ${_this.lon}, population: ${_this.population}, zoneId: ${_this.zoneId})';
}


}

/// @nodoc
abstract mixin class $GazetteerPlaceCopyWith<$Res>  {
  factory $GazetteerPlaceCopyWith(GazetteerPlace value, $Res Function(GazetteerPlace) _then) = _$GazetteerPlaceCopyWithImpl;
@useResult
$Res call({
 int id, String name, String asciiName, GazetteerAltNames altNames, String country, String admin1, double lat, double lon, int population, String zoneId
});


$GazetteerAltNamesCopyWith<$Res> get altNames;

}
/// @nodoc
class _$GazetteerPlaceCopyWithImpl<$Res>
    implements $GazetteerPlaceCopyWith<$Res> {
  _$GazetteerPlaceCopyWithImpl(this._self, this._then);

  final GazetteerPlace _self;
  final $Res Function(GazetteerPlace) _then;

/// Create a copy of GazetteerPlace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? asciiName = null,Object? altNames = null,Object? country = null,Object? admin1 = null,Object? lat = null,Object? lon = null,Object? population = null,Object? zoneId = null,}) {
  return _then(GazetteerPlace(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,asciiName: null == asciiName ? _self.asciiName : asciiName // ignore: cast_nullable_to_non_nullable
as String,altNames: null == altNames ? _self.altNames : altNames // ignore: cast_nullable_to_non_nullable
as GazetteerAltNames,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,admin1: null == admin1 ? _self.admin1 : admin1 // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lon: null == lon ? _self.lon : lon // ignore: cast_nullable_to_non_nullable
as double,population: null == population ? _self.population : population // ignore: cast_nullable_to_non_nullable
as int,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of GazetteerPlace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GazetteerAltNamesCopyWith<$Res> get altNames {
  
  return $GazetteerAltNamesCopyWith<$Res>(_self.altNames, (value) {
    return _then(_self.copyWith(altNames: value));
  });
}
}


/// Adds pattern-matching-related methods to [GazetteerPlace].
extension GazetteerPlacePatterns on GazetteerPlace {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GazetteerPlace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GazetteerPlace() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GazetteerPlace value)  $default,){
final _that = this;
switch (_that) {
case _GazetteerPlace():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GazetteerPlace value)?  $default,){
final _that = this;
switch (_that) {
case _GazetteerPlace() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String asciiName,  GazetteerAltNames altNames,  String country,  String admin1,  double lat,  double lon,  int population,  String zoneId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GazetteerPlace() when $default != null:
return $default(_that.id,_that.name,_that.asciiName,_that.altNames,_that.country,_that.admin1,_that.lat,_that.lon,_that.population,_that.zoneId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String asciiName,  GazetteerAltNames altNames,  String country,  String admin1,  double lat,  double lon,  int population,  String zoneId)  $default,) {final _that = this;
switch (_that) {
case _GazetteerPlace():
return $default(_that.id,_that.name,_that.asciiName,_that.altNames,_that.country,_that.admin1,_that.lat,_that.lon,_that.population,_that.zoneId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String asciiName,  GazetteerAltNames altNames,  String country,  String admin1,  double lat,  double lon,  int population,  String zoneId)?  $default,) {final _that = this;
switch (_that) {
case _GazetteerPlace() when $default != null:
return $default(_that.id,_that.name,_that.asciiName,_that.altNames,_that.country,_that.admin1,_that.lat,_that.lon,_that.population,_that.zoneId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GazetteerPlace implements GazetteerPlace {
  const _GazetteerPlace({required this.id, required this.name, required this.asciiName, required this.altNames, required this.country, required this.admin1, required this.lat, required this.lon, required this.population, required this.zoneId});
  factory _GazetteerPlace.fromJson(Map<String, dynamic> json) => _$GazetteerPlaceFromJson(json);

/// GeoNames id.
@override final  int id;
/// Name.
@override final  String name;
/// ASCII name.
@override final  String asciiName;
/// Alternate names.
@override final  GazetteerAltNames altNames;
/// ISO 3166-1 alpha-2.
@override final  String country;
/// Admin-1 code; empty when unknown.
@override final  String admin1;
/// Latitude.
@override final  double lat;
/// Longitude.
@override final  double lon;
/// Population.
@override final  int population;
/// IANA zone.
@override final  String zoneId;

/// Create a copy of GazetteerPlace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GazetteerPlaceCopyWith<_GazetteerPlace> get copyWith => __$GazetteerPlaceCopyWithImpl<_GazetteerPlace>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GazetteerPlaceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GazetteerPlace&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.asciiName, asciiName) || other.asciiName == asciiName)&&(identical(other.altNames, altNames) || other.altNames == altNames)&&(identical(other.country, country) || other.country == country)&&(identical(other.admin1, admin1) || other.admin1 == admin1)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lon, lon) || other.lon == lon)&&(identical(other.population, population) || other.population == population)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,asciiName,altNames,country,admin1,lat,lon,population,zoneId);
}

@override
String toString() {
    return 'GazetteerPlace(id: $id, name: $name, asciiName: $asciiName, altNames: $altNames, country: $country, admin1: $admin1, lat: $lat, lon: $lon, population: $population, zoneId: $zoneId)';
}


}

/// @nodoc
abstract mixin class _$GazetteerPlaceCopyWith<$Res> implements $GazetteerPlaceCopyWith<$Res> {
  factory _$GazetteerPlaceCopyWith(_GazetteerPlace value, $Res Function(_GazetteerPlace) _then) = __$GazetteerPlaceCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String asciiName, GazetteerAltNames altNames, String country, String admin1, double lat, double lon, int population, String zoneId
});


@override $GazetteerAltNamesCopyWith<$Res> get altNames;

}
/// @nodoc
class __$GazetteerPlaceCopyWithImpl<$Res>
    implements _$GazetteerPlaceCopyWith<$Res> {
  __$GazetteerPlaceCopyWithImpl(this._self, this._then);

  final _GazetteerPlace _self;
  final $Res Function(_GazetteerPlace) _then;

/// Create a copy of GazetteerPlace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? asciiName = null,Object? altNames = null,Object? country = null,Object? admin1 = null,Object? lat = null,Object? lon = null,Object? population = null,Object? zoneId = null,}) {
  return _then(_GazetteerPlace(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,asciiName: null == asciiName ? _self.asciiName : asciiName // ignore: cast_nullable_to_non_nullable
as String,altNames: null == altNames ? _self.altNames : altNames // ignore: cast_nullable_to_non_nullable
as GazetteerAltNames,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,admin1: null == admin1 ? _self.admin1 : admin1 // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lon: null == lon ? _self.lon : lon // ignore: cast_nullable_to_non_nullable
as double,population: null == population ? _self.population : population // ignore: cast_nullable_to_non_nullable
as int,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of GazetteerPlace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GazetteerAltNamesCopyWith<$Res> get altNames {
  
  return $GazetteerAltNamesCopyWith<$Res>(_self.altNames, (value) {
    return _then(_self.copyWith(altNames: value));
  });
}
}

// dart format on
