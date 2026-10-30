// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quran_edition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuranEdition {

/// The riwayah; `hafs` only in v1.
 String get riwayah;/// The publisher of the Mushaf.
 String get publisher;/// The digital edition, e.g. `1441`.
 String get printEdition;/// Pages in the Mushaf.
 int get pageCount;/// Surahs.
 int get suraCount;/// Verses.
 int get verseCount;/// Every source with its licence.
 List<QuranSource> get sources;
/// Create a copy of QuranEdition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuranEditionCopyWith<QuranEdition> get copyWith => _$QuranEditionCopyWithImpl<QuranEdition>(this as QuranEdition, _$identity);

  /// Serializes this QuranEdition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QuranEdition;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuranEdition&&(identical(other.riwayah, _this.riwayah) || other.riwayah == _this.riwayah)&&(identical(other.publisher, _this.publisher) || other.publisher == _this.publisher)&&(identical(other.printEdition, _this.printEdition) || other.printEdition == _this.printEdition)&&(identical(other.pageCount, _this.pageCount) || other.pageCount == _this.pageCount)&&(identical(other.suraCount, _this.suraCount) || other.suraCount == _this.suraCount)&&(identical(other.verseCount, _this.verseCount) || other.verseCount == _this.verseCount)&&const DeepCollectionEquality().equals(other.sources, _this.sources));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QuranEdition;
  return Object.hash(runtimeType,_this.riwayah,_this.publisher,_this.printEdition,_this.pageCount,_this.suraCount,_this.verseCount,const DeepCollectionEquality().hash(_this.sources));
}

@override
String toString() {
  final _this = this as QuranEdition;
  return 'QuranEdition(riwayah: ${_this.riwayah}, publisher: ${_this.publisher}, printEdition: ${_this.printEdition}, pageCount: ${_this.pageCount}, suraCount: ${_this.suraCount}, verseCount: ${_this.verseCount}, sources: ${_this.sources})';
}


}

/// @nodoc
abstract mixin class $QuranEditionCopyWith<$Res>  {
  factory $QuranEditionCopyWith(QuranEdition value, $Res Function(QuranEdition) _then) = _$QuranEditionCopyWithImpl;
@useResult
$Res call({
 String riwayah, String publisher, String printEdition, int pageCount, int suraCount, int verseCount, List<QuranSource> sources
});




}
/// @nodoc
class _$QuranEditionCopyWithImpl<$Res>
    implements $QuranEditionCopyWith<$Res> {
  _$QuranEditionCopyWithImpl(this._self, this._then);

  final QuranEdition _self;
  final $Res Function(QuranEdition) _then;

/// Create a copy of QuranEdition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? riwayah = null,Object? publisher = null,Object? printEdition = null,Object? pageCount = null,Object? suraCount = null,Object? verseCount = null,Object? sources = null,}) {
  return _then(QuranEdition(
riwayah: null == riwayah ? _self.riwayah : riwayah // ignore: cast_nullable_to_non_nullable
as String,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String,printEdition: null == printEdition ? _self.printEdition : printEdition // ignore: cast_nullable_to_non_nullable
as String,pageCount: null == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int,suraCount: null == suraCount ? _self.suraCount : suraCount // ignore: cast_nullable_to_non_nullable
as int,verseCount: null == verseCount ? _self.verseCount : verseCount // ignore: cast_nullable_to_non_nullable
as int,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<QuranSource>,
  ));
}

}


