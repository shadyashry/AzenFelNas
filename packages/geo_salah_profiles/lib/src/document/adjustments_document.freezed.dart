// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'adjustments_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdjustmentsDocument {

/// Largest allowed absolute offset.
 int get maxAbsMinutes;/// Minute offset per event name.
 Map<String, int> get perEventMinutes;/// Replacement rule per event name during Ramadan.
 Map<String, RuleDocument> get ramadan;
/// Create a copy of AdjustmentsDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdjustmentsDocumentCopyWith<AdjustmentsDocument> get copyWith => _$AdjustmentsDocumentCopyWithImpl<AdjustmentsDocument>(this as AdjustmentsDocument, _$identity);

  /// Serializes this AdjustmentsDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdjustmentsDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdjustmentsDocument&&(identical(other.maxAbsMinutes, _this.maxAbsMinutes) || other.maxAbsMinutes == _this.maxAbsMinutes)&&const DeepCollectionEquality().equals(other.perEventMinutes, _this.perEventMinutes)&&const DeepCollectionEquality().equals(other.ramadan, _this.ramadan));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdjustmentsDocument;
  return Object.hash(runtimeType,_this.maxAbsMinutes,const DeepCollectionEquality().hash(_this.perEventMinutes),const DeepCollectionEquality().hash(_this.ramadan));
}

@override
String toString() {
  final _this = this as AdjustmentsDocument;
  return 'AdjustmentsDocument(maxAbsMinutes: ${_this.maxAbsMinutes}, perEventMinutes: ${_this.perEventMinutes}, ramadan: ${_this.ramadan})';
}


}

/// @nodoc
abstract mixin class $AdjustmentsDocumentCopyWith<$Res>  {
  factory $AdjustmentsDocumentCopyWith(AdjustmentsDocument value, $Res Function(AdjustmentsDocument) _then) = _$AdjustmentsDocumentCopyWithImpl;
@useResult
$Res call({
 int maxAbsMinutes, Map<String, int> perEventMinutes, Map<String, RuleDocument> ramadan
});




}
/// @nodoc
class _$AdjustmentsDocumentCopyWithImpl<$Res>
    implements $AdjustmentsDocumentCopyWith<$Res> {
  _$AdjustmentsDocumentCopyWithImpl(this._self, this._then);

  final AdjustmentsDocument _self;
  final $Res Function(AdjustmentsDocument) _then;

/// Create a copy of AdjustmentsDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxAbsMinutes = null,Object? perEventMinutes = null,Object? ramadan = null,}) {
  return _then(AdjustmentsDocument(
maxAbsMinutes: null == maxAbsMinutes ? _self.maxAbsMinutes : maxAbsMinutes // ignore: cast_nullable_to_non_nullable
as int,perEventMinutes: null == perEventMinutes ? _self.perEventMinutes : perEventMinutes // ignore: cast_nullable_to_non_nullable
as Map<String, int>,ramadan: null == ramadan ? _self.ramadan : ramadan // ignore: cast_nullable_to_non_nullable
as Map<String, RuleDocument>,
  ));
}

}


