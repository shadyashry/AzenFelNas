// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trace_hijri_inputs_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TraceHijriInputsDocument {

/// Hijri date governing Imsak/Fajr of the prayer day.
 HijriDateDocument get dateAtDawn;/// Hijri date governing Isha of the prayer day.
 HijriDateDocument get dateAtNight;/// How the Hijri dates were obtained.
 HijriConfidenceCode get confidence;
/// Create a copy of TraceHijriInputsDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TraceHijriInputsDocumentCopyWith<TraceHijriInputsDocument> get copyWith => _$TraceHijriInputsDocumentCopyWithImpl<TraceHijriInputsDocument>(this as TraceHijriInputsDocument, _$identity);

  /// Serializes this TraceHijriInputsDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TraceHijriInputsDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TraceHijriInputsDocument&&(identical(other.dateAtDawn, _this.dateAtDawn) || other.dateAtDawn == _this.dateAtDawn)&&(identical(other.dateAtNight, _this.dateAtNight) || other.dateAtNight == _this.dateAtNight)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TraceHijriInputsDocument;
  return Object.hash(runtimeType,_this.dateAtDawn,_this.dateAtNight,_this.confidence);
}

@override
String toString() {
  final _this = this as TraceHijriInputsDocument;
  return 'TraceHijriInputsDocument(dateAtDawn: ${_this.dateAtDawn}, dateAtNight: ${_this.dateAtNight}, confidence: ${_this.confidence})';
}


}

/// @nodoc
abstract mixin class $TraceHijriInputsDocumentCopyWith<$Res>  {
  factory $TraceHijriInputsDocumentCopyWith(TraceHijriInputsDocument value, $Res Function(TraceHijriInputsDocument) _then) = _$TraceHijriInputsDocumentCopyWithImpl;
@useResult
$Res call({
 HijriDateDocument dateAtDawn, HijriDateDocument dateAtNight, HijriConfidenceCode confidence
});


$HijriDateDocumentCopyWith<$Res> get dateAtDawn;$HijriDateDocumentCopyWith<$Res> get dateAtNight;

}
/// @nodoc
class _$TraceHijriInputsDocumentCopyWithImpl<$Res>
    implements $TraceHijriInputsDocumentCopyWith<$Res> {
  _$TraceHijriInputsDocumentCopyWithImpl(this._self, this._then);

  final TraceHijriInputsDocument _self;
  final $Res Function(TraceHijriInputsDocument) _then;

/// Create a copy of TraceHijriInputsDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateAtDawn = null,Object? dateAtNight = null,Object? confidence = null,}) {
  return _then(TraceHijriInputsDocument(
dateAtDawn: null == dateAtDawn ? _self.dateAtDawn : dateAtDawn // ignore: cast_nullable_to_non_nullable
as HijriDateDocument,dateAtNight: null == dateAtNight ? _self.dateAtNight : dateAtNight // ignore: cast_nullable_to_non_nullable
as HijriDateDocument,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as HijriConfidenceCode,
  ));
}
/// Create a copy of TraceHijriInputsDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HijriDateDocumentCopyWith<$Res> get dateAtDawn {
  
  return $HijriDateDocumentCopyWith<$Res>(_self.dateAtDawn, (value) {
    return _then(_self.copyWith(dateAtDawn: value));
  });
}/// Create a copy of TraceHijriInputsDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HijriDateDocumentCopyWith<$Res> get dateAtNight {
  
  return $HijriDateDocumentCopyWith<$Res>(_self.dateAtNight, (value) {
    return _then(_self.copyWith(dateAtNight: value));
  });
}
}


