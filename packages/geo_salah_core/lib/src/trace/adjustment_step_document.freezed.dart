// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'adjustment_step_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdjustmentStepDocument {

/// Event the step applies to.
 PrayerEventCode get event;/// What kind of adjustment it was.
 AdjustmentKindCode get kind;/// Change in milliseconds.
 int get deltaMs;/// Why the step was taken.
 String get reason;/// Evidence id, when the step comes from profile evidence.
 String? get evidenceId;
/// Create a copy of AdjustmentStepDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdjustmentStepDocumentCopyWith<AdjustmentStepDocument> get copyWith => _$AdjustmentStepDocumentCopyWithImpl<AdjustmentStepDocument>(this as AdjustmentStepDocument, _$identity);

  /// Serializes this AdjustmentStepDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdjustmentStepDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdjustmentStepDocument&&(identical(other.event, _this.event) || other.event == _this.event)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.deltaMs, _this.deltaMs) || other.deltaMs == _this.deltaMs)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.evidenceId, _this.evidenceId) || other.evidenceId == _this.evidenceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdjustmentStepDocument;
  return Object.hash(runtimeType,_this.event,_this.kind,_this.deltaMs,_this.reason,_this.evidenceId);
}

@override
String toString() {
  final _this = this as AdjustmentStepDocument;
  return 'AdjustmentStepDocument(event: ${_this.event}, kind: ${_this.kind}, deltaMs: ${_this.deltaMs}, reason: ${_this.reason}, evidenceId: ${_this.evidenceId})';
}


}

/// @nodoc
abstract mixin class $AdjustmentStepDocumentCopyWith<$Res>  {
  factory $AdjustmentStepDocumentCopyWith(AdjustmentStepDocument value, $Res Function(AdjustmentStepDocument) _then) = _$AdjustmentStepDocumentCopyWithImpl;
@useResult
$Res call({
 PrayerEventCode event, AdjustmentKindCode kind, int deltaMs, String reason, String? evidenceId
});




}
/// @nodoc
class _$AdjustmentStepDocumentCopyWithImpl<$Res>
    implements $AdjustmentStepDocumentCopyWith<$Res> {
  _$AdjustmentStepDocumentCopyWithImpl(this._self, this._then);

  final AdjustmentStepDocument _self;
  final $Res Function(AdjustmentStepDocument) _then;

/// Create a copy of AdjustmentStepDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? event = null,Object? kind = null,Object? deltaMs = null,Object? reason = null,Object? evidenceId = freezed,}) {
  return _then(AdjustmentStepDocument(
event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as PrayerEventCode,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AdjustmentKindCode,deltaMs: null == deltaMs ? _self.deltaMs : deltaMs // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,evidenceId: freezed == evidenceId ? _self.evidenceId : evidenceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdjustmentStepDocument].
extension AdjustmentStepDocumentPatterns on AdjustmentStepDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdjustmentStepDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdjustmentStepDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdjustmentStepDocument value)  $default,){
final _that = this;
switch (_that) {
case _AdjustmentStepDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdjustmentStepDocument value)?  $default,){
final _that = this;
switch (_that) {
case _AdjustmentStepDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PrayerEventCode event,  AdjustmentKindCode kind,  int deltaMs,  String reason,  String? evidenceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdjustmentStepDocument() when $default != null:
return $default(_that.event,_that.kind,_that.deltaMs,_that.reason,_that.evidenceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PrayerEventCode event,  AdjustmentKindCode kind,  int deltaMs,  String reason,  String? evidenceId)  $default,) {final _that = this;
switch (_that) {
case _AdjustmentStepDocument():
return $default(_that.event,_that.kind,_that.deltaMs,_that.reason,_that.evidenceId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PrayerEventCode event,  AdjustmentKindCode kind,  int deltaMs,  String reason,  String? evidenceId)?  $default,) {final _that = this;
switch (_that) {
case _AdjustmentStepDocument() when $default != null:
return $default(_that.event,_that.kind,_that.deltaMs,_that.reason,_that.evidenceId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdjustmentStepDocument implements AdjustmentStepDocument {
  const _AdjustmentStepDocument({required this.event, required this.kind, required this.deltaMs, required this.reason, this.evidenceId});
  factory _AdjustmentStepDocument.fromJson(Map<String, dynamic> json) => _$AdjustmentStepDocumentFromJson(json);

/// Event the step applies to.
@override final  PrayerEventCode event;
/// What kind of adjustment it was.
@override final  AdjustmentKindCode kind;
/// Change in milliseconds.
@override final  int deltaMs;
/// Why the step was taken.
@override final  String reason;
/// Evidence id, when the step comes from profile evidence.
@override final  String? evidenceId;

/// Create a copy of AdjustmentStepDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdjustmentStepDocumentCopyWith<_AdjustmentStepDocument> get copyWith => __$AdjustmentStepDocumentCopyWithImpl<_AdjustmentStepDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdjustmentStepDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdjustmentStepDocument&&(identical(other.event, event) || other.event == event)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.deltaMs, deltaMs) || other.deltaMs == deltaMs)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.evidenceId, evidenceId) || other.evidenceId == evidenceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,event,kind,deltaMs,reason,evidenceId);
}

@override
String toString() {
    return 'AdjustmentStepDocument(event: $event, kind: $kind, deltaMs: $deltaMs, reason: $reason, evidenceId: $evidenceId)';
}


}

/// @nodoc
abstract mixin class _$AdjustmentStepDocumentCopyWith<$Res> implements $AdjustmentStepDocumentCopyWith<$Res> {
  factory _$AdjustmentStepDocumentCopyWith(_AdjustmentStepDocument value, $Res Function(_AdjustmentStepDocument) _then) = __$AdjustmentStepDocumentCopyWithImpl;
@override @useResult
$Res call({
 PrayerEventCode event, AdjustmentKindCode kind, int deltaMs, String reason, String? evidenceId
});




}
/// @nodoc
class __$AdjustmentStepDocumentCopyWithImpl<$Res>
    implements _$AdjustmentStepDocumentCopyWith<$Res> {
  __$AdjustmentStepDocumentCopyWithImpl(this._self, this._then);

  final _AdjustmentStepDocument _self;
  final $Res Function(_AdjustmentStepDocument) _then;

/// Create a copy of AdjustmentStepDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? event = null,Object? kind = null,Object? deltaMs = null,Object? reason = null,Object? evidenceId = freezed,}) {
  return _then(_AdjustmentStepDocument(
event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as PrayerEventCode,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AdjustmentKindCode,deltaMs: null == deltaMs ? _self.deltaMs : deltaMs // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,evidenceId: freezed == evidenceId ? _self.evidenceId : evidenceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
