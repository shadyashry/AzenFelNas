// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tuf_signed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
TufSigned _$TufSignedFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'root':
          return TufRootSigned.fromJson(
            json
          );
                case 'targets':
          return TufTargetsSigned.fromJson(
            json
          );
                case 'snapshot':
          return TufSnapshotSigned.fromJson(
            json
          );
                case 'timestamp':
          return TufTimestampSigned.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'TufSigned',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$TufSigned {

 String get expires;
/// Create a copy of TufSigned
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufSignedCopyWith<TufSigned> get copyWith => _$TufSignedCopyWithImpl<TufSigned>(this as TufSigned, _$identity);

  /// Serializes this TufSigned to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TufSigned;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TufSigned&&(identical(other.expires, _this.expires) || other.expires == _this.expires));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TufSigned;
  return Object.hash(runtimeType,_this.expires);
}

@override
String toString() {
  final _this = this as TufSigned;
  return 'TufSigned(expires: ${_this.expires})';
}


}

/// @nodoc
abstract mixin class $TufSignedCopyWith<$Res>  {
  factory $TufSignedCopyWith(TufSigned value, $Res Function(TufSigned) _then) = _$TufSignedCopyWithImpl;
@useResult
$Res call({
 String expires
});




}
/// @nodoc
class _$TufSignedCopyWithImpl<$Res>
    implements $TufSignedCopyWith<$Res> {
  _$TufSignedCopyWithImpl(this._self, this._then);

  final TufSigned _self;
  final $Res Function(TufSigned) _then;

/// Create a copy of TufSigned
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? expires = null,}) {
  return _then(_self.copyWith(
expires: null == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TufSigned].
extension TufSignedPatterns on TufSigned {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TufRootSigned value)?  root,TResult Function( TufTargetsSigned value)?  targets,TResult Function( TufSnapshotSigned value)?  snapshot,TResult Function( TufTimestampSigned value)?  timestamp,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TufRootSigned() when root != null:
return root(_that);case TufTargetsSigned() when targets != null:
return targets(_that);case TufSnapshotSigned() when snapshot != null:
return snapshot(_that);case TufTimestampSigned() when timestamp != null:
return timestamp(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TufRootSigned value)  root,required TResult Function( TufTargetsSigned value)  targets,required TResult Function( TufSnapshotSigned value)  snapshot,required TResult Function( TufTimestampSigned value)  timestamp,}){
final _that = this;
switch (_that) {
case TufRootSigned():
return root(_that);case TufTargetsSigned():
return targets(_that);case TufSnapshotSigned():
return snapshot(_that);case TufTimestampSigned():
return timestamp(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TufRootSigned value)?  root,TResult? Function( TufTargetsSigned value)?  targets,TResult? Function( TufSnapshotSigned value)?  snapshot,TResult? Function( TufTimestampSigned value)?  timestamp,}){
final _that = this;
switch (_that) {
case TufRootSigned() when root != null:
return root(_that);case TufTargetsSigned() when targets != null:
return targets(_that);case TufSnapshotSigned() when snapshot != null:
return snapshot(_that);case TufTimestampSigned() when timestamp != null:
return timestamp(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int version,  String expires,  Map<String, TufKey> keys,  TufRoles roles)?  root,TResult Function( int sequence,  String expires,  Map<String, TufTarget> targets)?  targets,TResult Function( int sequence,  String expires,  TufSnapshotMeta meta)?  snapshot,TResult Function( int sequence,  String expires,  TufTimestampMeta meta)?  timestamp,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TufRootSigned() when root != null:
return root(_that.version,_that.expires,_that.keys,_that.roles);case TufTargetsSigned() when targets != null:
return targets(_that.sequence,_that.expires,_that.targets);case TufSnapshotSigned() when snapshot != null:
return snapshot(_that.sequence,_that.expires,_that.meta);case TufTimestampSigned() when timestamp != null:
return timestamp(_that.sequence,_that.expires,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int version,  String expires,  Map<String, TufKey> keys,  TufRoles roles)  root,required TResult Function( int sequence,  String expires,  Map<String, TufTarget> targets)  targets,required TResult Function( int sequence,  String expires,  TufSnapshotMeta meta)  snapshot,required TResult Function( int sequence,  String expires,  TufTimestampMeta meta)  timestamp,}) {final _that = this;
switch (_that) {
case TufRootSigned():
return root(_that.version,_that.expires,_that.keys,_that.roles);case TufTargetsSigned():
return targets(_that.sequence,_that.expires,_that.targets);case TufSnapshotSigned():
return snapshot(_that.sequence,_that.expires,_that.meta);case TufTimestampSigned():
return timestamp(_that.sequence,_that.expires,_that.meta);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int version,  String expires,  Map<String, TufKey> keys,  TufRoles roles)?  root,TResult? Function( int sequence,  String expires,  Map<String, TufTarget> targets)?  targets,TResult? Function( int sequence,  String expires,  TufSnapshotMeta meta)?  snapshot,TResult? Function( int sequence,  String expires,  TufTimestampMeta meta)?  timestamp,}) {final _that = this;
switch (_that) {
case TufRootSigned() when root != null:
return root(_that.version,_that.expires,_that.keys,_that.roles);case TufTargetsSigned() when targets != null:
return targets(_that.sequence,_that.expires,_that.targets);case TufSnapshotSigned() when snapshot != null:
return snapshot(_that.sequence,_that.expires,_that.meta);case TufTimestampSigned() when timestamp != null:
return timestamp(_that.sequence,_that.expires,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class TufRootSigned implements TufSigned {
  const TufRootSigned({required this.version, required this.expires, required  Map<String, TufKey> keys, required this.roles,  String? $type}): _keys = keys,$type = $type ?? 'root';
  factory TufRootSigned.fromJson(Map<String, dynamic> json) => _$TufRootSignedFromJson(json);

 final  int version;
@override final  String expires;
 final  Map<String, TufKey> _keys;
 Map<String, TufKey> get keys {
  if (_keys is EqualUnmodifiableMapView) return _keys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_keys);
}

 final  TufRoles roles;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of TufSigned
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufRootSignedCopyWith<TufRootSigned> get copyWith => _$TufRootSignedCopyWithImpl<TufRootSigned>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufRootSignedToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TufRootSigned&&(identical(other.version, version) || other.version == version)&&(identical(other.expires, expires) || other.expires == expires)&&const DeepCollectionEquality().equals(other.keys, _keys)&&(identical(other.roles, roles) || other.roles == roles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,version,expires,const DeepCollectionEquality().hash(_keys),roles);
}

@override
String toString() {
    return 'TufSigned.root(version: $version, expires: $expires, keys: $keys, roles: $roles)';
}


}

/// @nodoc
abstract mixin class $TufRootSignedCopyWith<$Res> implements $TufSignedCopyWith<$Res> {
  factory $TufRootSignedCopyWith(TufRootSigned value, $Res Function(TufRootSigned) _then) = _$TufRootSignedCopyWithImpl;
@override @useResult
$Res call({
 int version, String expires, Map<String, TufKey> keys, TufRoles roles
});


$TufRolesCopyWith<$Res> get roles;

}
/// @nodoc
class _$TufRootSignedCopyWithImpl<$Res>
    implements $TufRootSignedCopyWith<$Res> {
  _$TufRootSignedCopyWithImpl(this._self, this._then);

  final TufRootSigned _self;
  final $Res Function(TufRootSigned) _then;

/// Create a copy of TufSigned
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? expires = null,Object? keys = null,Object? roles = null,}) {
  return _then(TufRootSigned(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,expires: null == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as String,keys: null == keys ? _self._keys : keys // ignore: cast_nullable_to_non_nullable
as Map<String, TufKey>,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as TufRoles,
  ));
}

