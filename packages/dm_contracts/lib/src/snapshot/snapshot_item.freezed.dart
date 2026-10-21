// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'snapshot_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnapshotItem {

/// Prayer day, `YYYY-MM-DD`.
 String get day;/// Event.
 PrayerEventCode get event;/// Displayed instant.
 int get displayedUtcMs;/// Pre-rendered `HH:mm`.
 String get displayLocal;/// Confidence.
 SnapshotConfidence get confidence;/// Local-date offset, −1…1.
 int get dayOffset;
/// Create a copy of SnapshotItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnapshotItemCopyWith<SnapshotItem> get copyWith => _$SnapshotItemCopyWithImpl<SnapshotItem>(this as SnapshotItem, _$identity);

  /// Serializes this SnapshotItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnapshotItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnapshotItem&&(identical(other.day, _this.day) || other.day == _this.day)&&(identical(other.event, _this.event) || other.event == _this.event)&&(identical(other.displayedUtcMs, _this.displayedUtcMs) || other.displayedUtcMs == _this.displayedUtcMs)&&(identical(other.displayLocal, _this.displayLocal) || other.displayLocal == _this.displayLocal)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.dayOffset, _this.dayOffset) || other.dayOffset == _this.dayOffset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnapshotItem;
  return Object.hash(runtimeType,_this.day,_this.event,_this.displayedUtcMs,_this.displayLocal,_this.confidence,_this.dayOffset);
}

@override
String toString() {
  final _this = this as SnapshotItem;
  return 'SnapshotItem(day: ${_this.day}, event: ${_this.event}, displayedUtcMs: ${_this.displayedUtcMs}, displayLocal: ${_this.displayLocal}, confidence: ${_this.confidence}, dayOffset: ${_this.dayOffset})';
}


}

