// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trace_inputs_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TraceInputsDocument {

/// Latitude, rounded to 6 decimals.
 double get lat;/// Longitude, rounded to 6 decimals.
 double get lon;/// IANA zone id of the observer.
 String get zoneId;/// Prayer day, `YYYY-MM-DD`.
 String get day;/// Prayer profile id.
 String get profileId;/// Prayer profile version.
 String get profileVersion;/// Hijri state of the day.
 TraceHijriInputsDocument get hijri;
/// Create a copy of TraceInputsDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TraceInputsDocumentCopyWith<TraceInputsDocument> get copyWith => _$TraceInputsDocumentCopyWithImpl<TraceInputsDocument>(this as TraceInputsDocument, _$identity);

  /// Serializes this TraceInputsDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TraceInputsDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TraceInputsDocument&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lon, _this.lon) || other.lon == _this.lon)&&(identical(other.zoneId, _this.zoneId) || other.zoneId == _this.zoneId)&&(identical(other.day, _this.day) || other.day == _this.day)&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.profileVersion, _this.profileVersion) || other.profileVersion == _this.profileVersion)&&(identical(other.hijri, _this.hijri) || other.hijri == _this.hijri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TraceInputsDocument;
  return Object.hash(runtimeType,_this.lat,_this.lon,_this.zoneId,_this.day,_this.profileId,_this.profileVersion,_this.hijri);
}

@override
String toString() {
  final _this = this as TraceInputsDocument;
  return 'TraceInputsDocument(lat: ${_this.lat}, lon: ${_this.lon}, zoneId: ${_this.zoneId}, day: ${_this.day}, profileId: ${_this.profileId}, profileVersion: ${_this.profileVersion}, hijri: ${_this.hijri})';
}


}

/// @nodoc
abstract mixin class $TraceInputsDocumentCopyWith<$Res>  {
  factory $TraceInputsDocumentCopyWith(TraceInputsDocument value, $Res Function(TraceInputsDocument) _then) = _$TraceInputsDocumentCopyWithImpl;
@useResult
$Res call({
 double lat, double lon, String zoneId, String day, String profileId, String profileVersion, TraceHijriInputsDocument hijri
});


$TraceHijriInputsDocumentCopyWith<$Res> get hijri;

}
/// @nodoc
class _$TraceInputsDocumentCopyWithImpl<$Res>
    implements $TraceInputsDocumentCopyWith<$Res> {
  _$TraceInputsDocumentCopyWithImpl(this._self, this._then);

  final TraceInputsDocument _self;
  final $Res Function(TraceInputsDocument) _then;

/// Create a copy of TraceInputsDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lat = null,Object? lon = null,Object? zoneId = null,Object? day = null,Object? profileId = null,Object? profileVersion = null,Object? hijri = null,}) {
  return _then(TraceInputsDocument(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lon: null == lon ? _self.lon : lon // ignore: cast_nullable_to_non_nullable
as double,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,profileVersion: null == profileVersion ? _self.profileVersion : profileVersion // ignore: cast_nullable_to_non_nullable
as String,hijri: null == hijri ? _self.hijri : hijri // ignore: cast_nullable_to_non_nullable
as TraceHijriInputsDocument,
  ));
}
/// Create a copy of TraceInputsDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TraceHijriInputsDocumentCopyWith<$Res> get hijri {
  
  return $TraceHijriInputsDocumentCopyWith<$Res>(_self.hijri, (value) {
    return _then(_self.copyWith(hijri: value));
  });
}
}


