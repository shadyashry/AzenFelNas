// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tuf_roles.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TufRoles {

/// Root role.
 TufRole get root;/// Targets role.
 TufRole get targets;/// Snapshot role.
 TufRole get snapshot;/// Timestamp role.
 TufRole get timestamp;
/// Create a copy of TufRoles
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufRolesCopyWith<TufRoles> get copyWith => _$TufRolesCopyWithImpl<TufRoles>(this as TufRoles, _$identity);

  /// Serializes this TufRoles to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TufRoles;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TufRoles&&(identical(other.root, _this.root) || other.root == _this.root)&&(identical(other.targets, _this.targets) || other.targets == _this.targets)&&(identical(other.snapshot, _this.snapshot) || other.snapshot == _this.snapshot)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TufRoles;
  return Object.hash(runtimeType,_this.root,_this.targets,_this.snapshot,_this.timestamp);
}

@override
String toString() {
  final _this = this as TufRoles;
  return 'TufRoles(root: ${_this.root}, targets: ${_this.targets}, snapshot: ${_this.snapshot}, timestamp: ${_this.timestamp})';
}


}

/// @nodoc
abstract mixin class $TufRolesCopyWith<$Res>  {
  factory $TufRolesCopyWith(TufRoles value, $Res Function(TufRoles) _then) = _$TufRolesCopyWithImpl;
@useResult
$Res call({
 TufRole root, TufRole targets, TufRole snapshot, TufRole timestamp
});


$TufRoleCopyWith<$Res> get root;$TufRoleCopyWith<$Res> get targets;$TufRoleCopyWith<$Res> get snapshot;$TufRoleCopyWith<$Res> get timestamp;

}
/// @nodoc
class _$TufRolesCopyWithImpl<$Res>
    implements $TufRolesCopyWith<$Res> {
  _$TufRolesCopyWithImpl(this._self, this._then);

  final TufRoles _self;
  final $Res Function(TufRoles) _then;

/// Create a copy of TufRoles
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? root = null,Object? targets = null,Object? snapshot = null,Object? timestamp = null,}) {
  return _then(TufRoles(
root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as TufRole,targets: null == targets ? _self.targets : targets // ignore: cast_nullable_to_non_nullable
as TufRole,snapshot: null == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as TufRole,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as TufRole,
  ));
}
/// Create a copy of TufRoles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufRoleCopyWith<$Res> get root {
  
  return $TufRoleCopyWith<$Res>(_self.root, (value) {
    return _then(_self.copyWith(root: value));
  });
}/// Create a copy of TufRoles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufRoleCopyWith<$Res> get targets {
  
  return $TufRoleCopyWith<$Res>(_self.targets, (value) {
    return _then(_self.copyWith(targets: value));
  });
}/// Create a copy of TufRoles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufRoleCopyWith<$Res> get snapshot {
  
  return $TufRoleCopyWith<$Res>(_self.snapshot, (value) {
    return _then(_self.copyWith(snapshot: value));
  });
}/// Create a copy of TufRoles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufRoleCopyWith<$Res> get timestamp {
  
  return $TufRoleCopyWith<$Res>(_self.timestamp, (value) {
    return _then(_self.copyWith(timestamp: value));
  });
}
}


/// Adds pattern-matching-related methods to [TufRoles].
extension TufRolesPatterns on TufRoles {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TufRoles value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TufRoles() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TufRoles value)  $default,){
final _that = this;
switch (_that) {
case _TufRoles():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TufRoles value)?  $default,){
final _that = this;
switch (_that) {
case _TufRoles() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TufRole root,  TufRole targets,  TufRole snapshot,  TufRole timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TufRoles() when $default != null:
return $default(_that.root,_that.targets,_that.snapshot,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TufRole root,  TufRole targets,  TufRole snapshot,  TufRole timestamp)  $default,) {final _that = this;
switch (_that) {
case _TufRoles():
return $default(_that.root,_that.targets,_that.snapshot,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TufRole root,  TufRole targets,  TufRole snapshot,  TufRole timestamp)?  $default,) {final _that = this;
switch (_that) {
case _TufRoles() when $default != null:
return $default(_that.root,_that.targets,_that.snapshot,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TufRoles implements TufRoles {
  const _TufRoles({required this.root, required this.targets, required this.snapshot, required this.timestamp});
  factory _TufRoles.fromJson(Map<String, dynamic> json) => _$TufRolesFromJson(json);

/// Root role.
@override final  TufRole root;
/// Targets role.
@override final  TufRole targets;
/// Snapshot role.
@override final  TufRole snapshot;
/// Timestamp role.
@override final  TufRole timestamp;

/// Create a copy of TufRoles
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TufRolesCopyWith<_TufRoles> get copyWith => __$TufRolesCopyWithImpl<_TufRoles>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufRolesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TufRoles&&(identical(other.root, root) || other.root == root)&&(identical(other.targets, targets) || other.targets == targets)&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,root,targets,snapshot,timestamp);
}

@override
String toString() {
    return 'TufRoles(root: $root, targets: $targets, snapshot: $snapshot, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$TufRolesCopyWith<$Res> implements $TufRolesCopyWith<$Res> {
  factory _$TufRolesCopyWith(_TufRoles value, $Res Function(_TufRoles) _then) = __$TufRolesCopyWithImpl;
@override @useResult
$Res call({
 TufRole root, TufRole targets, TufRole snapshot, TufRole timestamp
});


@override $TufRoleCopyWith<$Res> get root;@override $TufRoleCopyWith<$Res> get targets;@override $TufRoleCopyWith<$Res> get snapshot;@override $TufRoleCopyWith<$Res> get timestamp;

}
/// @nodoc
class __$TufRolesCopyWithImpl<$Res>
    implements _$TufRolesCopyWith<$Res> {
  __$TufRolesCopyWithImpl(this._self, this._then);

  final _TufRoles _self;
  final $Res Function(_TufRoles) _then;

/// Create a copy of TufRoles
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? root = null,Object? targets = null,Object? snapshot = null,Object? timestamp = null,}) {
  return _then(_TufRoles(
root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as TufRole,targets: null == targets ? _self.targets : targets // ignore: cast_nullable_to_non_nullable
as TufRole,snapshot: null == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as TufRole,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as TufRole,
  ));
}

/// Create a copy of TufRoles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufRoleCopyWith<$Res> get root {
  
  return $TufRoleCopyWith<$Res>(_self.root, (value) {
    return _then(_self.copyWith(root: value));
  });
}/// Create a copy of TufRoles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufRoleCopyWith<$Res> get targets {
  
  return $TufRoleCopyWith<$Res>(_self.targets, (value) {
    return _then(_self.copyWith(targets: value));
  });
}/// Create a copy of TufRoles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufRoleCopyWith<$Res> get snapshot {
  
  return $TufRoleCopyWith<$Res>(_self.snapshot, (value) {
    return _then(_self.copyWith(snapshot: value));
  });
}/// Create a copy of TufRoles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufRoleCopyWith<$Res> get timestamp {
  
  return $TufRoleCopyWith<$Res>(_self.timestamp, (value) {
    return _then(_self.copyWith(timestamp: value));
  });
}
}

// dart format on