/// @nodoc
abstract mixin class $SnapshotItemCopyWith<$Res>  {
  factory $SnapshotItemCopyWith(SnapshotItem value, $Res Function(SnapshotItem) _then) = _$SnapshotItemCopyWithImpl;
@useResult
$Res call({
 String day, PrayerEventCode event, int displayedUtcMs, String displayLocal, SnapshotConfidence confidence, int dayOffset
});


$SnapshotConfidenceCopyWith<$Res> get confidence;

}
/// @nodoc
class _$SnapshotItemCopyWithImpl<$Res>
    implements $SnapshotItemCopyWith<$Res> {
  _$SnapshotItemCopyWithImpl(this._self, this._then);

  final SnapshotItem _self;
  final $Res Function(SnapshotItem) _then;

/// Create a copy of SnapshotItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? event = null,Object? displayedUtcMs = null,Object? displayLocal = null,Object? confidence = null,Object? dayOffset = null,}) {
  return _then(SnapshotItem(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as PrayerEventCode,displayedUtcMs: null == displayedUtcMs ? _self.displayedUtcMs : displayedUtcMs // ignore: cast_nullable_to_non_nullable
as int,displayLocal: null == displayLocal ? _self.displayLocal : displayLocal // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as SnapshotConfidence,dayOffset: null == dayOffset ? _self.dayOffset : dayOffset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of SnapshotItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnapshotConfidenceCopyWith<$Res> get confidence {
  
  return $SnapshotConfidenceCopyWith<$Res>(_self.confidence, (value) {
    return _then(_self.copyWith(confidence: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnapshotItem].
extension SnapshotItemPatterns on SnapshotItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnapshotItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnapshotItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnapshotItem value)  $default,){
final _that = this;
switch (_that) {
case _SnapshotItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnapshotItem value)?  $default,){
final _that = this;
switch (_that) {
case _SnapshotItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String day,  PrayerEventCode event,  int displayedUtcMs,  String displayLocal,  SnapshotConfidence confidence,  int dayOffset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnapshotItem() when $default != null:
return $default(_that.day,_that.event,_that.displayedUtcMs,_that.displayLocal,_that.confidence,_that.dayOffset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String day,  PrayerEventCode event,  int displayedUtcMs,  String displayLocal,  SnapshotConfidence confidence,  int dayOffset)  $default,) {final _that = this;
switch (_that) {
case _SnapshotItem():
return $default(_that.day,_that.event,_that.displayedUtcMs,_that.displayLocal,_that.confidence,_that.dayOffset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String day,  PrayerEventCode event,  int displayedUtcMs,  String displayLocal,  SnapshotConfidence confidence,  int dayOffset)?  $default,) {final _that = this;
switch (_that) {
case _SnapshotItem() when $default != null:
return $default(_that.day,_that.event,_that.displayedUtcMs,_that.displayLocal,_that.confidence,_that.dayOffset);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnapshotItem implements SnapshotItem {
  const _SnapshotItem({required this.day, required this.event, required this.displayedUtcMs, required this.displayLocal, required this.confidence, required this.dayOffset});
  factory _SnapshotItem.fromJson(Map<String, dynamic> json) => _$SnapshotItemFromJson(json);

/// Prayer day, `YYYY-MM-DD`.
@override final  String day;
/// Event.
@override final  PrayerEventCode event;
/// Displayed instant.
@override final  int displayedUtcMs;
/// Pre-rendered `HH:mm`.
@override final  String displayLocal;
/// Confidence.
@override final  SnapshotConfidence confidence;
/// Local-date offset, −1…1.
@override final  int dayOffset;

/// Create a copy of SnapshotItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnapshotItemCopyWith<_SnapshotItem> get copyWith => __$SnapshotItemCopyWithImpl<_SnapshotItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnapshotItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnapshotItem&&(identical(other.day, day) || other.day == day)&&(identical(other.event, event) || other.event == event)&&(identical(other.displayedUtcMs, displayedUtcMs) || other.displayedUtcMs == displayedUtcMs)&&(identical(other.displayLocal, displayLocal) || other.displayLocal == displayLocal)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.dayOffset, dayOffset) || other.dayOffset == dayOffset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,day,event,displayedUtcMs,displayLocal,confidence,dayOffset);
}

@override
String toString() {
    return 'SnapshotItem(day: $day, event: $event, displayedUtcMs: $displayedUtcMs, displayLocal: $displayLocal, confidence: $confidence, dayOffset: $dayOffset)';
}


}

/// @nodoc
abstract mixin class _$SnapshotItemCopyWith<$Res> implements $SnapshotItemCopyWith<$Res> {
  factory _$SnapshotItemCopyWith(_SnapshotItem value, $Res Function(_SnapshotItem) _then) = __$SnapshotItemCopyWithImpl;
@override @useResult
$Res call({
 String day, PrayerEventCode event, int displayedUtcMs, String displayLocal, SnapshotConfidence confidence, int dayOffset
});


@override $SnapshotConfidenceCopyWith<$Res> get confidence;

}
/// @nodoc
class __$SnapshotItemCopyWithImpl<$Res>
    implements _$SnapshotItemCopyWith<$Res> {
  __$SnapshotItemCopyWithImpl(this._self, this._then);

  final _SnapshotItem _self;
  final $Res Function(_SnapshotItem) _then;

/// Create a copy of SnapshotItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? event = null,Object? displayedUtcMs = null,Object? displayLocal = null,Object? confidence = null,Object? dayOffset = null,}) {
  return _then(_SnapshotItem(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as PrayerEventCode,displayedUtcMs: null == displayedUtcMs ? _self.displayedUtcMs : displayedUtcMs // ignore: cast_nullable_to_non_nullable
as int,displayLocal: null == displayLocal ? _self.displayLocal : displayLocal // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as SnapshotConfidence,dayOffset: null == dayOffset ? _self.dayOffset : dayOffset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SnapshotItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnapshotConfidenceCopyWith<$Res> get confidence {
  
  return $SnapshotConfidenceCopyWith<$Res>(_self.confidence, (value) {
    return _then(_self.copyWith(confidence: value));
  });
}
}

// dart format on
