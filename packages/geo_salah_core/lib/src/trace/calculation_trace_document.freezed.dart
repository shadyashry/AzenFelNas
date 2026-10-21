// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calculation_trace_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalculationTraceDocument {

/// Schema version; 1.
 int get schemaVersion;/// `GS-` + 16 base32 characters (§6.4 ¶11).
 String get calculationId;/// Prayer day, `YYYY-MM-DD`.
 String get day;/// Calculation inputs.
 TraceInputsDocument get inputs;/// Provenance.
 TraceProvenanceDocument get provenance;/// Events of the day.
 List<TraceTimeDocument> get times;
/// Create a copy of CalculationTraceDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalculationTraceDocumentCopyWith<CalculationTraceDocument> get copyWith => _$CalculationTraceDocumentCopyWithImpl<CalculationTraceDocument>(this as CalculationTraceDocument, _$identity);

  /// Serializes this CalculationTraceDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CalculationTraceDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalculationTraceDocument&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.calculationId, _this.calculationId) || other.calculationId == _this.calculationId)&&(identical(other.day, _this.day) || other.day == _this.day)&&(identical(other.inputs, _this.inputs) || other.inputs == _this.inputs)&&(identical(other.provenance, _this.provenance) || other.provenance == _this.provenance)&&const DeepCollectionEquality().equals(other.times, _this.times));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CalculationTraceDocument;
  return Object.hash(runtimeType,_this.schemaVersion,_this.calculationId,_this.day,_this.inputs,_this.provenance,const DeepCollectionEquality().hash(_this.times));
}

@override
String toString() {
  final _this = this as CalculationTraceDocument;
  return 'CalculationTraceDocument(schemaVersion: ${_this.schemaVersion}, calculationId: ${_this.calculationId}, day: ${_this.day}, inputs: ${_this.inputs}, provenance: ${_this.provenance}, times: ${_this.times})';
}


}

/// @nodoc
abstract mixin class $CalculationTraceDocumentCopyWith<$Res>  {
  factory $CalculationTraceDocumentCopyWith(CalculationTraceDocument value, $Res Function(CalculationTraceDocument) _then) = _$CalculationTraceDocumentCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String calculationId, String day, TraceInputsDocument inputs, TraceProvenanceDocument provenance, List<TraceTimeDocument> times
});


$TraceInputsDocumentCopyWith<$Res> get inputs;$TraceProvenanceDocumentCopyWith<$Res> get provenance;

}
/// @nodoc
class _$CalculationTraceDocumentCopyWithImpl<$Res>
    implements $CalculationTraceDocumentCopyWith<$Res> {
  _$CalculationTraceDocumentCopyWithImpl(this._self, this._then);

  final CalculationTraceDocument _self;
  final $Res Function(CalculationTraceDocument) _then;

/// Create a copy of CalculationTraceDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? calculationId = null,Object? day = null,Object? inputs = null,Object? provenance = null,Object? times = null,}) {
  return _then(CalculationTraceDocument(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,calculationId: null == calculationId ? _self.calculationId : calculationId // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,inputs: null == inputs ? _self.inputs : inputs // ignore: cast_nullable_to_non_nullable
as TraceInputsDocument,provenance: null == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as TraceProvenanceDocument,times: null == times ? _self.times : times // ignore: cast_nullable_to_non_nullable
as List<TraceTimeDocument>,
  ));
}
/// Create a copy of CalculationTraceDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TraceInputsDocumentCopyWith<$Res> get inputs {
  
  return $TraceInputsDocumentCopyWith<$Res>(_self.inputs, (value) {
    return _then(_self.copyWith(inputs: value));
  });
}/// Create a copy of CalculationTraceDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TraceProvenanceDocumentCopyWith<$Res> get provenance {
  
  return $TraceProvenanceDocumentCopyWith<$Res>(_self.provenance, (value) {
    return _then(_self.copyWith(provenance: value));
  });
}
}


