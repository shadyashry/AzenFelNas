// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bench_observer_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BenchObserverDocument {

/// Latitude, degrees north.
 double get latitudeDeg;/// Longitude, degrees east.
 double get longitudeDeg;/// IANA zone id.
 String get zoneId;/// Where the position came from.
 ObserverSourceCode get source;/// Horizontal accuracy in metres.
 double? get horizontalAccuracyM;/// Elevation (provenance only, ADR-003).
 ElevationSampleDocument? get elevation;
/// Create a copy of BenchObserverDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenchObserverDocumentCopyWith<BenchObserverDocument> get copyWith => _$BenchObserverDocumentCopyWithImpl<BenchObserverDocument>(this as BenchObserverDocument, _$identity);

  /// Serializes this BenchObserverDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BenchObserverDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BenchObserverDocument&&(identical(other.latitudeDeg, _this.latitudeDeg) || other.latitudeDeg == _this.latitudeDeg)&&(identical(other.longitudeDeg, _this.longitudeDeg) || other.longitudeDeg == _this.longitudeDeg)&&(identical(other.zoneId, _this.zoneId) || other.zoneId == _this.zoneId)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.horizontalAccuracyM, _this.horizontalAccuracyM) || other.horizontalAccuracyM == _this.horizontalAccuracyM)&&(identical(other.elevation, _this.elevation) || other.elevation == _this.elevation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BenchObserverDocument;
  return Object.hash(runtimeType,_this.latitudeDeg,_this.longitudeDeg,_this.zoneId,_this.source,_this.horizontalAccuracyM,_this.elevation);
}

@override
String toString() {
  final _this = this as BenchObserverDocument;
  return 'BenchObserverDocument(latitudeDeg: ${_this.latitudeDeg}, longitudeDeg: ${_this.longitudeDeg}, zoneId: ${_this.zoneId}, source: ${_this.source}, horizontalAccuracyM: ${_this.horizontalAccuracyM}, elevation: ${_this.elevation})';
}


}

/// @nodoc
abstract mixin class $BenchObserverDocumentCopyWith<$Res>  {
  factory $BenchObserverDocumentCopyWith(BenchObserverDocument value, $Res Function(BenchObserverDocument) _then) = _$BenchObserverDocumentCopyWithImpl;
@useResult
$Res call({
 double latitudeDeg, double longitudeDeg, String zoneId, ObserverSourceCode source, double? horizontalAccuracyM, ElevationSampleDocument? elevation
});


$ElevationSampleDocumentCopyWith<$Res>? get elevation;

}
/// @nodoc
class _$BenchObserverDocumentCopyWithImpl<$Res>
    implements $BenchObserverDocumentCopyWith<$Res> {
  _$BenchObserverDocumentCopyWithImpl(this._self, this._then);

  final BenchObserverDocument _self;
  final $Res Function(BenchObserverDocument) _then;

/// Create a copy of BenchObserverDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitudeDeg = null,Object? longitudeDeg = null,Object? zoneId = null,Object? source = null,Object? horizontalAccuracyM = freezed,Object? elevation = freezed,}) {
  return _then(BenchObserverDocument(
latitudeDeg: null == latitudeDeg ? _self.latitudeDeg : latitudeDeg // ignore: cast_nullable_to_non_nullable
as double,longitudeDeg: null == longitudeDeg ? _self.longitudeDeg : longitudeDeg // ignore: cast_nullable_to_non_nullable
as double,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ObserverSourceCode,horizontalAccuracyM: freezed == horizontalAccuracyM ? _self.horizontalAccuracyM : horizontalAccuracyM // ignore: cast_nullable_to_non_nullable
as double?,elevation: freezed == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as ElevationSampleDocument?,
  ));
}
/// Create a copy of BenchObserverDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ElevationSampleDocumentCopyWith<$Res>? get elevation {
    if (_self.elevation == null) {
    return null;
  }

  return $ElevationSampleDocumentCopyWith<$Res>(_self.elevation!, (value) {
    return _then(_self.copyWith(elevation: value));
  });
}
}


