// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'high_latitude_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HighLatitudeDocument {

/// Methods, tried in order.
@HighLatitudeMethodDocumentConverter() List<HighLatitudeMethodDocument> get chain;
/// Create a copy of HighLatitudeDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HighLatitudeDocumentCopyWith<HighLatitudeDocument> get copyWith => _$HighLatitudeDocumentCopyWithImpl<HighLatitudeDocument>(this as HighLatitudeDocument, _$identity);

  /// Serializes this HighLatitudeDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HighLatitudeDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HighLatitudeDocument&&const DeepCollectionEquality().equals(other.chain, _this.chain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HighLatitudeDocument;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.chain));
}

@override
String toString() {
  final _this = this as HighLatitudeDocument;
  return 'HighLatitudeDocument(chain: ${_this.chain})';
}


}

/// @nodoc
abstract mixin class $HighLatitudeDocumentCopyWith<$Res>  {
  factory $HighLatitudeDocumentCopyWith(HighLatitudeDocument value, $Res Function(HighLatitudeDocument) _then) = _$HighLatitudeDocumentCopyWithImpl;
@useResult
$Res call({
@HighLatitudeMethodDocumentConverter() List<HighLatitudeMethodDocument> chain
});




}
/// @nodoc
class _$HighLatitudeDocumentCopyWithImpl<$Res>
    implements $HighLatitudeDocumentCopyWith<$Res> {
  _$HighLatitudeDocumentCopyWithImpl(this._self, this._then);

  final HighLatitudeDocument _self;
  final $Res Function(HighLatitudeDocument) _then;

/// Create a copy of HighLatitudeDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chain = null,}) {
  return _then(HighLatitudeDocument(
chain: null == chain ? _self.chain : chain // ignore: cast_nullable_to_non_nullable
as List<HighLatitudeMethodDocument>,
  ));
}

}


/// Adds pattern-matching-related methods to [HighLatitudeDocument].
extension HighLatitudeDocumentPatterns on HighLatitudeDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HighLatitudeDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HighLatitudeDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HighLatitudeDocument value)  $default,){
final _that = this;
switch (_that) {
case _HighLatitudeDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HighLatitudeDocument value)?  $default,){
final _that = this;
switch (_that) {
case _HighLatitudeDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HighLatitudeMethodDocumentConverter()  List<HighLatitudeMethodDocument> chain)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HighLatitudeDocument() when $default != null:
return $default(_that.chain);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HighLatitudeMethodDocumentConverter()  List<HighLatitudeMethodDocument> chain)  $default,) {final _that = this;
switch (_that) {
case _HighLatitudeDocument():
return $default(_that.chain);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HighLatitudeMethodDocumentConverter()  List<HighLatitudeMethodDocument> chain)?  $default,) {final _that = this;
switch (_that) {
case _HighLatitudeDocument() when $default != null:
return $default(_that.chain);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HighLatitudeDocument implements HighLatitudeDocument {
  const _HighLatitudeDocument({@HighLatitudeMethodDocumentConverter() required  List<HighLatitudeMethodDocument> chain}): _chain = chain;
  factory _HighLatitudeDocument.fromJson(Map<String, dynamic> json) => _$HighLatitudeDocumentFromJson(json);

/// Methods, tried in order.
 final  List<HighLatitudeMethodDocument> _chain;
/// Methods, tried in order.
@override@HighLatitudeMethodDocumentConverter() List<HighLatitudeMethodDocument> get chain {
  if (_chain is EqualUnmodifiableListView) return _chain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chain);
}


/// Create a copy of HighLatitudeDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HighLatitudeDocumentCopyWith<_HighLatitudeDocument> get copyWith => __$HighLatitudeDocumentCopyWithImpl<_HighLatitudeDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HighLatitudeDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HighLatitudeDocument&&const DeepCollectionEquality().equals(other.chain, _chain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_chain));
}

@override
String toString() {
    return 'HighLatitudeDocument(chain: $chain)';
}


}

/// @nodoc
abstract mixin class _$HighLatitudeDocumentCopyWith<$Res> implements $HighLatitudeDocumentCopyWith<$Res> {
  factory _$HighLatitudeDocumentCopyWith(_HighLatitudeDocument value, $Res Function(_HighLatitudeDocument) _then) = __$HighLatitudeDocumentCopyWithImpl;
@override @useResult
$Res call({
@HighLatitudeMethodDocumentConverter() List<HighLatitudeMethodDocument> chain
});




}
/// @nodoc
class __$HighLatitudeDocumentCopyWithImpl<$Res>
    implements _$HighLatitudeDocumentCopyWith<$Res> {
  __$HighLatitudeDocumentCopyWithImpl(this._self, this._then);

  final _HighLatitudeDocument _self;
  final $Res Function(_HighLatitudeDocument) _then;

/// Create a copy of HighLatitudeDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chain = null,}) {
  return _then(_HighLatitudeDocument(
chain: null == chain ? _self._chain : chain // ignore: cast_nullable_to_non_nullable
as List<HighLatitudeMethodDocument>,
  ));
}


}

// dart format on