/// Adds pattern-matching-related methods to [AdjustmentsDocument].
extension AdjustmentsDocumentPatterns on AdjustmentsDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdjustmentsDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdjustmentsDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdjustmentsDocument value)  $default,){
final _that = this;
switch (_that) {
case _AdjustmentsDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdjustmentsDocument value)?  $default,){
final _that = this;
switch (_that) {
case _AdjustmentsDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int maxAbsMinutes,  Map<String, int> perEventMinutes,  Map<String, RuleDocument> ramadan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdjustmentsDocument() when $default != null:
return $default(_that.maxAbsMinutes,_that.perEventMinutes,_that.ramadan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int maxAbsMinutes,  Map<String, int> perEventMinutes,  Map<String, RuleDocument> ramadan)  $default,) {final _that = this;
switch (_that) {
case _AdjustmentsDocument():
return $default(_that.maxAbsMinutes,_that.perEventMinutes,_that.ramadan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int maxAbsMinutes,  Map<String, int> perEventMinutes,  Map<String, RuleDocument> ramadan)?  $default,) {final _that = this;
switch (_that) {
case _AdjustmentsDocument() when $default != null:
return $default(_that.maxAbsMinutes,_that.perEventMinutes,_that.ramadan);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdjustmentsDocument implements AdjustmentsDocument {
  const _AdjustmentsDocument({required this.maxAbsMinutes,  Map<String, int> perEventMinutes = const <String, int>{},  Map<String, RuleDocument> ramadan = const <String, RuleDocument>{}}): _perEventMinutes = perEventMinutes,_ramadan = ramadan;
  factory _AdjustmentsDocument.fromJson(Map<String, dynamic> json) => _$AdjustmentsDocumentFromJson(json);

/// Largest allowed absolute offset.
@override final  int maxAbsMinutes;
/// Minute offset per event name.
 final  Map<String, int> _perEventMinutes;
/// Minute offset per event name.
@override@JsonKey() Map<String, int> get perEventMinutes {
  if (_perEventMinutes is EqualUnmodifiableMapView) return _perEventMinutes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_perEventMinutes);
}

/// Replacement rule per event name during Ramadan.
 final  Map<String, RuleDocument> _ramadan;
/// Replacement rule per event name during Ramadan.
@override@JsonKey() Map<String, RuleDocument> get ramadan {
  if (_ramadan is EqualUnmodifiableMapView) return _ramadan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ramadan);
}


/// Create a copy of AdjustmentsDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdjustmentsDocumentCopyWith<_AdjustmentsDocument> get copyWith => __$AdjustmentsDocumentCopyWithImpl<_AdjustmentsDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdjustmentsDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdjustmentsDocument&&(identical(other.maxAbsMinutes, maxAbsMinutes) || other.maxAbsMinutes == maxAbsMinutes)&&const DeepCollectionEquality().equals(other.perEventMinutes, _perEventMinutes)&&const DeepCollectionEquality().equals(other.ramadan, _ramadan));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,maxAbsMinutes,const DeepCollectionEquality().hash(_perEventMinutes),const DeepCollectionEquality().hash(_ramadan));
}

@override
String toString() {
    return 'AdjustmentsDocument(maxAbsMinutes: $maxAbsMinutes, perEventMinutes: $perEventMinutes, ramadan: $ramadan)';
}


}

/// @nodoc
abstract mixin class _$AdjustmentsDocumentCopyWith<$Res> implements $AdjustmentsDocumentCopyWith<$Res> {
  factory _$AdjustmentsDocumentCopyWith(_AdjustmentsDocument value, $Res Function(_AdjustmentsDocument) _then) = __$AdjustmentsDocumentCopyWithImpl;
@override @useResult
$Res call({
 int maxAbsMinutes, Map<String, int> perEventMinutes, Map<String, RuleDocument> ramadan
});




}
/// @nodoc
class __$AdjustmentsDocumentCopyWithImpl<$Res>
    implements _$AdjustmentsDocumentCopyWith<$Res> {
  __$AdjustmentsDocumentCopyWithImpl(this._self, this._then);

  final _AdjustmentsDocument _self;
  final $Res Function(_AdjustmentsDocument) _then;

/// Create a copy of AdjustmentsDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxAbsMinutes = null,Object? perEventMinutes = null,Object? ramadan = null,}) {
  return _then(_AdjustmentsDocument(
maxAbsMinutes: null == maxAbsMinutes ? _self.maxAbsMinutes : maxAbsMinutes // ignore: cast_nullable_to_non_nullable
as int,perEventMinutes: null == perEventMinutes ? _self._perEventMinutes : perEventMinutes // ignore: cast_nullable_to_non_nullable
as Map<String, int>,ramadan: null == ramadan ? _self._ramadan : ramadan // ignore: cast_nullable_to_non_nullable
as Map<String, RuleDocument>,
  ));
}


}

// dart format on