/// Adds pattern-matching-related methods to [BenchObserverDocument].
extension BenchObserverDocumentPatterns on BenchObserverDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BenchObserverDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BenchObserverDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BenchObserverDocument value)  $default,){
final _that = this;
switch (_that) {
case _BenchObserverDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BenchObserverDocument value)?  $default,){
final _that = this;
switch (_that) {
case _BenchObserverDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitudeDeg,  double longitudeDeg,  String zoneId,  ObserverSourceCode source,  double? horizontalAccuracyM,  ElevationSampleDocument? elevation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BenchObserverDocument() when $default != null:
return $default(_that.latitudeDeg,_that.longitudeDeg,_that.zoneId,_that.source,_that.horizontalAccuracyM,_that.elevation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitudeDeg,  double longitudeDeg,  String zoneId,  ObserverSourceCode source,  double? horizontalAccuracyM,  ElevationSampleDocument? elevation)  $default,) {final _that = this;
switch (_that) {
case _BenchObserverDocument():
return $default(_that.latitudeDeg,_that.longitudeDeg,_that.zoneId,_that.source,_that.horizontalAccuracyM,_that.elevation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitudeDeg,  double longitudeDeg,  String zoneId,  ObserverSourceCode source,  double? horizontalAccuracyM,  ElevationSampleDocument? elevation)?  $default,) {final _that = this;
switch (_that) {
case _BenchObserverDocument() when $default != null:
return $default(_that.latitudeDeg,_that.longitudeDeg,_that.zoneId,_that.source,_that.horizontalAccuracyM,_that.elevation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BenchObserverDocument implements BenchObserverDocument {
  const _BenchObserverDocument({required this.latitudeDeg, required this.longitudeDeg, required this.zoneId, required this.source, this.horizontalAccuracyM, this.elevation});
  factory _BenchObserverDocument.fromJson(Map<String, dynamic> json) => _$BenchObserverDocumentFromJson(json);

/// Latitude, degrees north.
@override final  double latitudeDeg;
/// Longitude, degrees east.
@override final  double longitudeDeg;
/// IANA zone id.
@override final  String zoneId;
/// Where the position came from.
@override final  ObserverSourceCode source;
/// Horizontal accuracy in metres.
@override final  double? horizontalAccuracyM;
/// Elevation (provenance only, ADR-003).
@override final  ElevationSampleDocument? elevation;

/// Create a copy of BenchObserverDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BenchObserverDocumentCopyWith<_BenchObserverDocument> get copyWith => __$BenchObserverDocumentCopyWithImpl<_BenchObserverDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BenchObserverDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BenchObserverDocument&&(identical(other.latitudeDeg, latitudeDeg) || other.latitudeDeg == latitudeDeg)&&(identical(other.longitudeDeg, longitudeDeg) || other.longitudeDeg == longitudeDeg)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.source, source) || other.source == source)&&(identical(other.horizontalAccuracyM, horizontalAccuracyM) || other.horizontalAccuracyM == horizontalAccuracyM)&&(identical(other.elevation, elevation) || other.elevation == elevation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,latitudeDeg,longitudeDeg,zoneId,source,horizontalAccuracyM,elevation);
}

@override
String toString() {
    return 'BenchObserverDocument(latitudeDeg: $latitudeDeg, longitudeDeg: $longitudeDeg, zoneId: $zoneId, source: $source, horizontalAccuracyM: $horizontalAccuracyM, elevation: $elevation)';
}


}

/// @nodoc
abstract mixin class _$BenchObserverDocumentCopyWith<$Res> implements $BenchObserverDocumentCopyWith<$Res> {
  factory _$BenchObserverDocumentCopyWith(_BenchObserverDocument value, $Res Function(_BenchObserverDocument) _then) = __$BenchObserverDocumentCopyWithImpl;
@override @useResult
$Res call({
 double latitudeDeg, double longitudeDeg, String zoneId, ObserverSourceCode source, double? horizontalAccuracyM, ElevationSampleDocument? elevation
});


@override $ElevationSampleDocumentCopyWith<$Res>? get elevation;

}
/// @nodoc
class __$BenchObserverDocumentCopyWithImpl<$Res>
    implements _$BenchObserverDocumentCopyWith<$Res> {
  __$BenchObserverDocumentCopyWithImpl(this._self, this._then);

  final _BenchObserverDocument _self;
  final $Res Function(_BenchObserverDocument) _then;

/// Create a copy of BenchObserverDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitudeDeg = null,Object? longitudeDeg = null,Object? zoneId = null,Object? source = null,Object? horizontalAccuracyM = freezed,Object? elevation = freezed,}) {
  return _then(_BenchObserverDocument(
latitudeDeg: null == latitudeDeg ? _self.latitudeDeg : latitudeDeg // ignore: cast_nullable_to_non_nullable
as double,longitudeDeg: null == longitudeDeg ? _self.longitudeDeg : longitudeDeg // ignore: cast_nullable_to_non_nullable
as double,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ObserverSourceCode,horizontalAccuracyM: freezed == horizontalAccuracyM ? _self.horizontalAccuracyM : horizontalAccuracyM // ignore: cast_nullable_to_non_nullable
as double?,elevation: freezed == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as ElevationSampleDocument?,
  ));
}

/// Create a copy of BenchObserverDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ElevationSampleDocumentCopyWith<$Res>? get elevation {
    if (_self.elevation == null) {
    return null;
  }

  return $ElevationSampleDocumentCopyWith<$Res>(_self.elevation!, (value) {
    return _then(_self.copyWith(elevation: value));
  });
}
}

// dart format on
