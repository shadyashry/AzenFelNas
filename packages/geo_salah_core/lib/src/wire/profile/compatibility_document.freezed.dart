// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compatibility_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CompatibilityDocument {

/// Minimum engine schema.
 int get minEngineSchema;/// Minimum app version.
 String get minAppVersion;
/// Create a copy of CompatibilityDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompatibilityDocumentCopyWith<CompatibilityDocument> get copyWith => _$CompatibilityDocumentCopyWithImpl<CompatibilityDocument>(this as CompatibilityDocument, _$identity);

  /// Serializes this CompatibilityDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CompatibilityDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompatibilityDocument&&(identical(other.minEngineSchema, _this.minEngineSchema) || other.minEngineSchema == _this.minEngineSchema)&&(identical(other.minAppVersion, _this.minAppVersion) || other.minAppVersion == _this.minAppVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CompatibilityDocument;
  return Object.hash(runtimeType,_this.minEngineSchema,_this.minAppVersion);
}

@override
String toString() {
  final _this = this as CompatibilityDocument;
  return 'CompatibilityDocument(minEngineSchema: ${_this.minEngineSchema}, minAppVersion: ${_this.minAppVersion})';
}


}

/// @nodoc
abstract mixin class $CompatibilityDocumentCopyWith<$Res>  {
  factory $CompatibilityDocumentCopyWith(CompatibilityDocument value, $Res Function(CompatibilityDocument) _then) = _$CompatibilityDocumentCopyWithImpl;
@useResult
$Res call({
 int minEngineSchema, String minAppVersion
});




}
/// @nodoc
class _$CompatibilityDocumentCopyWithImpl<$Res>
    implements $CompatibilityDocumentCopyWith<$Res> {
  _$CompatibilityDocumentCopyWithImpl(this._self, this._then);

  final CompatibilityDocument _self;
  final $Res Function(CompatibilityDocument) _then;

/// Create a copy of CompatibilityDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minEngineSchema = null,Object? minAppVersion = null,}) {
  return _then(CompatibilityDocument(
minEngineSchema: null == minEngineSchema ? _self.minEngineSchema : minEngineSchema // ignore: cast_nullable_to_non_nullable
as int,minAppVersion: null == minAppVersion ? _self.minAppVersion : minAppVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CompatibilityDocument].
extension CompatibilityDocumentPatterns on CompatibilityDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompatibilityDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompatibilityDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompatibilityDocument value)  $default,){
final _that = this;
switch (_that) {
case _CompatibilityDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompatibilityDocument value)?  $default,){
final _that = this;
switch (_that) {
case _CompatibilityDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int minEngineSchema,  String minAppVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompatibilityDocument() when $default != null:
return $default(_that.minEngineSchema,_that.minAppVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int minEngineSchema,  String minAppVersion)  $default,) {final _that = this;
switch (_that) {
case _CompatibilityDocument():
return $default(_that.minEngineSchema,_that.minAppVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int minEngineSchema,  String minAppVersion)?  $default,) {final _that = this;
switch (_that) {
case _CompatibilityDocument() when $default != null:
return $default(_that.minEngineSchema,_that.minAppVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompatibilityDocument implements CompatibilityDocument {
  const _CompatibilityDocument({required this.minEngineSchema, required this.minAppVersion});
  factory _CompatibilityDocument.fromJson(Map<String, dynamic> json) => _$CompatibilityDocumentFromJson(json);

/// Minimum engine schema.
@override final  int minEngineSchema;
/// Minimum app version.
@override final  String minAppVersion;

/// Create a copy of CompatibilityDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompatibilityDocumentCopyWith<_CompatibilityDocument> get copyWith => __$CompatibilityDocumentCopyWithImpl<_CompatibilityDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompatibilityDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompatibilityDocument&&(identical(other.minEngineSchema, minEngineSchema) || other.minEngineSchema == minEngineSchema)&&(identical(other.minAppVersion, minAppVersion) || other.minAppVersion == minAppVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,minEngineSchema,minAppVersion);
}

@override
String toString() {
    return 'CompatibilityDocument(minEngineSchema: $minEngineSchema, minAppVersion: $minAppVersion)';
}


}

/// @nodoc
abstract mixin class _$CompatibilityDocumentCopyWith<$Res> implements $CompatibilityDocumentCopyWith<$Res> {
  factory _$CompatibilityDocumentCopyWith(_CompatibilityDocument value, $Res Function(_CompatibilityDocument) _then) = __$CompatibilityDocumentCopyWithImpl;
@override @useResult
$Res call({
 int minEngineSchema, String minAppVersion
});




}
/// @nodoc
class __$CompatibilityDocumentCopyWithImpl<$Res>
    implements _$CompatibilityDocumentCopyWith<$Res> {
  __$CompatibilityDocumentCopyWithImpl(this._self, this._then);

  final _CompatibilityDocument _self;
  final $Res Function(_CompatibilityDocument) _then;

/// Create a copy of CompatibilityDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minEngineSchema = null,Object? minAppVersion = null,}) {
  return _then(_CompatibilityDocument(
minEngineSchema: null == minEngineSchema ? _self.minEngineSchema : minEngineSchema // ignore: cast_nullable_to_non_nullable
as int,minAppVersion: null == minAppVersion ? _self.minAppVersion : minAppVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
