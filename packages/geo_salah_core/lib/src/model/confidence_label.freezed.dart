// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'confidence_label.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConfidenceLabel {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfidenceLabel);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConfidenceLabel()';
}


}

/// @nodoc
class $ConfidenceLabelCopyWith<$Res>  {
$ConfidenceLabelCopyWith(ConfidenceLabel _, $Res Function(ConfidenceLabel) __);
}


/// Adds pattern-matching-related methods to [ConfidenceLabel].
extension ConfidenceLabelPatterns on ConfidenceLabel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Calculated value)?  calculated,TResult Function( AuthorityAligned value)?  authorityAligned,TResult Function( Verified value)?  verified,TResult Function( Estimated value)?  estimated,TResult Function( Observed value)?  observed,TResult Function( Unknown value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Calculated() when calculated != null:
return calculated(_that);case AuthorityAligned() when authorityAligned != null:
return authorityAligned(_that);case Verified() when verified != null:
return verified(_that);case Estimated() when estimated != null:
return estimated(_that);case Observed() when observed != null:
return observed(_that);case Unknown() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Calculated value)  calculated,required TResult Function( AuthorityAligned value)  authorityAligned,required TResult Function( Verified value)  verified,required TResult Function( Estimated value)  estimated,required TResult Function( Observed value)  observed,required TResult Function( Unknown value)  unknown,}){
final _that = this;
switch (_that) {
case Calculated():
return calculated(_that);case AuthorityAligned():
return authorityAligned(_that);case Verified():
return verified(_that);case Estimated():
return estimated(_that);case Observed():
return observed(_that);case Unknown():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Calculated value)?  calculated,TResult? Function( AuthorityAligned value)?  authorityAligned,TResult? Function( Verified value)?  verified,TResult? Function( Estimated value)?  estimated,TResult? Function( Observed value)?  observed,TResult? Function( Unknown value)?  unknown,}){
final _that = this;
switch (_that) {
case Calculated() when calculated != null:
return calculated(_that);case AuthorityAligned() when authorityAligned != null:
return authorityAligned(_that);case Verified() when verified != null:
return verified(_that);case Estimated() when estimated != null:
return estimated(_that);case Observed() when observed != null:
return observed(_that);case Unknown() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  calculated,TResult Function( String benchmarkReportId)?  authorityAligned,TResult Function( String sourceRef,  int freshUntilUtcMs)?  verified,TResult Function( int rangeMinutes)?  estimated,TResult Function( int count,  int lastSeenUtcMs)?  observed,TResult Function( String reasonCode)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Calculated() when calculated != null:
return calculated();case AuthorityAligned() when authorityAligned != null:
return authorityAligned(_that.benchmarkReportId);case Verified() when verified != null:
return verified(_that.sourceRef,_that.freshUntilUtcMs);case Estimated() when estimated != null:
return estimated(_that.rangeMinutes);case Observed() when observed != null:
return observed(_that.count,_that.lastSeenUtcMs);case Unknown() when unknown != null:
return unknown(_that.reasonCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  calculated,required TResult Function( String benchmarkReportId)  authorityAligned,required TResult Function( String sourceRef,  int freshUntilUtcMs)  verified,required TResult Function( int rangeMinutes)  estimated,required TResult Function( int count,  int lastSeenUtcMs)  observed,required TResult Function( String reasonCode)  unknown,}) {final _that = this;
switch (_that) {
case Calculated():
return calculated();case AuthorityAligned():
return authorityAligned(_that.benchmarkReportId);case Verified():
return verified(_that.sourceRef,_that.freshUntilUtcMs);case Estimated():
return estimated(_that.rangeMinutes);case Observed():
return observed(_that.count,_that.lastSeenUtcMs);case Unknown():
return unknown(_that.reasonCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  calculated,TResult? Function( String benchmarkReportId)?  authorityAligned,TResult? Function( String sourceRef,  int freshUntilUtcMs)?  verified,TResult? Function( int rangeMinutes)?  estimated,TResult? Function( int count,  int lastSeenUtcMs)?  observed,TResult? Function( String reasonCode)?  unknown,}) {final _that = this;
switch (_that) {
case Calculated() when calculated != null:
return calculated();case AuthorityAligned() when authorityAligned != null:
return authorityAligned(_that.benchmarkReportId);case Verified() when verified != null:
return verified(_that.sourceRef,_that.freshUntilUtcMs);case Estimated() when estimated != null:
return estimated(_that.rangeMinutes);case Observed() when observed != null:
return observed(_that.count,_that.lastSeenUtcMs);case Unknown() when unknown != null:
return unknown(_that.reasonCode);case _:
  return null;

}
}

}

/// @nodoc


class Calculated implements ConfidenceLabel {
  const Calculated();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Calculated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConfidenceLabel.calculated()';
}


}




