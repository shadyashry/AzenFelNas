// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'elevation_sample_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ElevationSampleDocument {

/// Height in metres above [datum].
 double get valueM;/// Vertical datum.
 ElevationDatumCode get datum;/// How the value was obtained.
 ElevationSourceCode get source;/// When the value was observed, UTC epoch milliseconds.
 int get observedUtcMs;/// Vertical accuracy in metres.
 double? get verticalAccuracyM;/// Dataset version.
 String? get datasetVersion;
/// Create a copy of ElevationSampleDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ElevationSampleDocumentCopyWith<ElevationSampleDocument> get copyWith => _$ElevationSampleDocumentCopyWithImpl<ElevationSampleDocument>(this as ElevationSampleDocument, _$identity);

  /// Serializes this ElevationSampleDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ElevationSampleDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ElevationSampleDocument&&(identical(other.valueM, _this.valueM) || other.valueM == _this.valueM)&&(identical(other.datum, _this.datum) || other.datum == _this.datum)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.observedUtcMs, _this.observedUtcMs) || other.observedUtcMs == _this.observedUtcMs)&&(identical(other.verticalAccuracyM, _this.verticalAccuracyM) || other.verticalAccuracyM == _this.verticalAccuracyM)&&(identical(other.datasetVersion, _this.datasetVersion) || other.datasetVersion == _this.datasetVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ElevationSampleDocument;
  return Object.hash(runtimeType,_this.valueM,_this.datum,_this.source,_this.observedUtcMs,_this.verticalAccuracyM,_this.datasetVersion);
}

@override
String toString() {
  final _this = this as ElevationSampleDocument;
  return 'ElevationSampleDocument(valueM: ${_this.valueM}, datum: ${_this.datum}, source: ${_this.source}, observedUtcMs: ${_this.observedUtcMs}, verticalAccuracyM: ${_this.verticalAccuracyM}, datasetVersion: ${_this.datasetVersion})';
}


}

