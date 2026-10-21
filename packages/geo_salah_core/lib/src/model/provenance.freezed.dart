// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provenance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Provenance {

/// Engine version, `MAJOR.MINOR.PATCH`.
 String get engineVersion;/// ΔT model id, e.g. `espenak-meeus-2006` (ADR-019).
 String get deltaTModel;/// Prayer profile id.
 String get profileId;/// Prayer profile version.
 String get profileVersion;/// Version of the TZDB the local dates were derived with (REQ-TIME-020).
 String get tzdbVersion;/// Lowercase hex SHA-256 of the canonical calculation inputs.
 String get inputsHash;/// How the day's Hijri dates were obtained.
 HijriConfidence get hijriConfidence;/// Adjustments applied after the rules, in order.
 List<AdjustmentStep> get adjustmentTrace;
/// Create a copy of Provenance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProvenanceCopyWith<Provenance> get copyWith => _$ProvenanceCopyWithImpl<Provenance>(this as Provenance, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Provenance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Provenance&&(identical(other.engineVersion, _this.engineVersion) || other.engineVersion == _this.engineVersion)&&(identical(other.deltaTModel, _this.deltaTModel) || other.deltaTModel == _this.deltaTModel)&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.profileVersion, _this.profileVersion) || other.profileVersion == _this.profileVersion)&&(identical(other.tzdbVersion, _this.tzdbVersion) || other.tzdbVersion == _this.tzdbVersion)&&(identical(other.inputsHash, _this.inputsHash) || other.inputsHash == _this.inputsHash)&&(identical(other.hijriConfidence, _this.hijriConfidence) || other.hijriConfidence == _this.hijriConfidence)&&const DeepCollectionEquality().equals(other.adjustmentTrace, _this.adjustmentTrace));
}


@override
int get hashCode {
  final _this = this as Provenance;
  return Object.hash(runtimeType,_this.engineVersion,_this.deltaTModel,_this.profileId,_this.profileVersion,_this.tzdbVersion,_this.inputsHash,_this.hijriConfidence,const DeepCollectionEquality().hash(_this.adjustmentTrace));
}

@override
String toString() {
  final _this = this as Provenance;
  return 'Provenance(engineVersion: ${_this.engineVersion}, deltaTModel: ${_this.deltaTModel}, profileId: ${_this.profileId}, profileVersion: ${_this.profileVersion}, tzdbVersion: ${_this.tzdbVersion}, inputsHash: ${_this.inputsHash}, hijriConfidence: ${_this.hijriConfidence}, adjustmentTrace: ${_this.adjustmentTrace})';
}


}

/// @nodoc
abstract mixin class $ProvenanceCopyWith<$Res>  {
  factory $ProvenanceCopyWith(Provenance value, $Res Function(Provenance) _then) = _$ProvenanceCopyWithImpl;
@useResult
$Res call({
 String engineVersion, String deltaTModel, String profileId, String profileVersion, String tzdbVersion, String inputsHash, HijriConfidence hijriConfidence, List<AdjustmentStep> adjustmentTrace
});




}
/// @nodoc
class _$ProvenanceCopyWithImpl<$Res>
    implements $ProvenanceCopyWith<$Res> {
  _$ProvenanceCopyWithImpl(this._self, this._then);

  final Provenance _self;
  final $Res Function(Provenance) _then;

/// Create a copy of Provenance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? engineVersion = null,Object? deltaTModel = null,Object? profileId = null,Object? profileVersion = null,Object? tzdbVersion = null,Object? inputsHash = null,Object? hijriConfidence = null,Object? adjustmentTrace = null,}) {
  return _then(Provenance(
engineVersion: null == engineVersion ? _self.engineVersion : engineVersion // ignore: cast_nullable_to_non_nullable
as String,deltaTModel: null == deltaTModel ? _self.deltaTModel : deltaTModel // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,profileVersion: null == profileVersion ? _self.profileVersion : profileVersion // ignore: cast_nullable_to_non_nullable
as String,tzdbVersion: null == tzdbVersion ? _self.tzdbVersion : tzdbVersion // ignore: cast_nullable_to_non_nullable
as String,inputsHash: null == inputsHash ? _self.inputsHash : inputsHash // ignore: cast_nullable_to_non_nullable
as String,hijriConfidence: null == hijriConfidence ? _self.hijriConfidence : hijriConfidence // ignore: cast_nullable_to_non_nullable
as HijriConfidence,adjustmentTrace: null == adjustmentTrace ? _self.adjustmentTrace : adjustmentTrace // ignore: cast_nullable_to_non_nullable
as List<AdjustmentStep>,
  ));
}

}


/// Adds pattern-matching-related methods to [Provenance].
extension ProvenancePatterns on Provenance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Provenance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Provenance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Provenance value)  $default,){
final _that = this;
switch (_that) {
case _Provenance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Provenance value)?  $default,){
final _that = this;
switch (_that) {
case _Provenance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String engineVersion,  String deltaTModel,  String profileId,  String profileVersion,  String tzdbVersion,  String inputsHash,  HijriConfidence hijriConfidence,  List<AdjustmentStep> adjustmentTrace)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Provenance() when $default != null:
return $default(_that.engineVersion,_that.deltaTModel,_that.profileId,_that.profileVersion,_that.tzdbVersion,_that.inputsHash,_that.hijriConfidence,_that.adjustmentTrace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String engineVersion,  String deltaTModel,  String profileId,  String profileVersion,  String tzdbVersion,  String inputsHash,  HijriConfidence hijriConfidence,  List<AdjustmentStep> adjustmentTrace)  $default,) {final _that = this;
switch (_that) {
case _Provenance():
return $default(_that.engineVersion,_that.deltaTModel,_that.profileId,_that.profileVersion,_that.tzdbVersion,_that.inputsHash,_that.hijriConfidence,_that.adjustmentTrace);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String engineVersion,  String deltaTModel,  String profileId,  String profileVersion,  String tzdbVersion,  String inputsHash,  HijriConfidence hijriConfidence,  List<AdjustmentStep> adjustmentTrace)?  $default,) {final _that = this;
switch (_that) {
case _Provenance() when $default != null:
return $default(_that.engineVersion,_that.deltaTModel,_that.profileId,_that.profileVersion,_that.tzdbVersion,_that.inputsHash,_that.hijriConfidence,_that.adjustmentTrace);case _:
  return null;

}
}

}

