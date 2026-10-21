// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'authority_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthorityDocument {

/// Display name.
 String get name;/// Authority type.
 AuthorityTypeCode get type;
/// Create a copy of AuthorityDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthorityDocumentCopyWith<AuthorityDocument> get copyWith => _$AuthorityDocumentCopyWithImpl<AuthorityDocument>(this as AuthorityDocument, _$identity);

  /// Serializes this AuthorityDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthorityDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthorityDocument&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthorityDocument;
  return Object.hash(runtimeType,_this.name,_this.type);
}

@override
String toString() {
  final _this = this as AuthorityDocument;
  return 'AuthorityDocument(name: ${_this.name}, type: ${_this.type})';
}


}

/// @nodoc
abstract mixin class $AuthorityDocumentCopyWith<$Res>  {
  factory $AuthorityDocumentCopyWith(AuthorityDocument value, $Res Function(AuthorityDocument) _then) = _$AuthorityDocumentCopyWithImpl;
@useResult
$Res call({
 String name, AuthorityTypeCode type
});




}
/// @nodoc
class _$AuthorityDocumentCopyWithImpl<$Res>
    implements $AuthorityDocumentCopyWith<$Res> {
  _$AuthorityDocumentCopyWithImpl(this._self, this._then);

  final AuthorityDocument _self;
  final $Res Function(AuthorityDocument) _then;

/// Create a copy of AuthorityDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,}) {
  return _then(AuthorityDocument(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AuthorityTypeCode,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthorityDocument].
extension AuthorityDocumentPatterns on AuthorityDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthorityDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthorityDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthorityDocument value)  $default,){
final _that = this;
switch (_that) {
case _AuthorityDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthorityDocument value)?  $default,){
final _that = this;
switch (_that) {
case _AuthorityDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  AuthorityTypeCode type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthorityDocument() when $default != null:
return $default(_that.name,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  AuthorityTypeCode type)  $default,) {final _that = this;
switch (_that) {
case _AuthorityDocument():
return $default(_that.name,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  AuthorityTypeCode type)?  $default,) {final _that = this;
switch (_that) {
case _AuthorityDocument() when $default != null:
return $default(_that.name,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthorityDocument implements AuthorityDocument {
  const _AuthorityDocument({required this.name, required this.type});
  factory _AuthorityDocument.fromJson(Map<String, dynamic> json) => _$AuthorityDocumentFromJson(json);

/// Display name.
@override final  String name;
/// Authority type.
@override final  AuthorityTypeCode type;

/// Create a copy of AuthorityDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthorityDocumentCopyWith<_AuthorityDocument> get copyWith => __$AuthorityDocumentCopyWithImpl<_AuthorityDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthorityDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthorityDocument&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,type);
}

@override
String toString() {
    return 'AuthorityDocument(name: $name, type: $type)';
}


}

/// @nodoc
abstract mixin class _$AuthorityDocumentCopyWith<$Res> implements $AuthorityDocumentCopyWith<$Res> {
  factory _$AuthorityDocumentCopyWith(_AuthorityDocument value, $Res Function(_AuthorityDocument) _then) = __$AuthorityDocumentCopyWithImpl;
@override @useResult
$Res call({
 String name, AuthorityTypeCode type
});




}
/// @nodoc
class __$AuthorityDocumentCopyWithImpl<$Res>
    implements _$AuthorityDocumentCopyWith<$Res> {
  __$AuthorityDocumentCopyWithImpl(this._self, this._then);

  final _AuthorityDocument _self;
  final $Res Function(_AuthorityDocument) _then;

/// Create a copy of AuthorityDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,}) {
  return _then(_AuthorityDocument(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AuthorityTypeCode,
  ));
}


}

// dart format on
