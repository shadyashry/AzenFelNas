// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'horizon_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HorizonDocument {

/// Elevation policy.
 ElevationPolicyCode get elevationPolicy;
/// Create a copy of HorizonDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HorizonDocumentCopyWith<HorizonDocument> get copyWith => _$HorizonDocumentCopyWithImpl<HorizonDocument>(this as HorizonDocument, _$identity);

  /// Serializes this HorizonDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HorizonDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HorizonDocument&&(identical(other.elevationPolicy, _this.elevationPolicy) || other.elevationPolicy == _this.elevationPolicy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HorizonDocument;
  return Object.hash(runtimeType,_this.elevationPolicy);
}

@override
String toString() {
  final _this = this as HorizonDocument;
  return 'HorizonDocument(elevationPolicy: ${_this.elevationPolicy})';
}


}

/// @nodoc
abstract mixin class $HorizonDocumentCopyWith<$Res>  {
  factory $HorizonDocumentCopyWith(HorizonDocument value, $Res Function(HorizonDocument) _then) = _$HorizonDocumentCopyWithImpl;
@useResult
$Res call({
 ElevationPolicyCode elevationPolicy
});




}
/// @nodoc
class _$HorizonDocumentCopyWithImpl<$Res>
    implements $HorizonDocumentCopyWith<$Res> {
  _$HorizonDocumentCopyWithImpl(this._self, this._then);

  final HorizonDocument _self;
  final $Res Function(HorizonDocument) _then;

/// Create a copy of HorizonDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? elevationPolicy = null,}) {
  return _then(HorizonDocument(
elevationPolicy: null == elevationPolicy ? _self.elevationPolicy : elevationPolicy // ignore: cast_nullable_to_non_nullable
as ElevationPolicyCode,
  ));
}

}


/// Adds pattern-matching-related methods to [HorizonDocument].
extension HorizonDocumentPatterns on HorizonDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HorizonDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HorizonDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HorizonDocument value)  $default,){
final _that = this;
switch (_that) {
case _HorizonDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HorizonDocument value)?  $default,){
final _that = this;
switch (_that) {
case _HorizonDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ElevationPolicyCode elevationPolicy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HorizonDocument() when $default != null:
return $default(_that.elevationPolicy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ElevationPolicyCode elevationPolicy)  $default,) {final _that = this;
switch (_that) {
case _HorizonDocument():
return $default(_that.elevationPolicy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ElevationPolicyCode elevationPolicy)?  $default,) {final _that = this;
switch (_that) {
case _HorizonDocument() when $default != null:
return $default(_that.elevationPolicy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HorizonDocument implements HorizonDocument {
  const _HorizonDocument({required this.elevationPolicy});
  factory _HorizonDocument.fromJson(Map<String, dynamic> json) => _$HorizonDocumentFromJson(json);

/// Elevation policy.
@override final  ElevationPolicyCode elevationPolicy;

/// Create a copy of HorizonDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HorizonDocumentCopyWith<_HorizonDocument> get copyWith => __$HorizonDocumentCopyWithImpl<_HorizonDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HorizonDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HorizonDocument&&(identical(other.elevationPolicy, elevationPolicy) || other.elevationPolicy == elevationPolicy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,elevationPolicy);
}

@override
String toString() {
    return 'HorizonDocument(elevationPolicy: $elevationPolicy)';
}


}

/// @nodoc
abstract mixin class _$HorizonDocumentCopyWith<$Res> implements $HorizonDocumentCopyWith<$Res> {
  factory _$HorizonDocumentCopyWith(_HorizonDocument value, $Res Function(_HorizonDocument) _then) = __$HorizonDocumentCopyWithImpl;
@override @useResult
$Res call({
 ElevationPolicyCode elevationPolicy
});




}
/// @nodoc
class __$HorizonDocumentCopyWithImpl<$Res>
    implements _$HorizonDocumentCopyWith<$Res> {
  __$HorizonDocumentCopyWithImpl(this._self, this._then);

  final _HorizonDocument _self;
  final $Res Function(_HorizonDocument) _then;

/// Create a copy of HorizonDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? elevationPolicy = null,}) {
  return _then(_HorizonDocument(
elevationPolicy: null == elevationPolicy ? _self.elevationPolicy : elevationPolicy // ignore: cast_nullable_to_non_nullable
as ElevationPolicyCode,
  ));
}


}

// dart format on
