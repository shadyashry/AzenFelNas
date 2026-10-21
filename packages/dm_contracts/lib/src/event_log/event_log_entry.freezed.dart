// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_log_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventLogEntry {

/// When it happened.
 int get utcMs;/// Severity.
 EventLogLevel get level;/// Event code.
@EventCodeConverter() EventCode get code;/// Attributes.
 EventLogAttrs get attrs;
/// Create a copy of EventLogEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventLogEntryCopyWith<EventLogEntry> get copyWith => _$EventLogEntryCopyWithImpl<EventLogEntry>(this as EventLogEntry, _$identity);

  /// Serializes this EventLogEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EventLogEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventLogEntry&&(identical(other.utcMs, _this.utcMs) || other.utcMs == _this.utcMs)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.attrs, _this.attrs) || other.attrs == _this.attrs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EventLogEntry;
  return Object.hash(runtimeType,_this.utcMs,_this.level,_this.code,_this.attrs);
}

@override
String toString() {
  final _this = this as EventLogEntry;
  return 'EventLogEntry(utcMs: ${_this.utcMs}, level: ${_this.level}, code: ${_this.code}, attrs: ${_this.attrs})';
}


}

/// @nodoc
abstract mixin class $EventLogEntryCopyWith<$Res>  {
  factory $EventLogEntryCopyWith(EventLogEntry value, $Res Function(EventLogEntry) _then) = _$EventLogEntryCopyWithImpl;
@useResult
$Res call({
 int utcMs, EventLogLevel level,@EventCodeConverter() EventCode code, EventLogAttrs attrs
});


$EventLogAttrsCopyWith<$Res> get attrs;

}
/// @nodoc
class _$EventLogEntryCopyWithImpl<$Res>
    implements $EventLogEntryCopyWith<$Res> {
  _$EventLogEntryCopyWithImpl(this._self, this._then);

  final EventLogEntry _self;
  final $Res Function(EventLogEntry) _then;

/// Create a copy of EventLogEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? utcMs = null,Object? level = null,Object? code = null,Object? attrs = null,}) {
  return _then(EventLogEntry(
utcMs: null == utcMs ? _self.utcMs : utcMs // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as EventLogLevel,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as EventCode,attrs: null == attrs ? _self.attrs : attrs // ignore: cast_nullable_to_non_nullable
as EventLogAttrs,
  ));
}
/// Create a copy of EventLogEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventLogAttrsCopyWith<$Res> get attrs {
  
  return $EventLogAttrsCopyWith<$Res>(_self.attrs, (value) {
    return _then(_self.copyWith(attrs: value));
  });
}
}


/// Adds pattern-matching-related methods to [EventLogEntry].
extension EventLogEntryPatterns on EventLogEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventLogEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventLogEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventLogEntry value)  $default,){
final _that = this;
switch (_that) {
case _EventLogEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventLogEntry value)?  $default,){
final _that = this;
switch (_that) {
case _EventLogEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int utcMs,  EventLogLevel level, @EventCodeConverter()  EventCode code,  EventLogAttrs attrs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventLogEntry() when $default != null:
return $default(_that.utcMs,_that.level,_that.code,_that.attrs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int utcMs,  EventLogLevel level, @EventCodeConverter()  EventCode code,  EventLogAttrs attrs)  $default,) {final _that = this;
switch (_that) {
case _EventLogEntry():
return $default(_that.utcMs,_that.level,_that.code,_that.attrs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int utcMs,  EventLogLevel level, @EventCodeConverter()  EventCode code,  EventLogAttrs attrs)?  $default,) {final _that = this;
switch (_that) {
case _EventLogEntry() when $default != null:
return $default(_that.utcMs,_that.level,_that.code,_that.attrs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventLogEntry implements EventLogEntry {
  const _EventLogEntry({required this.utcMs, required this.level, @EventCodeConverter() required this.code, required this.attrs});
  factory _EventLogEntry.fromJson(Map<String, dynamic> json) => _$EventLogEntryFromJson(json);

/// When it happened.
@override final  int utcMs;
/// Severity.
@override final  EventLogLevel level;
/// Event code.
@override@EventCodeConverter() final  EventCode code;
/// Attributes.
@override final  EventLogAttrs attrs;

/// Create a copy of EventLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventLogEntryCopyWith<_EventLogEntry> get copyWith => __$EventLogEntryCopyWithImpl<_EventLogEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventLogEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventLogEntry&&(identical(other.utcMs, utcMs) || other.utcMs == utcMs)&&(identical(other.level, level) || other.level == level)&&(identical(other.code, code) || other.code == code)&&(identical(other.attrs, attrs) || other.attrs == attrs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,utcMs,level,code,attrs);
}

@override
String toString() {
    return 'EventLogEntry(utcMs: $utcMs, level: $level, code: $code, attrs: $attrs)';
}


}

/// @nodoc
abstract mixin class _$EventLogEntryCopyWith<$Res> implements $EventLogEntryCopyWith<$Res> {
  factory _$EventLogEntryCopyWith(_EventLogEntry value, $Res Function(_EventLogEntry) _then) = __$EventLogEntryCopyWithImpl;
@override @useResult
$Res call({
 int utcMs, EventLogLevel level,@EventCodeConverter() EventCode code, EventLogAttrs attrs
});


@override $EventLogAttrsCopyWith<$Res> get attrs;

}
/// @nodoc
class __$EventLogEntryCopyWithImpl<$Res>
    implements _$EventLogEntryCopyWith<$Res> {
  __$EventLogEntryCopyWithImpl(this._self, this._then);

  final _EventLogEntry _self;
  final $Res Function(_EventLogEntry) _then;

/// Create a copy of EventLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? utcMs = null,Object? level = null,Object? code = null,Object? attrs = null,}) {
  return _then(_EventLogEntry(
utcMs: null == utcMs ? _self.utcMs : utcMs // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as EventLogLevel,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as EventCode,attrs: null == attrs ? _self.attrs : attrs // ignore: cast_nullable_to_non_nullable
as EventLogAttrs,
  ));
}

/// Create a copy of EventLogEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventLogAttrsCopyWith<$Res> get attrs {
  
  return $EventLogAttrsCopyWith<$Res>(_self.attrs, (value) {
    return _then(_self.copyWith(attrs: value));
  });
}
}

// dart format on
