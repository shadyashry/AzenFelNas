// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trace_provenance_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TraceProvenanceDocument {

/// Engine version.
 String get engineVersion;/// ΔT model id.
 String get deltaTModel;/// Prayer profile id.
 String get profileId;/// Prayer profile version.
 String get profileVersion;/// Pinned TZDB version.
 String get tzdbVersion;/// Lowercase hex SHA-256 of the canonical inputs.
 String get inputsHash;/// Hijri confidence of the day.
 HijriConfidenceCode get hijriConfidence;
/// Create a copy of TraceProvenanceDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TraceProvenanceDocumentCopyWith<TraceProvenanceDocument> get copyWith => _$TraceProvenanceDocumentCopyWithImpl<TraceProvenanceDocument>(this as TraceProvenanceDocument, _$identity);

  /// Serializes this TraceProvenanceDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TraceProvenanceDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TraceProvenanceDocument&&(identical(other.engineVersion, _this.engineVersion) || other.engineVersion == _this.engineVersion)&&(identical(other.deltaTModel, _this.deltaTModel) || other.deltaTModel == _this.deltaTModel)&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.profileVersion, _this.profileVersion) || other.profileVersion == _this.profileVersion)&&(identical(other.tzdbVersion, _this.tzdbVersion) || other.tzdbVersion == _this.tzdbVersion)&&(identical(other.inputsHash, _this.inputsHash) || other.inputsHash == _this.inputsHash)&&(identical(other.hijriConfidence, _this.hijriConfidence) || other.hijriConfidence == _this.hijriConfidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TraceProvenanceDocument;
  return Object.hash(runtimeType,_this.engineVersion,_this.deltaTModel,_this.profileId,_this.profileVersion,_this.tzdbVersion,_this.inputsHash,_this.hijriConfidence);
}

@override
String toString() {
  final _this = this as TraceProvenanceDocument;
  return 'TraceProvenanceDocument(engineVersion: ${_this.engineVersion}, deltaTModel: ${_this.deltaTModel}, profileId: ${_this.profileId}, profileVersion: ${_this.profileVersion}, tzdbVersion: ${_this.tzdbVersion}, inputsHash: ${_this.inputsHash}, hijriConfidence: ${_this.hijriConfidence})';
}


}

/// @nodoc
abstract mixin class $TraceProvenanceDocumentCopyWith<$Res>  {
  factory $TraceProvenanceDocumentCopyWith(TraceProvenanceDocument value, $Res Function(TraceProvenanceDocument) _then) = _$TraceProvenanceDocumentCopyWithImpl;
@useResult
$Res call({
 String engineVersion, String deltaTModel, String profileId, String profileVersion, String tzdbVersion, String inputsHash, HijriConfidenceCode hijriConfidence
});




}
/// @nodoc
class _$TraceProvenanceDocumentCopyWithImpl<$Res>
    implements $TraceProvenanceDocumentCopyWith<$Res> {
  _$TraceProvenanceDocumentCopyWithImpl(this._self, this._then);

  final TraceProvenanceDocument _self;
  final $Res Function(TraceProvenanceDocument) _then;

/// Create a copy of TraceProvenanceDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? engineVersion = null,Object? deltaTModel = null,Object? profileId = null,Object? profileVersion = null,Object? tzdbVersion = null,Object? inputsHash = null,Object? hijriConfidence = null,}) {
  return _then(TraceProvenanceDocument(
engineVersion: null == engineVersion ? _self.engineVersion : engineVersion // ignore: cast_nullable_to_non_nullable
as String,deltaTModel: null == deltaTModel ? _self.deltaTModel : deltaTModel // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,profileVersion: null == profileVersion ? _self.profileVersion : profileVersion // ignore: cast_nullable_to_non_nullable
as String,tzdbVersion: null == tzdbVersion ? _self.tzdbVersion : tzdbVersion // ignore: cast_nullable_to_non_nullable
as String,inputsHash: null == inputsHash ? _self.inputsHash : inputsHash // ignore: cast_nullable_to_non_nullable
as String,hijriConfidence: null == hijriConfidence ? _self.hijriConfidence : hijriConfidence // ignore: cast_nullable_to_non_nullable
as HijriConfidenceCode,
  ));
}

}


