// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_scope_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileScopeDocument {

/// ISO 3166-1 alpha-2 codes, or `*` for all.
 List<String> get countries;/// Polygon set reference (deferred to V1); always written, `null` when
/// unset.
@JsonKey(includeIfNull: true) String? get polygonsRef;/// ISO 3166-2 codes (deferred to V1).
 List<String> get adminAreas;
/// Create a copy of ProfileScopeDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileScopeDocumentCopyWith<ProfileScopeDocument> get copyWith => _$ProfileScopeDocumentCopyWithImpl<ProfileScopeDocument>(this as ProfileScopeDocument, _$identity);

  /// Serializes this ProfileScopeDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProfileScopeDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileScopeDocument&&const DeepCollectionEquality().equals(other.countries, _this.countries)&&(identical(other.polygonsRef, _this.polygonsRef) || other.polygonsRef == _this.polygonsRef)&&const DeepCollectionEquality().equals(other.adminAreas, _this.adminAreas));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProfileScopeDocument;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.countries),_this.polygonsRef,const DeepCollectionEquality().hash(_this.adminAreas));
}

@override
String toString() {
  final _this = this as ProfileScopeDocument;
  return 'ProfileScopeDocument(countries: ${_this.countries}, polygonsRef: ${_this.polygonsRef}, adminAreas: ${_this.adminAreas})';
}


}

/// @nodoc
abstract mixin class $ProfileScopeDocumentCopyWith<$Res>  {
  factory $ProfileScopeDocumentCopyWith(ProfileScopeDocument value, $Res Function(ProfileScopeDocument) _then) = _$ProfileScopeDocumentCopyWithImpl;
@useResult
$Res call({
 List<String> countries,@JsonKey(includeIfNull: true) String? polygonsRef, List<String> adminAreas
});




}
/// @nodoc
class _$ProfileScopeDocumentCopyWithImpl<$Res>
    implements $ProfileScopeDocumentCopyWith<$Res> {
  _$ProfileScopeDocumentCopyWithImpl(this._self, this._then);

  final ProfileScopeDocument _self;
  final $Res Function(ProfileScopeDocument) _then;

/// Create a copy of ProfileScopeDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? countries = null,Object? polygonsRef = freezed,Object? adminAreas = null,}) {
  return _then(ProfileScopeDocument(
countries: null == countries ? _self.countries : countries // ignore: cast_nullable_to_non_nullable
as List<String>,polygonsRef: freezed == polygonsRef ? _self.polygonsRef : polygonsRef // ignore: cast_nullable_to_non_nullable
as String?,adminAreas: null == adminAreas ? _self.adminAreas : adminAreas // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileScopeDocument].
extension ProfileScopeDocumentPatterns on ProfileScopeDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileScopeDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileScopeDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileScopeDocument value)  $default,){
final _that = this;
switch (_that) {
case _ProfileScopeDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileScopeDocument value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileScopeDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> countries, @JsonKey(includeIfNull: true)  String? polygonsRef,  List<String> adminAreas)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileScopeDocument() when $default != null:
return $default(_that.countries,_that.polygonsRef,_that.adminAreas);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> countries, @JsonKey(includeIfNull: true)  String? polygonsRef,  List<String> adminAreas)  $default,) {final _that = this;
switch (_that) {
case _ProfileScopeDocument():
return $default(_that.countries,_that.polygonsRef,_that.adminAreas);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> countries, @JsonKey(includeIfNull: true)  String? polygonsRef,  List<String> adminAreas)?  $default,) {final _that = this;
switch (_that) {
case _ProfileScopeDocument() when $default != null:
return $default(_that.countries,_that.polygonsRef,_that.adminAreas);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileScopeDocument implements ProfileScopeDocument {
  const _ProfileScopeDocument({required  List<String> countries, @JsonKey(includeIfNull: true) required this.polygonsRef,  List<String> adminAreas = const <String>[]}): _countries = countries,_adminAreas = adminAreas;
  factory _ProfileScopeDocument.fromJson(Map<String, dynamic> json) => _$ProfileScopeDocumentFromJson(json);

/// ISO 3166-1 alpha-2 codes, or `*` for all.
 final  List<String> _countries;
/// ISO 3166-1 alpha-2 codes, or `*` for all.
@override List<String> get countries {
  if (_countries is EqualUnmodifiableListView) return _countries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_countries);
}

/// Polygon set reference (deferred to V1); always written, `null` when
/// unset.
@override@JsonKey(includeIfNull: true) final  String? polygonsRef;
/// ISO 3166-2 codes (deferred to V1).
 final  List<String> _adminAreas;
/// ISO 3166-2 codes (deferred to V1).
@override@JsonKey() List<String> get adminAreas {
  if (_adminAreas is EqualUnmodifiableListView) return _adminAreas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_adminAreas);
}


/// Create a copy of ProfileScopeDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileScopeDocumentCopyWith<_ProfileScopeDocument> get copyWith => __$ProfileScopeDocumentCopyWithImpl<_ProfileScopeDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileScopeDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileScopeDocument&&const DeepCollectionEquality().equals(other.countries, _countries)&&(identical(other.polygonsRef, polygonsRef) || other.polygonsRef == polygonsRef)&&const DeepCollectionEquality().equals(other.adminAreas, _adminAreas));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_countries),polygonsRef,const DeepCollectionEquality().hash(_adminAreas));
}

@override
String toString() {
    return 'ProfileScopeDocument(countries: $countries, polygonsRef: $polygonsRef, adminAreas: $adminAreas)';
}


}

/// @nodoc
abstract mixin class _$ProfileScopeDocumentCopyWith<$Res> implements $ProfileScopeDocumentCopyWith<$Res> {
  factory _$ProfileScopeDocumentCopyWith(_ProfileScopeDocument value, $Res Function(_ProfileScopeDocument) _then) = __$ProfileScopeDocumentCopyWithImpl;
@override @useResult
$Res call({
 List<String> countries,@JsonKey(includeIfNull: true) String? polygonsRef, List<String> adminAreas
});




}
/// @nodoc
class __$ProfileScopeDocumentCopyWithImpl<$Res>
    implements _$ProfileScopeDocumentCopyWith<$Res> {
  __$ProfileScopeDocumentCopyWithImpl(this._self, this._then);

  final _ProfileScopeDocument _self;
  final $Res Function(_ProfileScopeDocument) _then;

/// Create a copy of ProfileScopeDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? countries = null,Object? polygonsRef = freezed,Object? adminAreas = null,}) {
  return _then(_ProfileScopeDocument(
countries: null == countries ? _self._countries : countries // ignore: cast_nullable_to_non_nullable
as List<String>,polygonsRef: freezed == polygonsRef ? _self.polygonsRef : polygonsRef // ignore: cast_nullable_to_non_nullable
as String?,adminAreas: null == adminAreas ? _self._adminAreas : adminAreas // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
