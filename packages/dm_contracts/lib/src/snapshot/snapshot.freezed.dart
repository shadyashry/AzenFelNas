// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Snapshot {

/// Schema version; 1.
 int get schemaVersion;/// Location context id.
 String get contextId;/// IANA zone.
 String get zoneId;/// Pinned TZDB version.
 String get tzdbVersion;/// When it was written.
 int get generatedAtUtcMs;/// Locale of pre-rendered text.
 PlanLocale get locale;/// Displayed times.
 List<SnapshotItem> get items;/// Sky-phase timeline.
 List<SkySegment> get skyTimeline;/// Athan Health summary.
 SnapshotHealth get health;
/// Create a copy of Snapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnapshotCopyWith<Snapshot> get copyWith => _$SnapshotCopyWithImpl<Snapshot>(this as Snapshot, _$identity);

  /// Serializes this Snapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Snapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Snapshot&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.contextId, _this.contextId) || other.contextId == _this.contextId)&&(identical(other.zoneId, _this.zoneId) || other.zoneId == _this.zoneId)&&(identical(other.tzdbVersion, _this.tzdbVersion) || other.tzdbVersion == _this.tzdbVersion)&&(identical(other.generatedAtUtcMs, _this.generatedAtUtcMs) || other.generatedAtUtcMs == _this.generatedAtUtcMs)&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&const DeepCollectionEquality().equals(other.items, _this.items)&&const DeepCollectionEquality().equals(other.skyTimeline, _this.skyTimeline)&&(identical(other.health, _this.health) || other.health == _this.health));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Snapshot;
  return Object.hash(runtimeType,_this.schemaVersion,_this.contextId,_this.zoneId,_this.tzdbVersion,_this.generatedAtUtcMs,_this.locale,const DeepCollectionEquality().hash(_this.items),const DeepCollectionEquality().hash(_this.skyTimeline),_this.health);
}

@override
String toString() {
  final _this = this as Snapshot;
  return 'Snapshot(schemaVersion: ${_this.schemaVersion}, contextId: ${_this.contextId}, zoneId: ${_this.zoneId}, tzdbVersion: ${_this.tzdbVersion}, generatedAtUtcMs: ${_this.generatedAtUtcMs}, locale: ${_this.locale}, items: ${_this.items}, skyTimeline: ${_this.skyTimeline}, health: ${_this.health})';
}


}

/// @nodoc
abstract mixin class $SnapshotCopyWith<$Res>  {
  factory $SnapshotCopyWith(Snapshot value, $Res Function(Snapshot) _then) = _$SnapshotCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String contextId, String zoneId, String tzdbVersion, int generatedAtUtcMs, PlanLocale locale, List<SnapshotItem> items, List<SkySegment> skyTimeline, SnapshotHealth health
});


$SnapshotHealthCopyWith<$Res> get health;

}
/// @nodoc
class _$SnapshotCopyWithImpl<$Res>
    implements $SnapshotCopyWith<$Res> {
  _$SnapshotCopyWithImpl(this._self, this._then);

  final Snapshot _self;
  final $Res Function(Snapshot) _then;

/// Create a copy of Snapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? contextId = null,Object? zoneId = null,Object? tzdbVersion = null,Object? generatedAtUtcMs = null,Object? locale = null,Object? items = null,Object? skyTimeline = null,Object? health = null,}) {
  return _then(Snapshot(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,tzdbVersion: null == tzdbVersion ? _self.tzdbVersion : tzdbVersion // ignore: cast_nullable_to_non_nullable
as String,generatedAtUtcMs: null == generatedAtUtcMs ? _self.generatedAtUtcMs : generatedAtUtcMs // ignore: cast_nullable_to_non_nullable
as int,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as PlanLocale,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SnapshotItem>,skyTimeline: null == skyTimeline ? _self.skyTimeline : skyTimeline // ignore: cast_nullable_to_non_nullable
as List<SkySegment>,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as SnapshotHealth,
  ));
}
/// Create a copy of Snapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnapshotHealthCopyWith<$Res> get health {
  
  return $SnapshotHealthCopyWith<$Res>(_self.health, (value) {
    return _then(_self.copyWith(health: value));
  });
}
}


