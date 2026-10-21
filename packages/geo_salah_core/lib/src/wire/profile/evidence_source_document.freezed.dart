// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'evidence_source_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EvidenceSourceDocument {

/// Title.
 String get title;/// URL.
 String get url;/// Retrieval date, `YYYY-MM-DD`.
 String get retrievedOn;/// SHA-256 of the retrieved document.
 String get sha256;
/// Create a copy of EvidenceSourceDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvidenceSourceDocumentCopyWith<EvidenceSourceDocument> get copyWith => _$EvidenceSourceDocumentCopyWithImpl<EvidenceSourceDocument>(this as EvidenceSourceDocument, _$identity);

  /// Serializes this EvidenceSourceDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EvidenceSourceDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EvidenceSourceDocument&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.retrievedOn, _this.retrievedOn) || other.retrievedOn == _this.retrievedOn)&&(identical(other.sha256, _this.sha256) || other.sha256 == _this.sha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EvidenceSourceDocument;
  return Object.hash(runtimeType,_this.title,_this.url,_this.retrievedOn,_this.sha256);
}

@override
String toString() {
  final _this = this as EvidenceSourceDocument;
  return 'EvidenceSourceDocument(title: ${_this.title}, url: ${_this.url}, retrievedOn: ${_this.retrievedOn}, sha256: ${_this.sha256})';
}


}

/// @nodoc
abstract mixin class $EvidenceSourceDocumentCopyWith<$Res>  {
  factory $EvidenceSourceDocumentCopyWith(EvidenceSourceDocument value, $Res Function(EvidenceSourceDocument) _then) = _$EvidenceSourceDocumentCopyWithImpl;
@useResult
$Res call({
 String title, String url, String retrievedOn, String sha256
});




}
/// @nodoc
class _$EvidenceSourceDocumentCopyWithImpl<$Res>
    implements $EvidenceSourceDocumentCopyWith<$Res> {
  _$EvidenceSourceDocumentCopyWithImpl(this._self, this._then);

  final EvidenceSourceDocument _self;
  final $Res Function(EvidenceSourceDocument) _then;

/// Create a copy of EvidenceSourceDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? url = null,Object? retrievedOn = null,Object? sha256 = null,}) {
  return _then(EvidenceSourceDocument(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,retrievedOn: null == retrievedOn ? _self.retrievedOn : retrievedOn // ignore: cast_nullable_to_non_nullable
as String,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EvidenceSourceDocument].
extension EvidenceSourceDocumentPatterns on EvidenceSourceDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EvidenceSourceDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EvidenceSourceDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EvidenceSourceDocument value)  $default,){
final _that = this;
switch (_that) {
case _EvidenceSourceDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EvidenceSourceDocument value)?  $default,){
final _that = this;
switch (_that) {
case _EvidenceSourceDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String url,  String retrievedOn,  String sha256)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EvidenceSourceDocument() when $default != null:
return $default(_that.title,_that.url,_that.retrievedOn,_that.sha256);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String url,  String retrievedOn,  String sha256)  $default,) {final _that = this;
switch (_that) {
case _EvidenceSourceDocument():
return $default(_that.title,_that.url,_that.retrievedOn,_that.sha256);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String url,  String retrievedOn,  String sha256)?  $default,) {final _that = this;
switch (_that) {
case _EvidenceSourceDocument() when $default != null:
return $default(_that.title,_that.url,_that.retrievedOn,_that.sha256);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EvidenceSourceDocument implements EvidenceSourceDocument {
  const _EvidenceSourceDocument({required this.title, required this.url, required this.retrievedOn, required this.sha256});
  factory _EvidenceSourceDocument.fromJson(Map<String, dynamic> json) => _$EvidenceSourceDocumentFromJson(json);

/// Title.
@override final  String title;
/// URL.
@override final  String url;
/// Retrieval date, `YYYY-MM-DD`.
@override final  String retrievedOn;
/// SHA-256 of the retrieved document.
@override final  String sha256;

/// Create a copy of EvidenceSourceDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EvidenceSourceDocumentCopyWith<_EvidenceSourceDocument> get copyWith => __$EvidenceSourceDocumentCopyWithImpl<_EvidenceSourceDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EvidenceSourceDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EvidenceSourceDocument&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.retrievedOn, retrievedOn) || other.retrievedOn == retrievedOn)&&(identical(other.sha256, sha256) || other.sha256 == sha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,title,url,retrievedOn,sha256);
}

@override
String toString() {
    return 'EvidenceSourceDocument(title: $title, url: $url, retrievedOn: $retrievedOn, sha256: $sha256)';
}


}

/// @nodoc
abstract mixin class _$EvidenceSourceDocumentCopyWith<$Res> implements $EvidenceSourceDocumentCopyWith<$Res> {
  factory _$EvidenceSourceDocumentCopyWith(_EvidenceSourceDocument value, $Res Function(_EvidenceSourceDocument) _then) = __$EvidenceSourceDocumentCopyWithImpl;
@override @useResult
$Res call({
 String title, String url, String retrievedOn, String sha256
});




}
/// @nodoc
class __$EvidenceSourceDocumentCopyWithImpl<$Res>
    implements _$EvidenceSourceDocumentCopyWith<$Res> {
  __$EvidenceSourceDocumentCopyWithImpl(this._self, this._then);

  final _EvidenceSourceDocument _self;
  final $Res Function(_EvidenceSourceDocument) _then;

/// Create a copy of EvidenceSourceDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? url = null,Object? retrievedOn = null,Object? sha256 = null,}) {
  return _then(_EvidenceSourceDocument(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,retrievedOn: null == retrievedOn ? _self.retrievedOn : retrievedOn // ignore: cast_nullable_to_non_nullable
as String,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
