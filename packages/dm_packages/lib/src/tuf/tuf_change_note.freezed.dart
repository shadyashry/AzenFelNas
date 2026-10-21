// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tuf_change_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TufChangeNote {

/// Arabic.
 String get ar;/// English.
 String get en;
/// Create a copy of TufChangeNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufChangeNoteCopyWith<TufChangeNote> get copyWith => _$TufChangeNoteCopyWithImpl<TufChangeNote>(this as TufChangeNote, _$identity);

  /// Serializes this TufChangeNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TufChangeNote;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TufChangeNote&&(identical(other.ar, _this.ar) || other.ar == _this.ar)&&(identical(other.en, _this.en) || other.en == _this.en));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TufChangeNote;
  return Object.hash(runtimeType,_this.ar,_this.en);
}

@override
String toString() {
  final _this = this as TufChangeNote;
  return 'TufChangeNote(ar: ${_this.ar}, en: ${_this.en})';
}


}

/// @nodoc
abstract mixin class $TufChangeNoteCopyWith<$Res>  {
  factory $TufChangeNoteCopyWith(TufChangeNote value, $Res Function(TufChangeNote) _then) = _$TufChangeNoteCopyWithImpl;
@useResult
$Res call({
 String ar, String en
});




}
/// @nodoc
class _$TufChangeNoteCopyWithImpl<$Res>
    implements $TufChangeNoteCopyWith<$Res> {
  _$TufChangeNoteCopyWithImpl(this._self, this._then);

  final TufChangeNote _self;
  final $Res Function(TufChangeNote) _then;

/// Create a copy of TufChangeNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ar = null,Object? en = null,}) {
  return _then(TufChangeNote(
ar: null == ar ? _self.ar : ar // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TufChangeNote].
extension TufChangeNotePatterns on TufChangeNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TufChangeNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TufChangeNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TufChangeNote value)  $default,){
final _that = this;
switch (_that) {
case _TufChangeNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TufChangeNote value)?  $default,){
final _that = this;
switch (_that) {
case _TufChangeNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ar,  String en)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TufChangeNote() when $default != null:
return $default(_that.ar,_that.en);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ar,  String en)  $default,) {final _that = this;
switch (_that) {
case _TufChangeNote():
return $default(_that.ar,_that.en);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ar,  String en)?  $default,) {final _that = this;
switch (_that) {
case _TufChangeNote() when $default != null:
return $default(_that.ar,_that.en);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TufChangeNote implements TufChangeNote {
  const _TufChangeNote({required this.ar, required this.en});
  factory _TufChangeNote.fromJson(Map<String, dynamic> json) => _$TufChangeNoteFromJson(json);

/// Arabic.
@override final  String ar;
/// English.
@override final  String en;

/// Create a copy of TufChangeNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TufChangeNoteCopyWith<_TufChangeNote> get copyWith => __$TufChangeNoteCopyWithImpl<_TufChangeNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufChangeNoteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TufChangeNote&&(identical(other.ar, ar) || other.ar == ar)&&(identical(other.en, en) || other.en == en));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ar,en);
}

@override
String toString() {
    return 'TufChangeNote(ar: $ar, en: $en)';
}


}

/// @nodoc
abstract mixin class _$TufChangeNoteCopyWith<$Res> implements $TufChangeNoteCopyWith<$Res> {
  factory _$TufChangeNoteCopyWith(_TufChangeNote value, $Res Function(_TufChangeNote) _then) = __$TufChangeNoteCopyWithImpl;
@override @useResult
$Res call({
 String ar, String en
});




}
/// @nodoc
class __$TufChangeNoteCopyWithImpl<$Res>
    implements _$TufChangeNoteCopyWith<$Res> {
  __$TufChangeNoteCopyWithImpl(this._self, this._then);

  final _TufChangeNote _self;
  final $Res Function(_TufChangeNote) _then;

/// Create a copy of TufChangeNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ar = null,Object? en = null,}) {
  return _then(_TufChangeNote(
ar: null == ar ? _self.ar : ar // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