/// Adds pattern-matching-related methods to [Snapshot].
extension SnapshotPatterns on Snapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Snapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Snapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Snapshot value)  $default,){
final _that = this;
switch (_that) {
case _Snapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Snapshot value)?  $default,){
final _that = this;
switch (_that) {
case _Snapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String contextId,  String zoneId,  String tzdbVersion,  int generatedAtUtcMs,  PlanLocale locale,  List<SnapshotItem> items,  List<SkySegment> skyTimeline,  SnapshotHealth health)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Snapshot() when $default != null:
return $default(_that.schemaVersion,_that.contextId,_that.zoneId,_that.tzdbVersion,_that.generatedAtUtcMs,_that.locale,_that.items,_that.skyTimeline,_that.health);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String contextId,  String zoneId,  String tzdbVersion,  int generatedAtUtcMs,  PlanLocale locale,  List<SnapshotItem> items,  List<SkySegment> skyTimeline,  SnapshotHealth health)  $default,) {final _that = this;
switch (_that) {
case _Snapshot():
return $default(_that.schemaVersion,_that.contextId,_that.zoneId,_that.tzdbVersion,_that.generatedAtUtcMs,_that.locale,_that.items,_that.skyTimeline,_that.health);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String contextId,  String zoneId,  String tzdbVersion,  int generatedAtUtcMs,  PlanLocale locale,  List<SnapshotItem> items,  List<SkySegment> skyTimeline,  SnapshotHealth health)?  $default,) {final _that = this;
switch (_that) {
case _Snapshot() when $default != null:
return $default(_that.schemaVersion,_that.contextId,_that.zoneId,_that.tzdbVersion,_that.generatedAtUtcMs,_that.locale,_that.items,_that.skyTimeline,_that.health);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Snapshot implements Snapshot {
  const _Snapshot({required this.schemaVersion, required this.contextId, required this.zoneId, required this.tzdbVersion, required this.generatedAtUtcMs, required this.locale, required  List<SnapshotItem> items, required  List<SkySegment> skyTimeline, required this.health}): _items = items,_skyTimeline = skyTimeline;
  factory _Snapshot.fromJson(Map<String, dynamic> json) => _$SnapshotFromJson(json);

/// Schema version; 1.
@override final  int schemaVersion;
/// Location context id.
@override final  String contextId;
/// IANA zone.
@override final  String zoneId;
/// Pinned TZDB version.
@override final  String tzdbVersion;
/// When it was written.
@override final  int generatedAtUtcMs;
/// Locale of pre-rendered text.
@override final  PlanLocale locale;
/// Displayed times.
 final  List<SnapshotItem> _items;
/// Displayed times.
@override List<SnapshotItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// Sky-phase timeline.
 final  List<SkySegment> _skyTimeline;
/// Sky-phase timeline.
@override List<SkySegment> get skyTimeline {
  if (_skyTimeline is EqualUnmodifiableListView) return _skyTimeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skyTimeline);
}

/// Athan Health summary.
@override final  SnapshotHealth health;

/// Create a copy of Snapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnapshotCopyWith<_Snapshot> get copyWith => __$SnapshotCopyWithImpl<_Snapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Snapshot&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.tzdbVersion, tzdbVersion) || other.tzdbVersion == tzdbVersion)&&(identical(other.generatedAtUtcMs, generatedAtUtcMs) || other.generatedAtUtcMs == generatedAtUtcMs)&&(identical(other.locale, locale) || other.locale == locale)&&const DeepCollectionEquality().equals(other.items, _items)&&const DeepCollectionEquality().equals(other.skyTimeline, _skyTimeline)&&(identical(other.health, health) || other.health == health));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,contextId,zoneId,tzdbVersion,generatedAtUtcMs,locale,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_skyTimeline),health);
}

@override
String toString() {
    return 'Snapshot(schemaVersion: $schemaVersion, contextId: $contextId, zoneId: $zoneId, tzdbVersion: $tzdbVersion, generatedAtUtcMs: $generatedAtUtcMs, locale: $locale, items: $items, skyTimeline: $skyTimeline, health: $health)';
}


}

/// @nodoc
abstract mixin class _$SnapshotCopyWith<$Res> implements $SnapshotCopyWith<$Res> {
  factory _$SnapshotCopyWith(_Snapshot value, $Res Function(_Snapshot) _then) = __$SnapshotCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String contextId, String zoneId, String tzdbVersion, int generatedAtUtcMs, PlanLocale locale, List<SnapshotItem> items, List<SkySegment> skyTimeline, SnapshotHealth health
});


@override $SnapshotHealthCopyWith<$Res> get health;

}
/// @nodoc
class __$SnapshotCopyWithImpl<$Res>
    implements _$SnapshotCopyWith<$Res> {
  __$SnapshotCopyWithImpl(this._self, this._then);

  final _Snapshot _self;
  final $Res Function(_Snapshot) _then;

/// Create a copy of Snapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? contextId = null,Object? zoneId = null,Object? tzdbVersion = null,Object? generatedAtUtcMs = null,Object? locale = null,Object? items = null,Object? skyTimeline = null,Object? health = null,}) {
  return _then(_Snapshot(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,tzdbVersion: null == tzdbVersion ? _self.tzdbVersion : tzdbVersion // ignore: cast_nullable_to_non_nullable
as String,generatedAtUtcMs: null == generatedAtUtcMs ? _self.generatedAtUtcMs : generatedAtUtcMs // ignore: cast_nullable_to_non_nullable
as int,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as PlanLocale,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SnapshotItem>,skyTimeline: null == skyTimeline ? _self._skyTimeline : skyTimeline // ignore: cast_nullable_to_non_nullable
as List<SkySegment>,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as SnapshotHealth,
  ));
}

/// Create a copy of Snapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnapshotHealthCopyWith<$Res> get health {
  
  return $SnapshotHealthCopyWith<$Res>(_self.health, (value) {
    return _then(_self.copyWith(health: value));
  });
}
}

// dart format on