/// Adds pattern-matching-related methods to [QuranEdition].
extension QuranEditionPatterns on QuranEdition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuranEdition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuranEdition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuranEdition value)  $default,){
final _that = this;
switch (_that) {
case _QuranEdition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuranEdition value)?  $default,){
final _that = this;
switch (_that) {
case _QuranEdition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String riwayah,  String publisher,  String printEdition,  int pageCount,  int suraCount,  int verseCount,  List<QuranSource> sources)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuranEdition() when $default != null:
return $default(_that.riwayah,_that.publisher,_that.printEdition,_that.pageCount,_that.suraCount,_that.verseCount,_that.sources);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String riwayah,  String publisher,  String printEdition,  int pageCount,  int suraCount,  int verseCount,  List<QuranSource> sources)  $default,) {final _that = this;
switch (_that) {
case _QuranEdition():
return $default(_that.riwayah,_that.publisher,_that.printEdition,_that.pageCount,_that.suraCount,_that.verseCount,_that.sources);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String riwayah,  String publisher,  String printEdition,  int pageCount,  int suraCount,  int verseCount,  List<QuranSource> sources)?  $default,) {final _that = this;
switch (_that) {
case _QuranEdition() when $default != null:
return $default(_that.riwayah,_that.publisher,_that.printEdition,_that.pageCount,_that.suraCount,_that.verseCount,_that.sources);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuranEdition implements QuranEdition {
  const _QuranEdition({required this.riwayah, required this.publisher, required this.printEdition, required this.pageCount, required this.suraCount, required this.verseCount, required  List<QuranSource> sources}): _sources = sources;
  factory _QuranEdition.fromJson(Map<String, dynamic> json) => _$QuranEditionFromJson(json);

/// The riwayah; `hafs` only in v1.
@override final  String riwayah;
/// The publisher of the Mushaf.
@override final  String publisher;
/// The digital edition, e.g. `1441`.
@override final  String printEdition;
/// Pages in the Mushaf.
@override final  int pageCount;
/// Surahs.
@override final  int suraCount;
/// Verses.
@override final  int verseCount;
/// Every source with its licence.
 final  List<QuranSource> _sources;
/// Every source with its licence.
@override List<QuranSource> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}


/// Create a copy of QuranEdition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuranEditionCopyWith<_QuranEdition> get copyWith => __$QuranEditionCopyWithImpl<_QuranEdition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuranEditionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuranEdition&&(identical(other.riwayah, riwayah) || other.riwayah == riwayah)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.printEdition, printEdition) || other.printEdition == printEdition)&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount)&&(identical(other.suraCount, suraCount) || other.suraCount == suraCount)&&(identical(other.verseCount, verseCount) || other.verseCount == verseCount)&&const DeepCollectionEquality().equals(other.sources, _sources));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,riwayah,publisher,printEdition,pageCount,suraCount,verseCount,const DeepCollectionEquality().hash(_sources));
}

@override
String toString() {
    return 'QuranEdition(riwayah: $riwayah, publisher: $publisher, printEdition: $printEdition, pageCount: $pageCount, suraCount: $suraCount, verseCount: $verseCount, sources: $sources)';
}


}

/// @nodoc
abstract mixin class _$QuranEditionCopyWith<$Res> implements $QuranEditionCopyWith<$Res> {
  factory _$QuranEditionCopyWith(_QuranEdition value, $Res Function(_QuranEdition) _then) = __$QuranEditionCopyWithImpl;
@override @useResult
$Res call({
 String riwayah, String publisher, String printEdition, int pageCount, int suraCount, int verseCount, List<QuranSource> sources
});




}
/// @nodoc
class __$QuranEditionCopyWithImpl<$Res>
    implements _$QuranEditionCopyWith<$Res> {
  __$QuranEditionCopyWithImpl(this._self, this._then);

  final _QuranEdition _self;
  final $Res Function(_QuranEdition) _then;

/// Create a copy of QuranEdition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? riwayah = null,Object? publisher = null,Object? printEdition = null,Object? pageCount = null,Object? suraCount = null,Object? verseCount = null,Object? sources = null,}) {
  return _then(_QuranEdition(
riwayah: null == riwayah ? _self.riwayah : riwayah // ignore: cast_nullable_to_non_nullable
as String,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String,printEdition: null == printEdition ? _self.printEdition : printEdition // ignore: cast_nullable_to_non_nullable
as String,pageCount: null == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int,suraCount: null == suraCount ? _self.suraCount : suraCount // ignore: cast_nullable_to_non_nullable
as int,verseCount: null == verseCount ? _self.verseCount : verseCount // ignore: cast_nullable_to_non_nullable
as int,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<QuranSource>,
  ));
}


}

// dart format on