/// Create a copy of TufSigned
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufRolesCopyWith<$Res> get roles {
  
  return $TufRolesCopyWith<$Res>(_self.roles, (value) {
    return _then(_self.copyWith(roles: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class TufTargetsSigned implements TufSigned {
  const TufTargetsSigned({required this.sequence, required this.expires, required  Map<String, TufTarget> targets,  String? $type}): _targets = targets,$type = $type ?? 'targets';
  factory TufTargetsSigned.fromJson(Map<String, dynamic> json) => _$TufTargetsSignedFromJson(json);

 final  int sequence;
@override final  String expires;
 final  Map<String, TufTarget> _targets;
 Map<String, TufTarget> get targets {
  if (_targets is EqualUnmodifiableMapView) return _targets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_targets);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of TufSigned
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufTargetsSignedCopyWith<TufTargetsSigned> get copyWith => _$TufTargetsSignedCopyWithImpl<TufTargetsSigned>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufTargetsSignedToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TufTargetsSigned&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.expires, expires) || other.expires == expires)&&const DeepCollectionEquality().equals(other.targets, _targets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sequence,expires,const DeepCollectionEquality().hash(_targets));
}

@override
String toString() {
    return 'TufSigned.targets(sequence: $sequence, expires: $expires, targets: $targets)';
}


}

/// @nodoc
abstract mixin class $TufTargetsSignedCopyWith<$Res> implements $TufSignedCopyWith<$Res> {
  factory $TufTargetsSignedCopyWith(TufTargetsSigned value, $Res Function(TufTargetsSigned) _then) = _$TufTargetsSignedCopyWithImpl;
@override @useResult
$Res call({
 int sequence, String expires, Map<String, TufTarget> targets
});




}
/// @nodoc
class _$TufTargetsSignedCopyWithImpl<$Res>
    implements $TufTargetsSignedCopyWith<$Res> {
  _$TufTargetsSignedCopyWithImpl(this._self, this._then);

  final TufTargetsSigned _self;
  final $Res Function(TufTargetsSigned) _then;

/// Create a copy of TufSigned
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sequence = null,Object? expires = null,Object? targets = null,}) {
  return _then(TufTargetsSigned(
sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,expires: null == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as String,targets: null == targets ? _self._targets : targets // ignore: cast_nullable_to_non_nullable
as Map<String, TufTarget>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class TufSnapshotSigned implements TufSigned {
  const TufSnapshotSigned({required this.sequence, required this.expires, required this.meta,  String? $type}): $type = $type ?? 'snapshot';
  factory TufSnapshotSigned.fromJson(Map<String, dynamic> json) => _$TufSnapshotSignedFromJson(json);

 final  int sequence;
@override final  String expires;
 final  TufSnapshotMeta meta;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of TufSigned
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufSnapshotSignedCopyWith<TufSnapshotSigned> get copyWith => _$TufSnapshotSignedCopyWithImpl<TufSnapshotSigned>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufSnapshotSignedToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TufSnapshotSigned&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.expires, expires) || other.expires == expires)&&(identical(other.meta, meta) || other.meta == meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sequence,expires,meta);
}

@override
String toString() {
    return 'TufSigned.snapshot(sequence: $sequence, expires: $expires, meta: $meta)';
}


}

/// @nodoc
abstract mixin class $TufSnapshotSignedCopyWith<$Res> implements $TufSignedCopyWith<$Res> {
  factory $TufSnapshotSignedCopyWith(TufSnapshotSigned value, $Res Function(TufSnapshotSigned) _then) = _$TufSnapshotSignedCopyWithImpl;
@override @useResult
$Res call({
 int sequence, String expires, TufSnapshotMeta meta
});


$TufSnapshotMetaCopyWith<$Res> get meta;

}
/// @nodoc
class _$TufSnapshotSignedCopyWithImpl<$Res>
    implements $TufSnapshotSignedCopyWith<$Res> {
  _$TufSnapshotSignedCopyWithImpl(this._self, this._then);

  final TufSnapshotSigned _self;
  final $Res Function(TufSnapshotSigned) _then;

/// Create a copy of TufSigned
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sequence = null,Object? expires = null,Object? meta = null,}) {
  return _then(TufSnapshotSigned(
sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,expires: null == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as TufSnapshotMeta,
  ));
}

