// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trace_time_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TraceTimeDocument {

/// The event.
 PrayerEventCode get event;/// How the time was obtained (REQ-DOM-002).
 EventOriginDocument get origin;/// Confidence label (REQ-DOM-010).
 ConfidenceLabelDocument get confidence;/// Result flags.
 List<ResultFlagCode> get flags;/// Adjustments applied to this event, in order.
 List<AdjustmentStepDocument> get adjustmentTrace;/// Raw instant, truncated to 1 ms (REQ-DOM-004).
 int? get rawUtcMs;/// Displayed instant after rounding (REQ-DOM-003).
 int? get displayedUtcMs;/// Local-date offset from the prayer day, −1…1.
 int? get dayOffset;
/// Create a copy of TraceTimeDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TraceTimeDocumentCopyWith<TraceTimeDocument> get copyWith => _$TraceTimeDocumentCopyWithImpl<TraceTimeDocument>(this as TraceTimeDocument, _$identity);

  /// Serializes this TraceTimeDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TraceTimeDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TraceTimeDocument&&(identical(other.event, _this.event) || other.event == _this.event)&&(identical(other.origin, _this.origin) || other.origin == _this.origin)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&const DeepCollectionEquality().equals(other.flags, _this.flags)&&const DeepCollectionEquality().equals(other.adjustmentTrace, _this.adjustmentTrace)&&(identical(other.rawUtcMs, _this.rawUtcMs) || other.rawUtcMs == _this.rawUtcMs)&&(identical(other.displayedUtcMs, _this.displayedUtcMs) || other.displayedUtcMs == _this.displayedUtcMs)&&(identical(other.dayOffset, _this.dayOffset) || other.dayOffset == _this.dayOffset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TraceTimeDocument;
  return Object.hash(runtimeType,_this.event,_this.origin,_this.confidence,const DeepCollectionEquality().hash(_this.flags),const DeepCollectionEquality().hash(_this.adjustmentTrace),_this.rawUtcMs,_this.displayedUtcMs,_this.dayOffset);
}

@override
String toString() {
  final _this = this as TraceTimeDocument;
  return 'TraceTimeDocument(event: ${_this.event}, origin: ${_this.origin}, confidence: ${_this.confidence}, flags: ${_this.flags}, adjustmentTrace: ${_this.adjustmentTrace}, rawUtcMs: ${_this.rawUtcMs}, displayedUtcMs: ${_this.displayedUtcMs}, dayOffset: ${_this.dayOffset})';
}


}

