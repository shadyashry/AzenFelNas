// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_plan_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SchedulePlanEntry {

/// Deterministic id: hex of sha256(`contextId|day|event|kind`)[0:16].
 String get id;/// Prayer day, `YYYY-MM-DD`.
 String get day;/// Entry kind.
 ScheduleEntryKind get kind;/// Fire instant = displayedUtcMs (REQ-ALM-001).
 int get fireAtUtcMs;/// Pre-rendered `HH:mm` in the plan's zone.
 String get displayLocal;/// Title.
 LocalizedText get title;/// Body.
 LocalizedText get body;/// Sound id.
 String get soundId;/// iOS fitting priority, 1–3.
 int get priority;/// Event, absent for horizon warnings.
 PrayerEventCode? get event;
/// Create a copy of SchedulePlanEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchedulePlanEntryCopyWith<SchedulePlanEntry> get copyWith => _$SchedulePlanEntryCopyWithImpl<SchedulePlanEntry>(this as SchedulePlanEntry, _$identity);

  /// Serializes this SchedulePlanEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SchedulePlanEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchedulePlanEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.day, _this.day) || other.day == _this.day)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.fireAtUtcMs, _this.fireAtUtcMs) || other.fireAtUtcMs == _this.fireAtUtcMs)&&(identical(other.displayLocal, _this.displayLocal) || other.displayLocal == _this.displayLocal)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.soundId, _this.soundId) || other.soundId == _this.soundId)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.event, _this.event) || other.event == _this.event));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SchedulePlanEntry;
  return Object.hash(runtimeType,_this.id,_this.day,_this.kind,_this.fireAtUtcMs,_this.displayLocal,_this.title,_this.body,_this.soundId,_this.priority,_this.event);
}

@override
String toString() {
  final _this = this as SchedulePlanEntry;
  return 'SchedulePlanEntry(id: ${_this.id}, day: ${_this.day}, kind: ${_this.kind}, fireAtUtcMs: ${_this.fireAtUtcMs}, displayLocal: ${_this.displayLocal}, title: ${_this.title}, body: ${_this.body}, soundId: ${_this.soundId}, priority: ${_this.priority}, event: ${_this.event})';
}


}

/// @nodoc
abstract mixin class $SchedulePlanEntryCopyWith<$Res>  {
  factory $SchedulePlanEntryCopyWith(SchedulePlanEntry value, $Res Function(SchedulePlanEntry) _then) = _$SchedulePlanEntryCopyWithImpl;
@useResult
$Res call({
 String id, String day, ScheduleEntryKind kind, int fireAtUtcMs, String displayLocal, LocalizedText title, LocalizedText body, String soundId, int priority, PrayerEventCode? event
});


$LocalizedTextCopyWith<$Res> get title;$LocalizedTextCopyWith<$Res> get body;

}
/// @nodoc
class _$SchedulePlanEntryCopyWithImpl<$Res>
    implements $SchedulePlanEntryCopyWith<$Res> {
  _$SchedulePlanEntryCopyWithImpl(this._self, this._then);

  final SchedulePlanEntry _self;
  final $Res Function(SchedulePlanEntry) _then;

/// Create a copy of SchedulePlanEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? day = null,Object? kind = null,Object? fireAtUtcMs = null,Object? displayLocal = null,Object? title = null,Object? body = null,Object? soundId = null,Object? priority = null,Object? event = freezed,}) {
  return _then(SchedulePlanEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ScheduleEntryKind,fireAtUtcMs: null == fireAtUtcMs ? _self.fireAtUtcMs : fireAtUtcMs // ignore: cast_nullable_to_non_nullable
as int,displayLocal: null == displayLocal ? _self.displayLocal : displayLocal // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as LocalizedText,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as LocalizedText,soundId: null == soundId ? _self.soundId : soundId // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as PrayerEventCode?,
  ));
}
/// Create a copy of SchedulePlanEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextCopyWith<$Res> get title {
  
  return $LocalizedTextCopyWith<$Res>(_self.title, (value) {
    return _then(_self.copyWith(title: value));
  });
}/// Create a copy of SchedulePlanEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextCopyWith<$Res> get body {
  
  return $LocalizedTextCopyWith<$Res>(_self.body, (value) {
    return _then(_self.copyWith(body: value));
  });
}
}


