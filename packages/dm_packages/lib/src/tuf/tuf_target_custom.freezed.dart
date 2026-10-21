// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tuf_target_custom.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TufTargetCustom {

/// Payload schema version.
 int get schemaVersion;/// Payload format.
 PayloadFormatCode get payloadFormat;/// Compatibility gate.
 TufCompat get compat;/// Effective date, `YYYY-MM-DD`.
 String get effectiveFrom;/// Download priority.
 TargetPriorityCode get priority;/// Change note.
 TufChangeNote get changeNote;/// Version this target rolls back from.
 String? get rollbackOf;/// Attribution text.
 String? get attribution;
/// Create a copy of TufTargetCustom
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufTargetCustomCopyWith<TufTargetCustom> get copyWith => _$TufTargetCustomCopyWithImpl<TufTargetCustom>(this as TufTargetCustom, _$identity);

  /// Serializes this TufTargetCustom to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TufTargetCustom;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TufTargetCustom&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.payloadFormat, _this.payloadFormat) || other.payloadFormat == _this.payloadFormat)&&(identical(other.compat, _this.compat) || other.compat == _this.compat)&&(identical(other.effectiveFrom, _this.effectiveFrom) || other.effectiveFrom == _this.effectiveFrom)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.changeNote, _this.changeNote) || other.changeNote == _this.changeNote)&&(identical(other.rollbackOf, _this.rollbackOf) || other.rollbackOf == _this.rollbackOf)&&(identical(other.attribution, _this.attribution) || other.attribution == _this.attribution));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TufTargetCustom;
  return Object.hash(runtimeType,_this.schemaVersion,_this.payloadFormat,_this.compat,_this.effectiveFrom,_this.priority,_this.changeNote,_this.rollbackOf,_this.attribution);
}

@override
String toString() {
  final _this = this as TufTargetCustom;
  return 'TufTargetCustom(schemaVersion: ${_this.schemaVersion}, payloadFormat: ${_this.payloadFormat}, compat: ${_this.compat}, effectiveFrom: ${_this.effectiveFrom}, priority: ${_this.priority}, changeNote: ${_this.changeNote}, rollbackOf: ${_this.rollbackOf}, attribution: ${_this.attribution})';
}


}

/// @nodoc
abstract mixin class $TufTargetCustomCopyWith<$Res>  {
  factory $TufTargetCustomCopyWith(TufTargetCustom value, $Res Function(TufTargetCustom) _then) = _$TufTargetCustomCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, PayloadFormatCode payloadFormat, TufCompat compat, String effectiveFrom, TargetPriorityCode priority, TufChangeNote changeNote, String? rollbackOf, String? attribution
});


$TufCompatCopyWith<$Res> get compat;$TufChangeNoteCopyWith<$Res> get changeNote;

}
/// @nodoc
class _$TufTargetCustomCopyWithImpl<$Res>
    implements $TufTargetCustomCopyWith<$Res> {
  _$TufTargetCustomCopyWithImpl(this._self, this._then);

  final TufTargetCustom _self;
  final $Res Function(TufTargetCustom) _then;

/// Create a copy of TufTargetCustom
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? payloadFormat = null,Object? compat = null,Object? effectiveFrom = null,Object? priority = null,Object? changeNote = null,Object? rollbackOf = freezed,Object? attribution = freezed,}) {
  return _then(TufTargetCustom(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,payloadFormat: null == payloadFormat ? _self.payloadFormat : payloadFormat // ignore: cast_nullable_to_non_nullable
as PayloadFormatCode,compat: null == compat ? _self.compat : compat // ignore: cast_nullable_to_non_nullable
as TufCompat,effectiveFrom: null == effectiveFrom ? _self.effectiveFrom : effectiveFrom // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TargetPriorityCode,changeNote: null == changeNote ? _self.changeNote : changeNote // ignore: cast_nullable_to_non_nullable
as TufChangeNote,rollbackOf: freezed == rollbackOf ? _self.rollbackOf : rollbackOf // ignore: cast_nullable_to_non_nullable
as String?,attribution: freezed == attribution ? _self.attribution : attribution // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of TufTargetCustom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufCompatCopyWith<$Res> get compat {
  
  return $TufCompatCopyWith<$Res>(_self.compat, (value) {
    return _then(_self.copyWith(compat: value));
  });
}/// Create a copy of TufTargetCustom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufChangeNoteCopyWith<$Res> get changeNote {
  
  return $TufChangeNoteCopyWith<$Res>(_self.changeNote, (value) {
    return _then(_self.copyWith(changeNote: value));
  });
}
}