/// @nodoc
abstract mixin class $TraceTimeDocumentCopyWith<$Res>  {
  factory $TraceTimeDocumentCopyWith(TraceTimeDocument value, $Res Function(TraceTimeDocument) _then) = _$TraceTimeDocumentCopyWithImpl;
@useResult
$Res call({
 PrayerEventCode event, EventOriginDocument origin, ConfidenceLabelDocument confidence, List<ResultFlagCode> flags, List<AdjustmentStepDocument> adjustmentTrace, int? rawUtcMs, int? displayedUtcMs, int? dayOffset
});


$EventOriginDocumentCopyWith<$Res> get origin;$ConfidenceLabelDocumentCopyWith<$Res> get confidence;

}
/// @nodoc
class _$TraceTimeDocumentCopyWithImpl<$Res>
    implements $TraceTimeDocumentCopyWith<$Res> {
  _$TraceTimeDocumentCopyWithImpl(this._self, this._then);

  final TraceTimeDocument _self;
  final $Res Function(TraceTimeDocument) _then;

/// Create a copy of TraceTimeDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? event = null,Object? origin = null,Object? confidence = null,Object? flags = null,Object? adjustmentTrace = null,Object? rawUtcMs = freezed,Object? displayedUtcMs = freezed,Object? dayOffset = freezed,}) {
  return _then(TraceTimeDocument(
event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as PrayerEventCode,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as EventOriginDocument,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as ConfidenceLabelDocument,flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as List<ResultFlagCode>,adjustmentTrace: null == adjustmentTrace ? _self.adjustmentTrace : adjustmentTrace // ignore: cast_nullable_to_non_nullable
as List<AdjustmentStepDocument>,rawUtcMs: freezed == rawUtcMs ? _self.rawUtcMs : rawUtcMs // ignore: cast_nullable_to_non_nullable
as int?,displayedUtcMs: freezed == displayedUtcMs ? _self.displayedUtcMs : displayedUtcMs // ignore: cast_nullable_to_non_nullable
as int?,dayOffset: freezed == dayOffset ? _self.dayOffset : dayOffset // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of TraceTimeDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventOriginDocumentCopyWith<$Res> get origin {
  
  return $EventOriginDocumentCopyWith<$Res>(_self.origin, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of TraceTimeDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfidenceLabelDocumentCopyWith<$Res> get confidence {
  
  return $ConfidenceLabelDocumentCopyWith<$Res>(_self.confidence, (value) {
    return _then(_self.copyWith(confidence: value));
  });
}
}


/// Adds pattern-matching-related methods to [TraceTimeDocument].
extension TraceTimeDocumentPatterns on TraceTimeDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TraceTimeDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TraceTimeDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TraceTimeDocument value)  $default,){
final _that = this;
switch (_that) {
case _TraceTimeDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TraceTimeDocument value)?  $default,){
final _that = this;
switch (_that) {
case _TraceTimeDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PrayerEventCode event,  EventOriginDocument origin,  ConfidenceLabelDocument confidence,  List<ResultFlagCode> flags,  List<AdjustmentStepDocument> adjustmentTrace,  int? rawUtcMs,  int? displayedUtcMs,  int? dayOffset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TraceTimeDocument() when $default != null:
return $default(_that.event,_that.origin,_that.confidence,_that.flags,_that.adjustmentTrace,_that.rawUtcMs,_that.displayedUtcMs,_that.dayOffset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PrayerEventCode event,  EventOriginDocument origin,  ConfidenceLabelDocument confidence,  List<ResultFlagCode> flags,  List<AdjustmentStepDocument> adjustmentTrace,  int? rawUtcMs,  int? displayedUtcMs,  int? dayOffset)  $default,) {final _that = this;
switch (_that) {
case _TraceTimeDocument():
return $default(_that.event,_that.origin,_that.confidence,_that.flags,_that.adjustmentTrace,_that.rawUtcMs,_that.displayedUtcMs,_that.dayOffset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PrayerEventCode event,  EventOriginDocument origin,  ConfidenceLabelDocument confidence,  List<ResultFlagCode> flags,  List<AdjustmentStepDocument> adjustmentTrace,  int? rawUtcMs,  int? displayedUtcMs,  int? dayOffset)?  $default,) {final _that = this;
switch (_that) {
case _TraceTimeDocument() when $default != null:
return $default(_that.event,_that.origin,_that.confidence,_that.flags,_that.adjustmentTrace,_that.rawUtcMs,_that.displayedUtcMs,_that.dayOffset);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TraceTimeDocument implements TraceTimeDocument {
  const _TraceTimeDocument({required this.event, required this.origin, required this.confidence, required  List<ResultFlagCode> flags, required  List<AdjustmentStepDocument> adjustmentTrace, this.rawUtcMs, this.displayedUtcMs, this.dayOffset}): _flags = flags,_adjustmentTrace = adjustmentTrace;
  factory _TraceTimeDocument.fromJson(Map<String, dynamic> json) => _$TraceTimeDocumentFromJson(json);

/// The event.
@override final  PrayerEventCode event;
/// How the time was obtained (REQ-DOM-002).
@override final  EventOriginDocument origin;
/// Confidence label (REQ-DOM-010).
@override final  ConfidenceLabelDocument confidence;
/// Result flags.
 final  List<ResultFlagCode> _flags;
/// Result flags.
@override List<ResultFlagCode> get flags {
  if (_flags is EqualUnmodifiableListView) return _flags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_flags);
}

/// Adjustments applied to this event, in order.
 final  List<AdjustmentStepDocument> _adjustmentTrace;
/// Adjustments applied to this event, in order.
@override List<AdjustmentStepDocument> get adjustmentTrace {
  if (_adjustmentTrace is EqualUnmodifiableListView) return _adjustmentTrace;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_adjustmentTrace);
}

/// Raw instant, truncated to 1 ms (REQ-DOM-004).
@override final  int? rawUtcMs;
/// Displayed instant after rounding (REQ-DOM-003).
@override final  int? displayedUtcMs;
/// Local-date offset from the prayer day, −1…1.
@override final  int? dayOffset;

/// Create a copy of TraceTimeDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TraceTimeDocumentCopyWith<_TraceTimeDocument> get copyWith => __$TraceTimeDocumentCopyWithImpl<_TraceTimeDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TraceTimeDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TraceTimeDocument&&(identical(other.event, event) || other.event == event)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other.flags, _flags)&&const DeepCollectionEquality().equals(other.adjustmentTrace, _adjustmentTrace)&&(identical(other.rawUtcMs, rawUtcMs) || other.rawUtcMs == rawUtcMs)&&(identical(other.displayedUtcMs, displayedUtcMs) || other.displayedUtcMs == displayedUtcMs)&&(identical(other.dayOffset, dayOffset) || other.dayOffset == dayOffset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,event,origin,confidence,const DeepCollectionEquality().hash(_flags),const DeepCollectionEquality().hash(_adjustmentTrace),rawUtcMs,displayedUtcMs,dayOffset);
}

@override
String toString() {
    return 'TraceTimeDocument(event: $event, origin: $origin, confidence: $confidence, flags: $flags, adjustmentTrace: $adjustmentTrace, rawUtcMs: $rawUtcMs, displayedUtcMs: $displayedUtcMs, dayOffset: $dayOffset)';
}


}

/// @nodoc
abstract mixin class _$TraceTimeDocumentCopyWith<$Res> implements $TraceTimeDocumentCopyWith<$Res> {
  factory _$TraceTimeDocumentCopyWith(_TraceTimeDocument value, $Res Function(_TraceTimeDocument) _then) = __$TraceTimeDocumentCopyWithImpl;
@override @useResult
$Res call({
 PrayerEventCode event, EventOriginDocument origin, ConfidenceLabelDocument confidence, List<ResultFlagCode> flags, List<AdjustmentStepDocument> adjustmentTrace, int? rawUtcMs, int? displayedUtcMs, int? dayOffset
});


@override $EventOriginDocumentCopyWith<$Res> get origin;@override $ConfidenceLabelDocumentCopyWith<$Res> get confidence;

}
/// @nodoc
class __$TraceTimeDocumentCopyWithImpl<$Res>
    implements _$TraceTimeDocumentCopyWith<$Res> {
  __$TraceTimeDocumentCopyWithImpl(this._self, this._then);

  final _TraceTimeDocument _self;
  final $Res Function(_TraceTimeDocument) _then;

/// Create a copy of TraceTimeDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? event = null,Object? origin = null,Object? confidence = null,Object? flags = null,Object? adjustmentTrace = null,Object? rawUtcMs = freezed,Object? displayedUtcMs = freezed,Object? dayOffset = freezed,}) {
  return _then(_TraceTimeDocument(
event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as PrayerEventCode,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as EventOriginDocument,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as ConfidenceLabelDocument,flags: null == flags ? _self._flags : flags // ignore: cast_nullable_to_non_nullable
as List<ResultFlagCode>,adjustmentTrace: null == adjustmentTrace ? _self._adjustmentTrace : adjustmentTrace // ignore: cast_nullable_to_non_nullable
as List<AdjustmentStepDocument>,rawUtcMs: freezed == rawUtcMs ? _self.rawUtcMs : rawUtcMs // ignore: cast_nullable_to_non_nullable
as int?,displayedUtcMs: freezed == displayedUtcMs ? _self.displayedUtcMs : displayedUtcMs // ignore: cast_nullable_to_non_nullable
as int?,dayOffset: freezed == dayOffset ? _self.dayOffset : dayOffset // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of TraceTimeDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventOriginDocumentCopyWith<$Res> get origin {
  
  return $EventOriginDocumentCopyWith<$Res>(_self.origin, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of TraceTimeDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfidenceLabelDocumentCopyWith<$Res> get confidence {
  
  return $ConfidenceLabelDocumentCopyWith<$Res>(_self.confidence, (value) {
    return _then(_self.copyWith(confidence: value));
  });
}
}

// dart format on