/// @nodoc


class _Provenance implements Provenance {
  const _Provenance({required this.engineVersion, required this.deltaTModel, required this.profileId, required this.profileVersion, required this.tzdbVersion, required this.inputsHash, required this.hijriConfidence, required  List<AdjustmentStep> adjustmentTrace}): _adjustmentTrace = adjustmentTrace;
  

/// Engine version, `MAJOR.MINOR.PATCH`.
@override final  String engineVersion;
/// ΔT model id, e.g. `espenak-meeus-2006` (ADR-019).
@override final  String deltaTModel;
/// Prayer profile id.
@override final  String profileId;
/// Prayer profile version.
@override final  String profileVersion;
/// Version of the TZDB the local dates were derived with (REQ-TIME-020).
@override final  String tzdbVersion;
/// Lowercase hex SHA-256 of the canonical calculation inputs.
@override final  String inputsHash;
/// How the day's Hijri dates were obtained.
@override final  HijriConfidence hijriConfidence;
/// Adjustments applied after the rules, in order.
 final  List<AdjustmentStep> _adjustmentTrace;
/// Adjustments applied after the rules, in order.
@override List<AdjustmentStep> get adjustmentTrace {
  if (_adjustmentTrace is EqualUnmodifiableListView) return _adjustmentTrace;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_adjustmentTrace);
}


/// Create a copy of Provenance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProvenanceCopyWith<_Provenance> get copyWith => __$ProvenanceCopyWithImpl<_Provenance>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Provenance&&(identical(other.engineVersion, engineVersion) || other.engineVersion == engineVersion)&&(identical(other.deltaTModel, deltaTModel) || other.deltaTModel == deltaTModel)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.profileVersion, profileVersion) || other.profileVersion == profileVersion)&&(identical(other.tzdbVersion, tzdbVersion) || other.tzdbVersion == tzdbVersion)&&(identical(other.inputsHash, inputsHash) || other.inputsHash == inputsHash)&&(identical(other.hijriConfidence, hijriConfidence) || other.hijriConfidence == hijriConfidence)&&const DeepCollectionEquality().equals(other.adjustmentTrace, _adjustmentTrace));
}


@override
int get hashCode {
    return Object.hash(runtimeType,engineVersion,deltaTModel,profileId,profileVersion,tzdbVersion,inputsHash,hijriConfidence,const DeepCollectionEquality().hash(_adjustmentTrace));
}

@override
String toString() {
    return 'Provenance(engineVersion: $engineVersion, deltaTModel: $deltaTModel, profileId: $profileId, profileVersion: $profileVersion, tzdbVersion: $tzdbVersion, inputsHash: $inputsHash, hijriConfidence: $hijriConfidence, adjustmentTrace: $adjustmentTrace)';
}


}

/// @nodoc
abstract mixin class _$ProvenanceCopyWith<$Res> implements $ProvenanceCopyWith<$Res> {
  factory _$ProvenanceCopyWith(_Provenance value, $Res Function(_Provenance) _then) = __$ProvenanceCopyWithImpl;
@override @useResult
$Res call({
 String engineVersion, String deltaTModel, String profileId, String profileVersion, String tzdbVersion, String inputsHash, HijriConfidence hijriConfidence, List<AdjustmentStep> adjustmentTrace
});




}
/// @nodoc
class __$ProvenanceCopyWithImpl<$Res>
    implements _$ProvenanceCopyWith<$Res> {
  __$ProvenanceCopyWithImpl(this._self, this._then);

  final _Provenance _self;
  final $Res Function(_Provenance) _then;

/// Create a copy of Provenance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? engineVersion = null,Object? deltaTModel = null,Object? profileId = null,Object? profileVersion = null,Object? tzdbVersion = null,Object? inputsHash = null,Object? hijriConfidence = null,Object? adjustmentTrace = null,}) {
  return _then(_Provenance(
engineVersion: null == engineVersion ? _self.engineVersion : engineVersion // ignore: cast_nullable_to_non_nullable
as String,deltaTModel: null == deltaTModel ? _self.deltaTModel : deltaTModel // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,profileVersion: null == profileVersion ? _self.profileVersion : profileVersion // ignore: cast_nullable_to_non_nullable
as String,tzdbVersion: null == tzdbVersion ? _self.tzdbVersion : tzdbVersion // ignore: cast_nullable_to_non_nullable
as String,inputsHash: null == inputsHash ? _self.inputsHash : inputsHash // ignore: cast_nullable_to_non_nullable
as String,hijriConfidence: null == hijriConfidence ? _self.hijriConfidence : hijriConfidence // ignore: cast_nullable_to_non_nullable
as HijriConfidence,adjustmentTrace: null == adjustmentTrace ? _self._adjustmentTrace : adjustmentTrace // ignore: cast_nullable_to_non_nullable
as List<AdjustmentStep>,
  ));
}


}

// dart format on
