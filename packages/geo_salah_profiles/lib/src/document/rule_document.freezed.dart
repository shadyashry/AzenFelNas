// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rule_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
RuleDocument _$RuleDocumentFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'solarAltitude':
          return SolarAltitudeRuleDocument.fromJson(
            json
          );
                case 'transit':
          return TransitRuleDocument.fromJson(
            json
          );
                case 'shadowFactor':
          return ShadowFactorRuleDocument.fromJson(
            json
          );
                case 'horizon':
          return HorizonRuleDocument.fromJson(
            json
          );
                case 'intervalAfter':
          return IntervalAfterRuleDocument.fromJson(
            json
          );
                case 'intervalBefore':
          return IntervalBeforeRuleDocument.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'RuleDocument',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$RuleDocument {



  /// Serializes this RuleDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RuleDocument);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'RuleDocument()';
}


}

/// @nodoc
class $RuleDocumentCopyWith<$Res>  {
$RuleDocumentCopyWith(RuleDocument _, $Res Function(RuleDocument) __);
}


/// Adds pattern-matching-related methods to [RuleDocument].
extension RuleDocumentPatterns on RuleDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SolarAltitudeRuleDocument value)?  solarAltitude,TResult Function( TransitRuleDocument value)?  transit,TResult Function( ShadowFactorRuleDocument value)?  shadowFactor,TResult Function( HorizonRuleDocument value)?  horizon,TResult Function( IntervalAfterRuleDocument value)?  intervalAfter,TResult Function( IntervalBeforeRuleDocument value)?  intervalBefore,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SolarAltitudeRuleDocument() when solarAltitude != null:
return solarAltitude(_that);case TransitRuleDocument() when transit != null:
return transit(_that);case ShadowFactorRuleDocument() when shadowFactor != null:
return shadowFactor(_that);case HorizonRuleDocument() when horizon != null:
return horizon(_that);case IntervalAfterRuleDocument() when intervalAfter != null:
return intervalAfter(_that);case IntervalBeforeRuleDocument() when intervalBefore != null:
return intervalBefore(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SolarAltitudeRuleDocument value)  solarAltitude,required TResult Function( TransitRuleDocument value)  transit,required TResult Function( ShadowFactorRuleDocument value)  shadowFactor,required TResult Function( HorizonRuleDocument value)  horizon,required TResult Function( IntervalAfterRuleDocument value)  intervalAfter,required TResult Function( IntervalBeforeRuleDocument value)  intervalBefore,}){
final _that = this;
switch (_that) {
case SolarAltitudeRuleDocument():
return solarAltitude(_that);case TransitRuleDocument():
return transit(_that);case ShadowFactorRuleDocument():
return shadowFactor(_that);case HorizonRuleDocument():
return horizon(_that);case IntervalAfterRuleDocument():
return intervalAfter(_that);case IntervalBeforeRuleDocument():
return intervalBefore(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SolarAltitudeRuleDocument value)?  solarAltitude,TResult? Function( TransitRuleDocument value)?  transit,TResult? Function( ShadowFactorRuleDocument value)?  shadowFactor,TResult? Function( HorizonRuleDocument value)?  horizon,TResult? Function( IntervalAfterRuleDocument value)?  intervalAfter,TResult? Function( IntervalBeforeRuleDocument value)?  intervalBefore,}){
final _that = this;
switch (_that) {
case SolarAltitudeRuleDocument() when solarAltitude != null:
return solarAltitude(_that);case TransitRuleDocument() when transit != null:
return transit(_that);case ShadowFactorRuleDocument() when shadowFactor != null:
return shadowFactor(_that);case HorizonRuleDocument() when horizon != null:
return horizon(_that);case IntervalAfterRuleDocument() when intervalAfter != null:
return intervalAfter(_that);case IntervalBeforeRuleDocument() when intervalBefore != null:
return intervalBefore(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( double degrees)?  solarAltitude,TResult Function(@JsonKey(includeIfNull: false)  int? offsetMinutes)?  transit,TResult Function( int k)?  shadowFactor,TResult Function(@JsonKey(includeIfNull: false)  double? refractionArcmin, @JsonKey(includeIfNull: false)  double? semidiameterArcmin)?  horizon,TResult Function( IntervalBaseCode base,  int minutes)?  intervalAfter,TResult Function( IntervalBaseCode base,  int minutes)?  intervalBefore,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SolarAltitudeRuleDocument() when solarAltitude != null:
return solarAltitude(_that.degrees);case TransitRuleDocument() when transit != null:
return transit(_that.offsetMinutes);case ShadowFactorRuleDocument() when shadowFactor != null:
return shadowFactor(_that.k);case HorizonRuleDocument() when horizon != null:
return horizon(_that.refractionArcmin,_that.semidiameterArcmin);case IntervalAfterRuleDocument() when intervalAfter != null:
return intervalAfter(_that.base,_that.minutes);case IntervalBeforeRuleDocument() when intervalBefore != null:
return intervalBefore(_that.base,_that.minutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( double degrees)  solarAltitude,required TResult Function(@JsonKey(includeIfNull: false)  int? offsetMinutes)  transit,required TResult Function( int k)  shadowFactor,required TResult Function(@JsonKey(includeIfNull: false)  double? refractionArcmin, @JsonKey(includeIfNull: false)  double? semidiameterArcmin)  horizon,required TResult Function( IntervalBaseCode base,  int minutes)  intervalAfter,required TResult Function( IntervalBaseCode base,  int minutes)  intervalBefore,}) {final _that = this;
switch (_that) {
case SolarAltitudeRuleDocument():
return solarAltitude(_that.degrees);case TransitRuleDocument():
return transit(_that.offsetMinutes);case ShadowFactorRuleDocument():
return shadowFactor(_that.k);case HorizonRuleDocument():
return horizon(_that.refractionArcmin,_that.semidiameterArcmin);case IntervalAfterRuleDocument():
return intervalAfter(_that.base,_that.minutes);case IntervalBeforeRuleDocument():
return intervalBefore(_that.base,_that.minutes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( double degrees)?  solarAltitude,TResult? Function(@JsonKey(includeIfNull: false)  int? offsetMinutes)?  transit,TResult? Function( int k)?  shadowFactor,TResult? Function(@JsonKey(includeIfNull: false)  double? refractionArcmin, @JsonKey(includeIfNull: false)  double? semidiameterArcmin)?  horizon,TResult? Function( IntervalBaseCode base,  int minutes)?  intervalAfter,TResult? Function( IntervalBaseCode base,  int minutes)?  intervalBefore,}) {final _that = this;
switch (_that) {
case SolarAltitudeRuleDocument() when solarAltitude != null:
return solarAltitude(_that.degrees);case TransitRuleDocument() when transit != null:
return transit(_that.offsetMinutes);case ShadowFactorRuleDocument() when shadowFactor != null:
return shadowFactor(_that.k);case HorizonRuleDocument() when horizon != null:
return horizon(_that.refractionArcmin,_that.semidiameterArcmin);case IntervalAfterRuleDocument() when intervalAfter != null:
return intervalAfter(_that.base,_that.minutes);case IntervalBeforeRuleDocument() when intervalBefore != null:
return intervalBefore(_that.base,_that.minutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class SolarAltitudeRuleDocument implements RuleDocument {
  const SolarAltitudeRuleDocument({required this.degrees,  String? $type}): $type = $type ?? 'solarAltitude';
  factory SolarAltitudeRuleDocument.fromJson(Map<String, dynamic> json) => _$SolarAltitudeRuleDocumentFromJson(json);

 final  double degrees;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of RuleDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SolarAltitudeRuleDocumentCopyWith<SolarAltitudeRuleDocument> get copyWith => _$SolarAltitudeRuleDocumentCopyWithImpl<SolarAltitudeRuleDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SolarAltitudeRuleDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SolarAltitudeRuleDocument&&(identical(other.degrees, degrees) || other.degrees == degrees));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,degrees);
}

@override
String toString() {
    return 'RuleDocument.solarAltitude(degrees: $degrees)';
}


}

/// @nodoc
abstract mixin class $SolarAltitudeRuleDocumentCopyWith<$Res> implements $RuleDocumentCopyWith<$Res> {
  factory $SolarAltitudeRuleDocumentCopyWith(SolarAltitudeRuleDocument value, $Res Function(SolarAltitudeRuleDocument) _then) = _$SolarAltitudeRuleDocumentCopyWithImpl;
@useResult
$Res call({
 double degrees
});




}
/// @nodoc
class _$SolarAltitudeRuleDocumentCopyWithImpl<$Res>
    implements $SolarAltitudeRuleDocumentCopyWith<$Res> {
  _$SolarAltitudeRuleDocumentCopyWithImpl(this._self, this._then);

  final SolarAltitudeRuleDocument _self;
  final $Res Function(SolarAltitudeRuleDocument) _then;

/// Create a copy of RuleDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? degrees = null,}) {
  return _then(SolarAltitudeRuleDocument(
degrees: null == degrees ? _self.degrees : degrees // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
@JsonSerializable()

class TransitRuleDocument implements RuleDocument {
  const TransitRuleDocument({@JsonKey(includeIfNull: false) this.offsetMinutes,  String? $type}): $type = $type ?? 'transit';
  factory TransitRuleDocument.fromJson(Map<String, dynamic> json) => _$TransitRuleDocumentFromJson(json);

@JsonKey(includeIfNull: false) final  int? offsetMinutes;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of RuleDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransitRuleDocumentCopyWith<TransitRuleDocument> get copyWith => _$TransitRuleDocumentCopyWithImpl<TransitRuleDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransitRuleDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TransitRuleDocument&&(identical(other.offsetMinutes, offsetMinutes) || other.offsetMinutes == offsetMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,offsetMinutes);
}

@override
String toString() {
    return 'RuleDocument.transit(offsetMinutes: $offsetMinutes)';
}


}

/// @nodoc
abstract mixin class $TransitRuleDocumentCopyWith<$Res> implements $RuleDocumentCopyWith<$Res> {
  factory $TransitRuleDocumentCopyWith(TransitRuleDocument value, $Res Function(TransitRuleDocument) _then) = _$TransitRuleDocumentCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) int? offsetMinutes
});




}
/// @nodoc
class _$TransitRuleDocumentCopyWithImpl<$Res>
    implements $TransitRuleDocumentCopyWith<$Res> {
  _$TransitRuleDocumentCopyWithImpl(this._self, this._then);

  final TransitRuleDocument _self;
  final $Res Function(TransitRuleDocument) _then;

/// Create a copy of RuleDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? offsetMinutes = freezed,}) {
  return _then(TransitRuleDocument(
offsetMinutes: freezed == offsetMinutes ? _self.offsetMinutes : offsetMinutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ShadowFactorRuleDocument implements RuleDocument {
  const ShadowFactorRuleDocument({required this.k,  String? $type}): $type = $type ?? 'shadowFactor';
  factory ShadowFactorRuleDocument.fromJson(Map<String, dynamic> json) => _$ShadowFactorRuleDocumentFromJson(json);

 final  int k;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of RuleDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShadowFactorRuleDocumentCopyWith<ShadowFactorRuleDocument> get copyWith => _$ShadowFactorRuleDocumentCopyWithImpl<ShadowFactorRuleDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShadowFactorRuleDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ShadowFactorRuleDocument&&(identical(other.k, k) || other.k == k));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,k);
}

@override
String toString() {
    return 'RuleDocument.shadowFactor(k: $k)';
}


}

/// @nodoc
abstract mixin class $ShadowFactorRuleDocumentCopyWith<$Res> implements $RuleDocumentCopyWith<$Res> {
  factory $ShadowFactorRuleDocumentCopyWith(ShadowFactorRuleDocument value, $Res Function(ShadowFactorRuleDocument) _then) = _$ShadowFactorRuleDocumentCopyWithImpl;
@useResult
$Res call({
 int k
});




}
/// @nodoc
class _$ShadowFactorRuleDocumentCopyWithImpl<$Res>
    implements $ShadowFactorRuleDocumentCopyWith<$Res> {
  _$ShadowFactorRuleDocumentCopyWithImpl(this._self, this._then);

  final ShadowFactorRuleDocument _self;
  final $Res Function(ShadowFactorRuleDocument) _then;

/// Create a copy of RuleDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? k = null,}) {
  return _then(ShadowFactorRuleDocument(
k: null == k ? _self.k : k // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class HorizonRuleDocument implements RuleDocument {
  const HorizonRuleDocument({@JsonKey(includeIfNull: false) this.refractionArcmin, @JsonKey(includeIfNull: false) this.semidiameterArcmin,  String? $type}): $type = $type ?? 'horizon';
  factory HorizonRuleDocument.fromJson(Map<String, dynamic> json) => _$HorizonRuleDocumentFromJson(json);

@JsonKey(includeIfNull: false) final  double? refractionArcmin;
@JsonKey(includeIfNull: false) final  double? semidiameterArcmin;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of RuleDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HorizonRuleDocumentCopyWith<HorizonRuleDocument> get copyWith => _$HorizonRuleDocumentCopyWithImpl<HorizonRuleDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HorizonRuleDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HorizonRuleDocument&&(identical(other.refractionArcmin, refractionArcmin) || other.refractionArcmin == refractionArcmin)&&(identical(other.semidiameterArcmin, semidiameterArcmin) || other.semidiameterArcmin == semidiameterArcmin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,refractionArcmin,semidiameterArcmin);
}

@override
String toString() {
    return 'RuleDocument.horizon(refractionArcmin: $refractionArcmin, semidiameterArcmin: $semidiameterArcmin)';
}


}

/// @nodoc
abstract mixin class $HorizonRuleDocumentCopyWith<$Res> implements $RuleDocumentCopyWith<$Res> {
  factory $HorizonRuleDocumentCopyWith(HorizonRuleDocument value, $Res Function(HorizonRuleDocument) _then) = _$HorizonRuleDocumentCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) double? refractionArcmin,@JsonKey(includeIfNull: false) double? semidiameterArcmin
});




}
/// @nodoc
class _$HorizonRuleDocumentCopyWithImpl<$Res>
    implements $HorizonRuleDocumentCopyWith<$Res> {
  _$HorizonRuleDocumentCopyWithImpl(this._self, this._then);

  final HorizonRuleDocument _self;
  final $Res Function(HorizonRuleDocument) _then;

/// Create a copy of RuleDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? refractionArcmin = freezed,Object? semidiameterArcmin = freezed,}) {
  return _then(HorizonRuleDocument(
refractionArcmin: freezed == refractionArcmin ? _self.refractionArcmin : refractionArcmin // ignore: cast_nullable_to_non_nullable
as double?,semidiameterArcmin: freezed == semidiameterArcmin ? _self.semidiameterArcmin : semidiameterArcmin // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class IntervalAfterRuleDocument implements RuleDocument {
  const IntervalAfterRuleDocument({required this.base, required this.minutes,  String? $type}): $type = $type ?? 'intervalAfter';
  factory IntervalAfterRuleDocument.fromJson(Map<String, dynamic> json) => _$IntervalAfterRuleDocumentFromJson(json);

 final  IntervalBaseCode base;
 final  int minutes;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of RuleDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IntervalAfterRuleDocumentCopyWith<IntervalAfterRuleDocument> get copyWith => _$IntervalAfterRuleDocumentCopyWithImpl<IntervalAfterRuleDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IntervalAfterRuleDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is IntervalAfterRuleDocument&&(identical(other.base, base) || other.base == base)&&(identical(other.minutes, minutes) || other.minutes == minutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,base,minutes);
}

@override
String toString() {
    return 'RuleDocument.intervalAfter(base: $base, minutes: $minutes)';
}


}

/// @nodoc
abstract mixin class $IntervalAfterRuleDocumentCopyWith<$Res> implements $RuleDocumentCopyWith<$Res> {
  factory $IntervalAfterRuleDocumentCopyWith(IntervalAfterRuleDocument value, $Res Function(IntervalAfterRuleDocument) _then) = _$IntervalAfterRuleDocumentCopyWithImpl;
@useResult
$Res call({
 IntervalBaseCode base, int minutes
});




}
/// @nodoc
class _$IntervalAfterRuleDocumentCopyWithImpl<$Res>
    implements $IntervalAfterRuleDocumentCopyWith<$Res> {
  _$IntervalAfterRuleDocumentCopyWithImpl(this._self, this._then);

  final IntervalAfterRuleDocument _self;
  final $Res Function(IntervalAfterRuleDocument) _then;

/// Create a copy of RuleDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? base = null,Object? minutes = null,}) {
  return _then(IntervalAfterRuleDocument(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as IntervalBaseCode,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class IntervalBeforeRuleDocument implements RuleDocument {
  const IntervalBeforeRuleDocument({required this.base, required this.minutes,  String? $type}): $type = $type ?? 'intervalBefore';
  factory IntervalBeforeRuleDocument.fromJson(Map<String, dynamic> json) => _$IntervalBeforeRuleDocumentFromJson(json);

 final  IntervalBaseCode base;
 final  int minutes;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of RuleDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IntervalBeforeRuleDocumentCopyWith<IntervalBeforeRuleDocument> get copyWith => _$IntervalBeforeRuleDocumentCopyWithImpl<IntervalBeforeRuleDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IntervalBeforeRuleDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is IntervalBeforeRuleDocument&&(identical(other.base, base) || other.base == base)&&(identical(other.minutes, minutes) || other.minutes == minutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,base,minutes);
}

@override
String toString() {
    return 'RuleDocument.intervalBefore(base: $base, minutes: $minutes)';
}


}

/// @nodoc
abstract mixin class $IntervalBeforeRuleDocumentCopyWith<$Res> implements $RuleDocumentCopyWith<$Res> {
  factory $IntervalBeforeRuleDocumentCopyWith(IntervalBeforeRuleDocument value, $Res Function(IntervalBeforeRuleDocument) _then) = _$IntervalBeforeRuleDocumentCopyWithImpl;
@useResult
$Res call({
 IntervalBaseCode base, int minutes
});




}
/// @nodoc
class _$IntervalBeforeRuleDocumentCopyWithImpl<$Res>
    implements $IntervalBeforeRuleDocumentCopyWith<$Res> {
  _$IntervalBeforeRuleDocumentCopyWithImpl(this._self, this._then);

  final IntervalBeforeRuleDocument _self;
  final $Res Function(IntervalBeforeRuleDocument) _then;

/// Create a copy of RuleDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? base = null,Object? minutes = null,}) {
  return _then(IntervalBeforeRuleDocument(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as IntervalBaseCode,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
