// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hijri_package_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HijriPackageDocument {

/// ISO 3166-1 alpha-2 source country.
 String get country;/// Month starts.
 List<HijriMonthDocument> get months;
/// Create a copy of HijriPackageDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HijriPackageDocumentCopyWith<HijriPackageDocument> get copyWith => _$HijriPackageDocumentCopyWithImpl<HijriPackageDocument>(this as HijriPackageDocument, _$identity);

  /// Serializes this HijriPackageDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HijriPackageDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HijriPackageDocument&&(identical(other.country, _this.country) || other.country == _this.country)&&const DeepCollectionEquality().equals(other.months, _this.months));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HijriPackageDocument;
  return Object.hash(runtimeType,_this.country,const DeepCollectionEquality().hash(_this.months));
}

@override
String toString() {
  final _this = this as HijriPackageDocument;
  return 'HijriPackageDocument(country: ${_this.country}, months: ${_this.months})';
}


}

/// @nodoc
abstract mixin class $HijriPackageDocumentCopyWith<$Res>  {
  factory $HijriPackageDocumentCopyWith(HijriPackageDocument value, $Res Function(HijriPackageDocument) _then) = _$HijriPackageDocumentCopyWithImpl;
@useResult
$Res call({
 String country, List<HijriMonthDocument> months
});




}
/// @nodoc
class _$HijriPackageDocumentCopyWithImpl<$Res>
    implements $HijriPackageDocumentCopyWith<$Res> {
  _$HijriPackageDocumentCopyWithImpl(this._self, this._then);

  final HijriPackageDocument _self;
  final $Res Function(HijriPackageDocument) _then;

/// Create a copy of HijriPackageDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? country = null,Object? months = null,}) {
  return _then(HijriPackageDocument(
country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,months: null == months ? _self.months : months // ignore: cast_nullable_to_non_nullable
as List<HijriMonthDocument>,
  ));
}

}


/// Adds pattern-matching-related methods to [HijriPackageDocument].
extension HijriPackageDocumentPatterns on HijriPackageDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HijriPackageDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HijriPackageDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HijriPackageDocument value)  $default,){
final _that = this;
switch (_that) {
case _HijriPackageDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HijriPackageDocument value)?  $default,){
final _that = this;
switch (_that) {
case _HijriPackageDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String country,  List<HijriMonthDocument> months)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HijriPackageDocument() when $default != null:
return $default(_that.country,_that.months);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String country,  List<HijriMonthDocument> months)  $default,) {final _that = this;
switch (_that) {
case _HijriPackageDocument():
return $default(_that.country,_that.months);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String country,  List<HijriMonthDocument> months)?  $default,) {final _that = this;
switch (_that) {
case _HijriPackageDocument() when $default != null:
return $default(_that.country,_that.months);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HijriPackageDocument implements HijriPackageDocument {
  const _HijriPackageDocument({required this.country, required  List<HijriMonthDocument> months}): _months = months;
  factory _HijriPackageDocument.fromJson(Map<String, dynamic> json) => _$HijriPackageDocumentFromJson(json);

/// ISO 3166-1 alpha-2 source country.
@override final  String country;
/// Month starts.
 final  List<HijriMonthDocument> _months;
/// Month starts.
@override List<HijriMonthDocument> get months {
  if (_months is EqualUnmodifiableListView) return _months;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_months);
}


/// Create a copy of HijriPackageDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HijriPackageDocumentCopyWith<_HijriPackageDocument> get copyWith => __$HijriPackageDocumentCopyWithImpl<_HijriPackageDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HijriPackageDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HijriPackageDocument&&(identical(other.country, country) || other.country == country)&&const DeepCollectionEquality().equals(other.months, _months));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,country,const DeepCollectionEquality().hash(_months));
}

@override
String toString() {
    return 'HijriPackageDocument(country: $country, months: $months)';
}


}

/// @nodoc
abstract mixin class _$HijriPackageDocumentCopyWith<$Res> implements $HijriPackageDocumentCopyWith<$Res> {
  factory _$HijriPackageDocumentCopyWith(_HijriPackageDocument value, $Res Function(_HijriPackageDocument) _then) = __$HijriPackageDocumentCopyWithImpl;
@override @useResult
$Res call({
 String country, List<HijriMonthDocument> months
});




}
/// @nodoc
class __$HijriPackageDocumentCopyWithImpl<$Res>
    implements _$HijriPackageDocumentCopyWith<$Res> {
  __$HijriPackageDocumentCopyWithImpl(this._self, this._then);

  final _HijriPackageDocument _self;
  final $Res Function(_HijriPackageDocument) _then;

/// Create a copy of HijriPackageDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? country = null,Object? months = null,}) {
  return _then(_HijriPackageDocument(
country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,months: null == months ? _self._months : months // ignore: cast_nullable_to_non_nullable
as List<HijriMonthDocument>,
  ));
}


}

// dart format on