/// @nodoc


class AuthorityAligned implements ConfidenceLabel {
  const AuthorityAligned({required this.benchmarkReportId});
  

 final  String benchmarkReportId;

/// Create a copy of ConfidenceLabel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthorityAlignedCopyWith<AuthorityAligned> get copyWith => _$AuthorityAlignedCopyWithImpl<AuthorityAligned>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthorityAligned&&(identical(other.benchmarkReportId, benchmarkReportId) || other.benchmarkReportId == benchmarkReportId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,benchmarkReportId);
}

@override
String toString() {
    return 'ConfidenceLabel.authorityAligned(benchmarkReportId: $benchmarkReportId)';
}


}

/// @nodoc
abstract mixin class $AuthorityAlignedCopyWith<$Res> implements $ConfidenceLabelCopyWith<$Res> {
  factory $AuthorityAlignedCopyWith(AuthorityAligned value, $Res Function(AuthorityAligned) _then) = _$AuthorityAlignedCopyWithImpl;
@useResult
$Res call({
 String benchmarkReportId
});




}
/// @nodoc
class _$AuthorityAlignedCopyWithImpl<$Res>
    implements $AuthorityAlignedCopyWith<$Res> {
  _$AuthorityAlignedCopyWithImpl(this._self, this._then);

  final AuthorityAligned _self;
  final $Res Function(AuthorityAligned) _then;

/// Create a copy of ConfidenceLabel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? benchmarkReportId = null,}) {
  return _then(AuthorityAligned(
benchmarkReportId: null == benchmarkReportId ? _self.benchmarkReportId : benchmarkReportId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class Verified implements ConfidenceLabel {
  const Verified({required this.sourceRef, required this.freshUntilUtcMs});
  

 final  String sourceRef;
 final  int freshUntilUtcMs;

/// Create a copy of ConfidenceLabel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifiedCopyWith<Verified> get copyWith => _$VerifiedCopyWithImpl<Verified>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Verified&&(identical(other.sourceRef, sourceRef) || other.sourceRef == sourceRef)&&(identical(other.freshUntilUtcMs, freshUntilUtcMs) || other.freshUntilUtcMs == freshUntilUtcMs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,sourceRef,freshUntilUtcMs);
}

@override
String toString() {
    return 'ConfidenceLabel.verified(sourceRef: $sourceRef, freshUntilUtcMs: $freshUntilUtcMs)';
}


}

/// @nodoc
abstract mixin class $VerifiedCopyWith<$Res> implements $ConfidenceLabelCopyWith<$Res> {
  factory $VerifiedCopyWith(Verified value, $Res Function(Verified) _then) = _$VerifiedCopyWithImpl;
@useResult
$Res call({
 String sourceRef, int freshUntilUtcMs
});




}
/// @nodoc
class _$VerifiedCopyWithImpl<$Res>
    implements $VerifiedCopyWith<$Res> {
  _$VerifiedCopyWithImpl(this._self, this._then);

  final Verified _self;
  final $Res Function(Verified) _then;

/// Create a copy of ConfidenceLabel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sourceRef = null,Object? freshUntilUtcMs = null,}) {
  return _then(Verified(
sourceRef: null == sourceRef ? _self.sourceRef : sourceRef // ignore: cast_nullable_to_non_nullable
as String,freshUntilUtcMs: null == freshUntilUtcMs ? _self.freshUntilUtcMs : freshUntilUtcMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class Estimated implements ConfidenceLabel {
  const Estimated({required this.rangeMinutes});
  

 final  int rangeMinutes;

/// Create a copy of ConfidenceLabel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EstimatedCopyWith<Estimated> get copyWith => _$EstimatedCopyWithImpl<Estimated>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Estimated&&(identical(other.rangeMinutes, rangeMinutes) || other.rangeMinutes == rangeMinutes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,rangeMinutes);
}

@override
String toString() {
    return 'ConfidenceLabel.estimated(rangeMinutes: $rangeMinutes)';
}


}

/// @nodoc
abstract mixin class $EstimatedCopyWith<$Res> implements $ConfidenceLabelCopyWith<$Res> {
  factory $EstimatedCopyWith(Estimated value, $Res Function(Estimated) _then) = _$EstimatedCopyWithImpl;
@useResult
$Res call({
 int rangeMinutes
});




}
/// @nodoc
class _$EstimatedCopyWithImpl<$Res>
    implements $EstimatedCopyWith<$Res> {
  _$EstimatedCopyWithImpl(this._self, this._then);

  final Estimated _self;
  final $Res Function(Estimated) _then;

/// Create a copy of ConfidenceLabel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? rangeMinutes = null,}) {
  return _then(Estimated(
rangeMinutes: null == rangeMinutes ? _self.rangeMinutes : rangeMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class Observed implements ConfidenceLabel {
  const Observed({required this.count, required this.lastSeenUtcMs});
  

 final  int count;
 final  int lastSeenUtcMs;

/// Create a copy of ConfidenceLabel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ObservedCopyWith<Observed> get copyWith => _$ObservedCopyWithImpl<Observed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Observed&&(identical(other.count, count) || other.count == count)&&(identical(other.lastSeenUtcMs, lastSeenUtcMs) || other.lastSeenUtcMs == lastSeenUtcMs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,count,lastSeenUtcMs);
}

@override
String toString() {
    return 'ConfidenceLabel.observed(count: $count, lastSeenUtcMs: $lastSeenUtcMs)';
}


}

/// @nodoc
abstract mixin class $ObservedCopyWith<$Res> implements $ConfidenceLabelCopyWith<$Res> {
  factory $ObservedCopyWith(Observed value, $Res Function(Observed) _then) = _$ObservedCopyWithImpl;
@useResult
$Res call({
 int count, int lastSeenUtcMs
});




}
/// @nodoc
class _$ObservedCopyWithImpl<$Res>
    implements $ObservedCopyWith<$Res> {
  _$ObservedCopyWithImpl(this._self, this._then);

  final Observed _self;
  final $Res Function(Observed) _then;

/// Create a copy of ConfidenceLabel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? count = null,Object? lastSeenUtcMs = null,}) {
  return _then(Observed(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,lastSeenUtcMs: null == lastSeenUtcMs ? _self.lastSeenUtcMs : lastSeenUtcMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class Unknown implements ConfidenceLabel {
  const Unknown({required this.reasonCode});
  

 final  String reasonCode;

/// Create a copy of ConfidenceLabel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnknownCopyWith<Unknown> get copyWith => _$UnknownCopyWithImpl<Unknown>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Unknown&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reasonCode);
}

@override
String toString() {
    return 'ConfidenceLabel.unknown(reasonCode: $reasonCode)';
}


}

/// @nodoc
abstract mixin class $UnknownCopyWith<$Res> implements $ConfidenceLabelCopyWith<$Res> {
  factory $UnknownCopyWith(Unknown value, $Res Function(Unknown) _then) = _$UnknownCopyWithImpl;
@useResult
$Res call({
 String reasonCode
});




}
/// @nodoc
class _$UnknownCopyWithImpl<$Res>
    implements $UnknownCopyWith<$Res> {
  _$UnknownCopyWithImpl(this._self, this._then);

  final Unknown _self;
  final $Res Function(Unknown) _then;

/// Create a copy of ConfidenceLabel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reasonCode = null,}) {
  return _then(Unknown(
reasonCode: null == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