/// Adds pattern-matching-related methods to [TraceInputsDocument].
extension TraceInputsDocumentPatterns on TraceInputsDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TraceInputsDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TraceInputsDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TraceInputsDocument value)  $default,){
final _that = this;
switch (_that) {
case _TraceInputsDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TraceInputsDocument value)?  $default,){
final _that = this;
switch (_that) {
case _TraceInputsDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double lat,  double lon,  String zoneId,  String day,  String profileId,  String profileVersion,  TraceHijriInputsDocument hijri)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TraceInputsDocument() when $default != null:
return $default(_that.lat,_that.lon,_that.zoneId,_that.day,_that.profileId,_that.profileVersion,_that.hijri);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double lat,  double lon,  String zoneId,  String day,  String profileId,  String profileVersion,  TraceHijriInputsDocument hijri)  $default,) {final _that = this;
switch (_that) {
case _TraceInputsDocument():
return $default(_that.lat,_that.lon,_that.zoneId,_that.day,_that.profileId,_that.profileVersion,_that.hijri);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double lat,  double lon,  String zoneId,  String day,  String profileId,  String profileVersion,  TraceHijriInputsDocument hijri)?  $default,) {final _that = this;
switch (_that) {
case _TraceInputsDocument() when $default != null:
return $default(_that.lat,_that.lon,_that.zoneId,_that.day,_that.profileId,_that.profileVersion,_that.hijri);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TraceInputsDocument implements TraceInputsDocument {
  const _TraceInputsDocument({required this.lat, required this.lon, required this.zoneId, required this.day, required this.profileId, required this.profileVersion, required this.hijri});
  factory _TraceInputsDocument.fromJson(Map<String, dynamic> json) => _$TraceInputsDocumentFromJson(json);

/// Latitude, rounded to 6 decimals.
@override final  double lat;
/// Longitude, rounded to 6 decimals.
@override final  double lon;
/// IANA zone id of the observer.
@override final  String zoneId;
/// Prayer day, `YYYY-MM-DD`.
@override final  String day;
/// Prayer profile id.
@override final  String profileId;
/// Prayer profile version.
@override final  String profileVersion;
/// Hijri state of the day.
@override final  TraceHijriInputsDocument hijri;

/// Create a copy of TraceInputsDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TraceInputsDocumentCopyWith<_TraceInputsDocument> get copyWith => __$TraceInputsDocumentCopyWithImpl<_TraceInputsDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TraceInputsDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TraceInputsDocument&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lon, lon) || other.lon == lon)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.day, day) || other.day == day)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.profileVersion, profileVersion) || other.profileVersion == profileVersion)&&(identical(other.hijri, hijri) || other.hijri == hijri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lat,lon,zoneId,day,profileId,profileVersion,hijri);
}

@override
String toString() {
    return 'TraceInputsDocument(lat: $lat, lon: $lon, zoneId: $zoneId, day: $day, profileId: $profileId, profileVersion: $profileVersion, hijri: $hijri)';
}


}

/// @nodoc
abstract mixin class _$TraceInputsDocumentCopyWith<$Res> implements $TraceInputsDocumentCopyWith<$Res> {
  factory _$TraceInputsDocumentCopyWith(_TraceInputsDocument value, $Res Function(_TraceInputsDocument) _then) = __$TraceInputsDocumentCopyWithImpl;
@override @useResult
$Res call({
 double lat, double lon, String zoneId, String day, String profileId, String profileVersion, TraceHijriInputsDocument hijri
});


@override $TraceHijriInputsDocumentCopyWith<$Res> get hijri;

}
/// @nodoc
class __$TraceInputsDocumentCopyWithImpl<$Res>
    implements _$TraceInputsDocumentCopyWith<$Res> {
  __$TraceInputsDocumentCopyWithImpl(this._self, this._then);

  final _TraceInputsDocument _self;
  final $Res Function(_TraceInputsDocument) _then;

/// Create a copy of TraceInputsDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lat = null,Object? lon = null,Object? zoneId = null,Object? day = null,Object? profileId = null,Object? profileVersion = null,Object? hijri = null,}) {
  return _then(_TraceInputsDocument(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lon: null == lon ? _self.lon : lon // ignore: cast_nullable_to_non_nullable
as double,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,profileVersion: null == profileVersion ? _self.profileVersion : profileVersion // ignore: cast_nullable_to_non_nullable
as String,hijri: null == hijri ? _self.hijri : hijri // ignore: cast_nullable_to_non_nullable
as TraceHijriInputsDocument,
  ));
}

/// Create a copy of TraceInputsDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TraceHijriInputsDocumentCopyWith<$Res> get hijri {
  
  return $TraceHijriInputsDocumentCopyWith<$Res>(_self.hijri, (value) {
    return _then(_self.copyWith(hijri: value));
  });
}
}

// dart format on