/// Adds pattern-matching-related methods to [TraceHijriInputsDocument].
extension TraceHijriInputsDocumentPatterns on TraceHijriInputsDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TraceHijriInputsDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TraceHijriInputsDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TraceHijriInputsDocument value)  $default,){
final _that = this;
switch (_that) {
case _TraceHijriInputsDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TraceHijriInputsDocument value)?  $default,){
final _that = this;
switch (_that) {
case _TraceHijriInputsDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HijriDateDocument dateAtDawn,  HijriDateDocument dateAtNight,  HijriConfidenceCode confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TraceHijriInputsDocument() when $default != null:
return $default(_that.dateAtDawn,_that.dateAtNight,_that.confidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HijriDateDocument dateAtDawn,  HijriDateDocument dateAtNight,  HijriConfidenceCode confidence)  $default,) {final _that = this;
switch (_that) {
case _TraceHijriInputsDocument():
return $default(_that.dateAtDawn,_that.dateAtNight,_that.confidence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HijriDateDocument dateAtDawn,  HijriDateDocument dateAtNight,  HijriConfidenceCode confidence)?  $default,) {final _that = this;
switch (_that) {
case _TraceHijriInputsDocument() when $default != null:
return $default(_that.dateAtDawn,_that.dateAtNight,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TraceHijriInputsDocument implements TraceHijriInputsDocument {
  const _TraceHijriInputsDocument({required this.dateAtDawn, required this.dateAtNight, required this.confidence});
  factory _TraceHijriInputsDocument.fromJson(Map<String, dynamic> json) => _$TraceHijriInputsDocumentFromJson(json);

/// Hijri date governing Imsak/Fajr of the prayer day.
@override final  HijriDateDocument dateAtDawn;
/// Hijri date governing Isha of the prayer day.
@override final  HijriDateDocument dateAtNight;
/// How the Hijri dates were obtained.
@override final  HijriConfidenceCode confidence;

/// Create a copy of TraceHijriInputsDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TraceHijriInputsDocumentCopyWith<_TraceHijriInputsDocument> get copyWith => __$TraceHijriInputsDocumentCopyWithImpl<_TraceHijriInputsDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TraceHijriInputsDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TraceHijriInputsDocument&&(identical(other.dateAtDawn, dateAtDawn) || other.dateAtDawn == dateAtDawn)&&(identical(other.dateAtNight, dateAtNight) || other.dateAtNight == dateAtNight)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,dateAtDawn,dateAtNight,confidence);
}

@override
String toString() {
    return 'TraceHijriInputsDocument(dateAtDawn: $dateAtDawn, dateAtNight: $dateAtNight, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$TraceHijriInputsDocumentCopyWith<$Res> implements $TraceHijriInputsDocumentCopyWith<$Res> {
  factory _$TraceHijriInputsDocumentCopyWith(_TraceHijriInputsDocument value, $Res Function(_TraceHijriInputsDocument) _then) = __$TraceHijriInputsDocumentCopyWithImpl;
@override @useResult
$Res call({
 HijriDateDocument dateAtDawn, HijriDateDocument dateAtNight, HijriConfidenceCode confidence
});


@override $HijriDateDocumentCopyWith<$Res> get dateAtDawn;@override $HijriDateDocumentCopyWith<$Res> get dateAtNight;

}
/// @nodoc
class __$TraceHijriInputsDocumentCopyWithImpl<$Res>
    implements _$TraceHijriInputsDocumentCopyWith<$Res> {
  __$TraceHijriInputsDocumentCopyWithImpl(this._self, this._then);

  final _TraceHijriInputsDocument _self;
  final $Res Function(_TraceHijriInputsDocument) _then;

/// Create a copy of TraceHijriInputsDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateAtDawn = null,Object? dateAtNight = null,Object? confidence = null,}) {
  return _then(_TraceHijriInputsDocument(
dateAtDawn: null == dateAtDawn ? _self.dateAtDawn : dateAtDawn // ignore: cast_nullable_to_non_nullable
as HijriDateDocument,dateAtNight: null == dateAtNight ? _self.dateAtNight : dateAtNight // ignore: cast_nullable_to_non_nullable
as HijriDateDocument,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as HijriConfidenceCode,
  ));
}

/// Create a copy of TraceHijriInputsDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HijriDateDocumentCopyWith<$Res> get dateAtDawn {
  
  return $HijriDateDocumentCopyWith<$Res>(_self.dateAtDawn, (value) {
    return _then(_self.copyWith(dateAtDawn: value));
  });
}/// Create a copy of TraceHijriInputsDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HijriDateDocumentCopyWith<$Res> get dateAtNight {
  
  return $HijriDateDocumentCopyWith<$Res>(_self.dateAtNight, (value) {
    return _then(_self.copyWith(dateAtNight: value));
  });
}
}

// dart format on