/// Adds pattern-matching-related methods to [SchedulePlanEntry].
extension SchedulePlanEntryPatterns on SchedulePlanEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchedulePlanEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchedulePlanEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchedulePlanEntry value)  $default,){
final _that = this;
switch (_that) {
case _SchedulePlanEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchedulePlanEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SchedulePlanEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String day,  ScheduleEntryKind kind,  int fireAtUtcMs,  String displayLocal,  LocalizedText title,  LocalizedText body,  String soundId,  int priority,  PrayerEventCode? event)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchedulePlanEntry() when $default != null:
return $default(_that.id,_that.day,_that.kind,_that.fireAtUtcMs,_that.displayLocal,_that.title,_that.body,_that.soundId,_that.priority,_that.event);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String day,  ScheduleEntryKind kind,  int fireAtUtcMs,  String displayLocal,  LocalizedText title,  LocalizedText body,  String soundId,  int priority,  PrayerEventCode? event)  $default,) {final _that = this;
switch (_that) {
case _SchedulePlanEntry():
return $default(_that.id,_that.day,_that.kind,_that.fireAtUtcMs,_that.displayLocal,_that.title,_that.body,_that.soundId,_that.priority,_that.event);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String day,  ScheduleEntryKind kind,  int fireAtUtcMs,  String displayLocal,  LocalizedText title,  LocalizedText body,  String soundId,  int priority,  PrayerEventCode? event)?  $default,) {final _that = this;
switch (_that) {
case _SchedulePlanEntry() when $default != null:
return $default(_that.id,_that.day,_that.kind,_that.fireAtUtcMs,_that.displayLocal,_that.title,_that.body,_that.soundId,_that.priority,_that.event);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SchedulePlanEntry implements SchedulePlanEntry {
  const _SchedulePlanEntry({required this.id, required this.day, required this.kind, required this.fireAtUtcMs, required this.displayLocal, required this.title, required this.body, required this.soundId, required this.priority, this.event});
  factory _SchedulePlanEntry.fromJson(Map<String, dynamic> json) => _$SchedulePlanEntryFromJson(json);

/// Deterministic id: hex of sha256(`contextId|day|event|kind`)[0:16].
@override final  String id;
/// Prayer day, `YYYY-MM-DD`.
@override final  String day;
/// Entry kind.
@override final  ScheduleEntryKind kind;
/// Fire instant = displayedUtcMs (REQ-ALM-001).
@override final  int fireAtUtcMs;
/// Pre-rendered `HH:mm` in the plan's zone.
@override final  String displayLocal;
/// Title.
@override final  LocalizedText title;
/// Body.
@override final  LocalizedText body;
/// Sound id.
@override final  String soundId;
/// iOS fitting priority, 1–3.
@override final  int priority;
/// Event, absent for horizon warnings.
@override final  PrayerEventCode? event;

/// Create a copy of SchedulePlanEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchedulePlanEntryCopyWith<_SchedulePlanEntry> get copyWith => __$SchedulePlanEntryCopyWithImpl<_SchedulePlanEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchedulePlanEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchedulePlanEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.fireAtUtcMs, fireAtUtcMs) || other.fireAtUtcMs == fireAtUtcMs)&&(identical(other.displayLocal, displayLocal) || other.displayLocal == displayLocal)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.soundId, soundId) || other.soundId == soundId)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.event, event) || other.event == event));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,day,kind,fireAtUtcMs,displayLocal,title,body,soundId,priority,event);
}

@override
String toString() {
    return 'SchedulePlanEntry(id: $id, day: $day, kind: $kind, fireAtUtcMs: $fireAtUtcMs, displayLocal: $displayLocal, title: $title, body: $body, soundId: $soundId, priority: $priority, event: $event)';
}


}

/// @nodoc
abstract mixin class _$SchedulePlanEntryCopyWith<$Res> implements $SchedulePlanEntryCopyWith<$Res> {
  factory _$SchedulePlanEntryCopyWith(_SchedulePlanEntry value, $Res Function(_SchedulePlanEntry) _then) = __$SchedulePlanEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String day, ScheduleEntryKind kind, int fireAtUtcMs, String displayLocal, LocalizedText title, LocalizedText body, String soundId, int priority, PrayerEventCode? event
});


@override $LocalizedTextCopyWith<$Res> get title;@override $LocalizedTextCopyWith<$Res> get body;

}
/// @nodoc
class __$SchedulePlanEntryCopyWithImpl<$Res>
    implements _$SchedulePlanEntryCopyWith<$Res> {
  __$SchedulePlanEntryCopyWithImpl(this._self, this._then);

  final _SchedulePlanEntry _self;
  final $Res Function(_SchedulePlanEntry) _then;

/// Create a copy of SchedulePlanEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? day = null,Object? kind = null,Object? fireAtUtcMs = null,Object? displayLocal = null,Object? title = null,Object? body = null,Object? soundId = null,Object? priority = null,Object? event = freezed,}) {
  return _then(_SchedulePlanEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ScheduleEntryKind,fireAtUtcMs: null == fireAtUtcMs ? _self.fireAtUtcMs : fireAtUtcMs // ignore: cast_nullable_to_non_nullable
as int,displayLocal: null == displayLocal ? _self.displayLocal : displayLocal // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as LocalizedText,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as LocalizedText,soundId: null == soundId ? _self.soundId : soundId // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as PrayerEventCode?,
  ));
}

/// Create a copy of SchedulePlanEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextCopyWith<$Res> get title {
  
  return $LocalizedTextCopyWith<$Res>(_self.title, (value) {
    return _then(_self.copyWith(title: value));
  });
}/// Create a copy of SchedulePlanEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextCopyWith<$Res> get body {
  
  return $LocalizedTextCopyWith<$Res>(_self.body, (value) {
    return _then(_self.copyWith(body: value));
  });
}
}

// dart format on