/// Adds pattern-matching-related methods to [CalculationTraceDocument].
extension CalculationTraceDocumentPatterns on CalculationTraceDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalculationTraceDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalculationTraceDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalculationTraceDocument value)  $default,){
final _that = this;
switch (_that) {
case _CalculationTraceDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalculationTraceDocument value)?  $default,){
final _that = this;
switch (_that) {
case _CalculationTraceDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String calculationId,  String day,  TraceInputsDocument inputs,  TraceProvenanceDocument provenance,  List<TraceTimeDocument> times)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalculationTraceDocument() when $default != null:
return $default(_that.schemaVersion,_that.calculationId,_that.day,_that.inputs,_that.provenance,_that.times);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String calculationId,  String day,  TraceInputsDocument inputs,  TraceProvenanceDocument provenance,  List<TraceTimeDocument> times)  $default,) {final _that = this;
switch (_that) {
case _CalculationTraceDocument():
return $default(_that.schemaVersion,_that.calculationId,_that.day,_that.inputs,_that.provenance,_that.times);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String calculationId,  String day,  TraceInputsDocument inputs,  TraceProvenanceDocument provenance,  List<TraceTimeDocument> times)?  $default,) {final _that = this;
switch (_that) {
case _CalculationTraceDocument() when $default != null:
return $default(_that.schemaVersion,_that.calculationId,_that.day,_that.inputs,_that.provenance,_that.times);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CalculationTraceDocument implements CalculationTraceDocument {
  const _CalculationTraceDocument({required this.schemaVersion, required this.calculationId, required this.day, required this.inputs, required this.provenance, required  List<TraceTimeDocument> times}): _times = times;
  factory _CalculationTraceDocument.fromJson(Map<String, dynamic> json) => _$CalculationTraceDocumentFromJson(json);

/// Schema version; 1.
@override final  int schemaVersion;
/// `GS-` + 16 base32 characters (§6.4 ¶11).
@override final  String calculationId;
/// Prayer day, `YYYY-MM-DD`.
@override final  String day;
/// Calculation inputs.
@override final  TraceInputsDocument inputs;
/// Provenance.
@override final  TraceProvenanceDocument provenance;
/// Events of the day.
 final  List<TraceTimeDocument> _times;
/// Events of the day.
@override List<TraceTimeDocument> get times {
  if (_times is EqualUnmodifiableListView) return _times;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_times);
}


/// Create a copy of CalculationTraceDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalculationTraceDocumentCopyWith<_CalculationTraceDocument> get copyWith => __$CalculationTraceDocumentCopyWithImpl<_CalculationTraceDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalculationTraceDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalculationTraceDocument&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.calculationId, calculationId) || other.calculationId == calculationId)&&(identical(other.day, day) || other.day == day)&&(identical(other.inputs, inputs) || other.inputs == inputs)&&(identical(other.provenance, provenance) || other.provenance == provenance)&&const DeepCollectionEquality().equals(other.times, _times));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,calculationId,day,inputs,provenance,const DeepCollectionEquality().hash(_times));
}

@override
String toString() {
    return 'CalculationTraceDocument(schemaVersion: $schemaVersion, calculationId: $calculationId, day: $day, inputs: $inputs, provenance: $provenance, times: $times)';
}


}

/// @nodoc
abstract mixin class _$CalculationTraceDocumentCopyWith<$Res> implements $CalculationTraceDocumentCopyWith<$Res> {
  factory _$CalculationTraceDocumentCopyWith(_CalculationTraceDocument value, $Res Function(_CalculationTraceDocument) _then) = __$CalculationTraceDocumentCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String calculationId, String day, TraceInputsDocument inputs, TraceProvenanceDocument provenance, List<TraceTimeDocument> times
});


@override $TraceInputsDocumentCopyWith<$Res> get inputs;@override $TraceProvenanceDocumentCopyWith<$Res> get provenance;

}
/// @nodoc
class __$CalculationTraceDocumentCopyWithImpl<$Res>
    implements _$CalculationTraceDocumentCopyWith<$Res> {
  __$CalculationTraceDocumentCopyWithImpl(this._self, this._then);

  final _CalculationTraceDocument _self;
  final $Res Function(_CalculationTraceDocument) _then;

/// Create a copy of CalculationTraceDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? calculationId = null,Object? day = null,Object? inputs = null,Object? provenance = null,Object? times = null,}) {
  return _then(_CalculationTraceDocument(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,calculationId: null == calculationId ? _self.calculationId : calculationId // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,inputs: null == inputs ? _self.inputs : inputs // ignore: cast_nullable_to_non_nullable
as TraceInputsDocument,provenance: null == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as TraceProvenanceDocument,times: null == times ? _self._times : times // ignore: cast_nullable_to_non_nullable
as List<TraceTimeDocument>,
  ));
}

/// Create a copy of CalculationTraceDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TraceInputsDocumentCopyWith<$Res> get inputs {
  
  return $TraceInputsDocumentCopyWith<$Res>(_self.inputs, (value) {
    return _then(_self.copyWith(inputs: value));
  });
}/// Create a copy of CalculationTraceDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TraceProvenanceDocumentCopyWith<$Res> get provenance {
  
  return $TraceProvenanceDocumentCopyWith<$Res>(_self.provenance, (value) {
    return _then(_self.copyWith(provenance: value));
  });
}
}

// dart format on