/// Create a copy of TufSigned
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufSnapshotMetaCopyWith<$Res> get meta {
  
  return $TufSnapshotMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class TufTimestampSigned implements TufSigned {
  const TufTimestampSigned({required this.sequence, required this.expires, required this.meta,  String? $type}): $type = $type ?? 'timestamp';
  factory TufTimestampSigned.fromJson(Map<String, dynamic> json) => _$TufTimestampSignedFromJson(json);

 final  int sequence;
@override final  String expires;
 final  TufTimestampMeta meta;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of TufSigned
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufTimestampSignedCopyWith<TufTimestampSigned> get copyWith => _$TufTimestampSignedCopyWithImpl<TufTimestampSigned>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufTimestampSignedToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TufTimestampSigned&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.expires, expires) || other.expires == expires)&&(identical(other.meta, meta) || other.meta == meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sequence,expires,meta);
}

@override
String toString() {
    return 'TufSigned.timestamp(sequence: $sequence, expires: $expires, meta: $meta)';
}


}

/// @nodoc
abstract mixin class $TufTimestampSignedCopyWith<$Res> implements $TufSignedCopyWith<$Res> {
  factory $TufTimestampSignedCopyWith(TufTimestampSigned value, $Res Function(TufTimestampSigned) _then) = _$TufTimestampSignedCopyWithImpl;
@override @useResult
$Res call({
 int sequence, String expires, TufTimestampMeta meta
});


$TufTimestampMetaCopyWith<$Res> get meta;

}
/// @nodoc
class _$TufTimestampSignedCopyWithImpl<$Res>
    implements $TufTimestampSignedCopyWith<$Res> {
  _$TufTimestampSignedCopyWithImpl(this._self, this._then);

  final TufTimestampSigned _self;
  final $Res Function(TufTimestampSigned) _then;

/// Create a copy of TufSigned
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sequence = null,Object? expires = null,Object? meta = null,}) {
  return _then(TufTimestampSigned(
sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,expires: null == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as TufTimestampMeta,
  ));
}

/// Create a copy of TufSigned
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufTimestampMetaCopyWith<$Res> get meta {
  
  return $TufTimestampMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}

// dart format on