/// Adds pattern-matching-related methods to [TufTargetCustom].
extension TufTargetCustomPatterns on TufTargetCustom {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TufTargetCustom value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TufTargetCustom() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TufTargetCustom value)  $default,){
final _that = this;
switch (_that) {
case _TufTargetCustom():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TufTargetCustom value)?  $default,){
final _that = this;
switch (_that) {
case _TufTargetCustom() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  PayloadFormatCode payloadFormat,  TufCompat compat,  String effectiveFrom,  TargetPriorityCode priority,  TufChangeNote changeNote,  String? rollbackOf,  String? attribution)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TufTargetCustom() when $default != null:
return $default(_that.schemaVersion,_that.payloadFormat,_that.compat,_that.effectiveFrom,_that.priority,_that.changeNote,_that.rollbackOf,_that.attribution);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  PayloadFormatCode payloadFormat,  TufCompat compat,  String effectiveFrom,  TargetPriorityCode priority,  TufChangeNote changeNote,  String? rollbackOf,  String? attribution)  $default,) {final _that = this;
switch (_that) {
case _TufTargetCustom():
return $default(_that.schemaVersion,_that.payloadFormat,_that.compat,_that.effectiveFrom,_that.priority,_that.changeNote,_that.rollbackOf,_that.attribution);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  PayloadFormatCode payloadFormat,  TufCompat compat,  String effectiveFrom,  TargetPriorityCode priority,  TufChangeNote changeNote,  String? rollbackOf,  String? attribution)?  $default,) {final _that = this;
switch (_that) {
case _TufTargetCustom() when $default != null:
return $default(_that.schemaVersion,_that.payloadFormat,_that.compat,_that.effectiveFrom,_that.priority,_that.changeNote,_that.rollbackOf,_that.attribution);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TufTargetCustom implements TufTargetCustom {
  const _TufTargetCustom({required this.schemaVersion, required this.payloadFormat, required this.compat, required this.effectiveFrom, required this.priority, required this.changeNote, this.rollbackOf, this.attribution});
  factory _TufTargetCustom.fromJson(Map<String, dynamic> json) => _$TufTargetCustomFromJson(json);

/// Payload schema version.
@override final  int schemaVersion;
/// Payload format.
@override final  PayloadFormatCode payloadFormat;
/// Compatibility gate.
@override final  TufCompat compat;
/// Effective date, `YYYY-MM-DD`.
@override final  String effectiveFrom;
/// Download priority.
@override final  TargetPriorityCode priority;
/// Change note.
@override final  TufChangeNote changeNote;
/// Version this target rolls back from.
@override final  String? rollbackOf;
/// Attribution text.
@override final  String? attribution;

/// Create a copy of TufTargetCustom
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TufTargetCustomCopyWith<_TufTargetCustom> get copyWith => __$TufTargetCustomCopyWithImpl<_TufTargetCustom>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufTargetCustomToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TufTargetCustom&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.payloadFormat, payloadFormat) || other.payloadFormat == payloadFormat)&&(identical(other.compat, compat) || other.compat == compat)&&(identical(other.effectiveFrom, effectiveFrom) || other.effectiveFrom == effectiveFrom)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.changeNote, changeNote) || other.changeNote == changeNote)&&(identical(other.rollbackOf, rollbackOf) || other.rollbackOf == rollbackOf)&&(identical(other.attribution, attribution) || other.attribution == attribution));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,payloadFormat,compat,effectiveFrom,priority,changeNote,rollbackOf,attribution);
}

@override
String toString() {
    return 'TufTargetCustom(schemaVersion: $schemaVersion, payloadFormat: $payloadFormat, compat: $compat, effectiveFrom: $effectiveFrom, priority: $priority, changeNote: $changeNote, rollbackOf: $rollbackOf, attribution: $attribution)';
}


}

/// @nodoc
abstract mixin class _$TufTargetCustomCopyWith<$Res> implements $TufTargetCustomCopyWith<$Res> {
  factory _$TufTargetCustomCopyWith(_TufTargetCustom value, $Res Function(_TufTargetCustom) _then) = __$TufTargetCustomCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, PayloadFormatCode payloadFormat, TufCompat compat, String effectiveFrom, TargetPriorityCode priority, TufChangeNote changeNote, String? rollbackOf, String? attribution
});


@override $TufCompatCopyWith<$Res> get compat;@override $TufChangeNoteCopyWith<$Res> get changeNote;

}
/// @nodoc
class __$TufTargetCustomCopyWithImpl<$Res>
    implements _$TufTargetCustomCopyWith<$Res> {
  __$TufTargetCustomCopyWithImpl(this._self, this._then);

  final _TufTargetCustom _self;
  final $Res Function(_TufTargetCustom) _then;

/// Create a copy of TufTargetCustom
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? payloadFormat = null,Object? compat = null,Object? effectiveFrom = null,Object? priority = null,Object? changeNote = null,Object? rollbackOf = freezed,Object? attribution = freezed,}) {
  return _then(_TufTargetCustom(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,payloadFormat: null == payloadFormat ? _self.payloadFormat : payloadFormat // ignore: cast_nullable_to_non_nullable
as PayloadFormatCode,compat: null == compat ? _self.compat : compat // ignore: cast_nullable_to_non_nullable
as TufCompat,effectiveFrom: null == effectiveFrom ? _self.effectiveFrom : effectiveFrom // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TargetPriorityCode,changeNote: null == changeNote ? _self.changeNote : changeNote // ignore: cast_nullable_to_non_nullable
as TufChangeNote,rollbackOf: freezed == rollbackOf ? _self.rollbackOf : rollbackOf // ignore: cast_nullable_to_non_nullable
as String?,attribution: freezed == attribution ? _self.attribution : attribution // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of TufTargetCustom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufCompatCopyWith<$Res> get compat {
  
  return $TufCompatCopyWith<$Res>(_self.compat, (value) {
    return _then(_self.copyWith(compat: value));
  });
}/// Create a copy of TufTargetCustom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufChangeNoteCopyWith<$Res> get changeNote {
  
  return $TufChangeNoteCopyWith<$Res>(_self.changeNote, (value) {
    return _then(_self.copyWith(changeNote: value));
  });
}
}

// dart format on