/// Adds pattern-matching-related methods to [TraceProvenanceDocument].
extension TraceProvenanceDocumentPatterns on TraceProvenanceDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TraceProvenanceDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TraceProvenanceDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TraceProvenanceDocument value)  $default,){
final _that = this;
switch (_that) {
case _TraceProvenanceDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TraceProvenanceDocument value)?  $default,){
final _that = this;
switch (_that) {
case _TraceProvenanceDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String engineVersion,  String deltaTModel,  String profileId,  String profileVersion,  String tzdbVersion,  String inputsHash,  HijriConfidenceCode hijriConfidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TraceProvenanceDocument() when $default != null:
return $default(_that.engineVersion,_that.deltaTModel,_that.profileId,_that.profileVersion,_that.tzdbVersion,_that.inputsHash,_that.hijriConfidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String engineVersion,  String deltaTModel,  String profileId,  String profileVersion,  String tzdbVersion,  String inputsHash,  HijriConfidenceCode hijriConfidence)  $default,) {final _that = this;
switch (_that) {
case _TraceProvenanceDocument():
return $default(_that.engineVersion,_that.deltaTModel,_that.profileId,_that.profileVersion,_that.tzdbVersion,_that.inputsHash,_that.hijriConfidence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String engineVersion,  String deltaTModel,  String profileId,  String profileVersion,  String tzdbVersion,  String inputsHash,  HijriConfidenceCode hijriConfidence)?  $default,) {final _that = this;
switch (_that) {
case _TraceProvenanceDocument() when $default != null:
return $default(_that.engineVersion,_that.deltaTModel,_that.profileId,_that.profileVersion,_that.tzdbVersion,_that.inputsHash,_that.hijriConfidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TraceProvenanceDocument implements TraceProvenanceDocument {
  const _TraceProvenanceDocument({required this.engineVersion, required this.deltaTModel, required this.profileId, required this.profileVersion, required this.tzdbVersion, required this.inputsHash, required this.hijriConfidence});
  factory _TraceProvenanceDocument.fromJson(Map<String, dynamic> json) => _$TraceProvenanceDocumentFromJson(json);

/// Engine version.
@override final  String engineVersion;
/// ΔT model id.
@override final  String deltaTModel;
/// Prayer profile id.
@override final  String profileId;
/// Prayer profile version.
@override final  String profileVersion;
/// Pinned TZDB version.
@override final  String tzdbVersion;
/// Lowercase hex SHA-256 of the canonical inputs.
@override final  String inputsHash;
/// Hijri confidence of the day.
@override final  HijriConfidenceCode hijriConfidence;

/// Create a copy of TraceProvenanceDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TraceProvenanceDocumentCopyWith<_TraceProvenanceDocument> get copyWith => __$TraceProvenanceDocumentCopyWithImpl<_TraceProvenanceDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TraceProvenanceDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TraceProvenanceDocument&&(identical(other.engineVersion, engineVersion) || other.engineVersion == engineVersion)&&(identical(other.deltaTModel, deltaTModel) || other.deltaTModel == deltaTModel)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.profileVersion, profileVersion) || other.profileVersion == profileVersion)&&(identical(other.tzdbVersion, tzdbVersion) || other.tzdbVersion == tzdbVersion)&&(identical(other.inputsHash, inputsHash) || other.inputsHash == inputsHash)&&(identical(other.hijriConfidence, hijriConfidence) || other.hijriConfidence == hijriConfidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,engineVersion,deltaTModel,profileId,profileVersion,tzdbVersion,inputsHash,hijriConfidence);
}

@override
String toString() {
    return 'TraceProvenanceDocument(engineVersion: $engineVersion, deltaTModel: $deltaTModel, profileId: $profileId, profileVersion: $profileVersion, tzdbVersion: $tzdbVersion, inputsHash: $inputsHash, hijriConfidence: $hijriConfidence)';
}


}

/// @nodoc
abstract mixin class _$TraceProvenanceDocumentCopyWith<$Res> implements $TraceProvenanceDocumentCopyWith<$Res> {
  factory _$TraceProvenanceDocumentCopyWith(_TraceProvenanceDocument value, $Res Function(_TraceProvenanceDocument) _then) = __$TraceProvenanceDocumentCopyWithImpl;
@override @useResult
$Res call({
 String engineVersion, String deltaTModel, String profileId, String profileVersion, String tzdbVersion, String inputsHash, HijriConfidenceCode hijriConfidence
});




}
/// @nodoc
class __$TraceProvenanceDocumentCopyWithImpl<$Res>
    implements _$TraceProvenanceDocumentCopyWith<$Res> {
  __$TraceProvenanceDocumentCopyWithImpl(this._self, this._then);

  final _TraceProvenanceDocument _self;
  final $Res Function(_TraceProvenanceDocument) _then;

/// Create a copy of TraceProvenanceDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? engineVersion = null,Object? deltaTModel = null,Object? profileId = null,Object? profileVersion = null,Object? tzdbVersion = null,Object? inputsHash = null,Object? hijriConfidence = null,}) {
  return _then(_TraceProvenanceDocument(
engineVersion: null == engineVersion ? _self.engineVersion : engineVersion // ignore: cast_nullable_to_non_nullable
as String,deltaTModel: null == deltaTModel ? _self.deltaTModel : deltaTModel // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,profileVersion: null == profileVersion ? _self.profileVersion : profileVersion // ignore: cast_nullable_to_non_nullable
as String,tzdbVersion: null == tzdbVersion ? _self.tzdbVersion : tzdbVersion // ignore: cast_nullable_to_non_nullable
as String,inputsHash: null == inputsHash ? _self.inputsHash : inputsHash // ignore: cast_nullable_to_non_nullable
as String,hijriConfidence: null == hijriConfidence ? _self.hijriConfidence : hijriConfidence // ignore: cast_nullable_to_non_nullable
as HijriConfidenceCode,
  ));
}


}

// dart format on