/// @nodoc
abstract mixin class $ElevationSampleDocumentCopyWith<$Res>  {
  factory $ElevationSampleDocumentCopyWith(ElevationSampleDocument value, $Res Function(ElevationSampleDocument) _then) = _$ElevationSampleDocumentCopyWithImpl;
@useResult
$Res call({
 double valueM, ElevationDatumCode datum, ElevationSourceCode source, int observedUtcMs, double? verticalAccuracyM, String? datasetVersion
});




}
/// @nodoc
class _$ElevationSampleDocumentCopyWithImpl<$Res>
    implements $ElevationSampleDocumentCopyWith<$Res> {
  _$ElevationSampleDocumentCopyWithImpl(this._self, this._then);

  final ElevationSampleDocument _self;
  final $Res Function(ElevationSampleDocument) _then;

/// Create a copy of ElevationSampleDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? valueM = null,Object? datum = null,Object? source = null,Object? observedUtcMs = null,Object? verticalAccuracyM = freezed,Object? datasetVersion = freezed,}) {
  return _then(ElevationSampleDocument(
valueM: null == valueM ? _self.valueM : valueM // ignore: cast_nullable_to_non_nullable
as double,datum: null == datum ? _self.datum : datum // ignore: cast_nullable_to_non_nullable
as ElevationDatumCode,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ElevationSourceCode,observedUtcMs: null == observedUtcMs ? _self.observedUtcMs : observedUtcMs // ignore: cast_nullable_to_non_nullable
as int,verticalAccuracyM: freezed == verticalAccuracyM ? _self.verticalAccuracyM : verticalAccuracyM // ignore: cast_nullable_to_non_nullable
as double?,datasetVersion: freezed == datasetVersion ? _self.datasetVersion : datasetVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ElevationSampleDocument].
extension ElevationSampleDocumentPatterns on ElevationSampleDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ElevationSampleDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ElevationSampleDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ElevationSampleDocument value)  $default,){
final _that = this;
switch (_that) {
case _ElevationSampleDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ElevationSampleDocument value)?  $default,){
final _that = this;
switch (_that) {
case _ElevationSampleDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double valueM,  ElevationDatumCode datum,  ElevationSourceCode source,  int observedUtcMs,  double? verticalAccuracyM,  String? datasetVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ElevationSampleDocument() when $default != null:
return $default(_that.valueM,_that.datum,_that.source,_that.observedUtcMs,_that.verticalAccuracyM,_that.datasetVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double valueM,  ElevationDatumCode datum,  ElevationSourceCode source,  int observedUtcMs,  double? verticalAccuracyM,  String? datasetVersion)  $default,) {final _that = this;
switch (_that) {
case _ElevationSampleDocument():
return $default(_that.valueM,_that.datum,_that.source,_that.observedUtcMs,_that.verticalAccuracyM,_that.datasetVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double valueM,  ElevationDatumCode datum,  ElevationSourceCode source,  int observedUtcMs,  double? verticalAccuracyM,  String? datasetVersion)?  $default,) {final _that = this;
switch (_that) {
case _ElevationSampleDocument() when $default != null:
return $default(_that.valueM,_that.datum,_that.source,_that.observedUtcMs,_that.verticalAccuracyM,_that.datasetVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ElevationSampleDocument implements ElevationSampleDocument {
  const _ElevationSampleDocument({required this.valueM, required this.datum, required this.source, required this.observedUtcMs, this.verticalAccuracyM, this.datasetVersion});
  factory _ElevationSampleDocument.fromJson(Map<String, dynamic> json) => _$ElevationSampleDocumentFromJson(json);

/// Height in metres above [datum].
@override final  double valueM;
/// Vertical datum.
@override final  ElevationDatumCode datum;
/// How the value was obtained.
@override final  ElevationSourceCode source;
/// When the value was observed, UTC epoch milliseconds.
@override final  int observedUtcMs;
/// Vertical accuracy in metres.
@override final  double? verticalAccuracyM;
/// Dataset version.
@override final  String? datasetVersion;

/// Create a copy of ElevationSampleDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ElevationSampleDocumentCopyWith<_ElevationSampleDocument> get copyWith => __$ElevationSampleDocumentCopyWithImpl<_ElevationSampleDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ElevationSampleDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ElevationSampleDocument&&(identical(other.valueM, valueM) || other.valueM == valueM)&&(identical(other.datum, datum) || other.datum == datum)&&(identical(other.source, source) || other.source == source)&&(identical(other.observedUtcMs, observedUtcMs) || other.observedUtcMs == observedUtcMs)&&(identical(other.verticalAccuracyM, verticalAccuracyM) || other.verticalAccuracyM == verticalAccuracyM)&&(identical(other.datasetVersion, datasetVersion) || other.datasetVersion == datasetVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,valueM,datum,source,observedUtcMs,verticalAccuracyM,datasetVersion);
}

@override
String toString() {
    return 'ElevationSampleDocument(valueM: $valueM, datum: $datum, source: $source, observedUtcMs: $observedUtcMs, verticalAccuracyM: $verticalAccuracyM, datasetVersion: $datasetVersion)';
}


}

/// @nodoc
abstract mixin class _$ElevationSampleDocumentCopyWith<$Res> implements $ElevationSampleDocumentCopyWith<$Res> {
  factory _$ElevationSampleDocumentCopyWith(_ElevationSampleDocument value, $Res Function(_ElevationSampleDocument) _then) = __$ElevationSampleDocumentCopyWithImpl;
@override @useResult
$Res call({
 double valueM, ElevationDatumCode datum, ElevationSourceCode source, int observedUtcMs, double? verticalAccuracyM, String? datasetVersion
});




}
/// @nodoc
class __$ElevationSampleDocumentCopyWithImpl<$Res>
    implements _$ElevationSampleDocumentCopyWith<$Res> {
  __$ElevationSampleDocumentCopyWithImpl(this._self, this._then);

  final _ElevationSampleDocument _self;
  final $Res Function(_ElevationSampleDocument) _then;

/// Create a copy of ElevationSampleDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? valueM = null,Object? datum = null,Object? source = null,Object? observedUtcMs = null,Object? verticalAccuracyM = freezed,Object? datasetVersion = freezed,}) {
  return _then(_ElevationSampleDocument(
valueM: null == valueM ? _self.valueM : valueM // ignore: cast_nullable_to_non_nullable
as double,datum: null == datum ? _self.datum : datum // ignore: cast_nullable_to_non_nullable
as ElevationDatumCode,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ElevationSourceCode,observedUtcMs: null == observedUtcMs ? _self.observedUtcMs : observedUtcMs // ignore: cast_nullable_to_non_nullable
as int,verticalAccuracyM: freezed == verticalAccuracyM ? _self.verticalAccuracyM : verticalAccuracyM // ignore: cast_nullable_to_non_nullable
as double?,datasetVersion: freezed == datasetVersion ? _self.datasetVersion : datasetVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
