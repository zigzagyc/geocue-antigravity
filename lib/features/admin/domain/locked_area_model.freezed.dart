// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'locked_area_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LockedAreaModel {

 String get id; double get latitude; double get longitude; double get radius; DateTime get createdAt; String? get reason; String? get createdBy;
/// Create a copy of LockedAreaModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LockedAreaModelCopyWith<LockedAreaModel> get copyWith => _$LockedAreaModelCopyWithImpl<LockedAreaModel>(this as LockedAreaModel, _$identity);

  /// Serializes this LockedAreaModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LockedAreaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.radius, radius) || other.radius == radius)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,latitude,longitude,radius,createdAt,reason,createdBy);

@override
String toString() {
  return 'LockedAreaModel(id: $id, latitude: $latitude, longitude: $longitude, radius: $radius, createdAt: $createdAt, reason: $reason, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class $LockedAreaModelCopyWith<$Res>  {
  factory $LockedAreaModelCopyWith(LockedAreaModel value, $Res Function(LockedAreaModel) _then) = _$LockedAreaModelCopyWithImpl;
@useResult
$Res call({
 String id, double latitude, double longitude, double radius, DateTime createdAt, String? reason, String? createdBy
});




}
/// @nodoc
class _$LockedAreaModelCopyWithImpl<$Res>
    implements $LockedAreaModelCopyWith<$Res> {
  _$LockedAreaModelCopyWithImpl(this._self, this._then);

  final LockedAreaModel _self;
  final $Res Function(LockedAreaModel) _then;

/// Create a copy of LockedAreaModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? latitude = null,Object? longitude = null,Object? radius = null,Object? createdAt = null,Object? reason = freezed,Object? createdBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LockedAreaModel].
extension LockedAreaModelPatterns on LockedAreaModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LockedAreaModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LockedAreaModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LockedAreaModel value)  $default,){
final _that = this;
switch (_that) {
case _LockedAreaModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LockedAreaModel value)?  $default,){
final _that = this;
switch (_that) {
case _LockedAreaModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double latitude,  double longitude,  double radius,  DateTime createdAt,  String? reason,  String? createdBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LockedAreaModel() when $default != null:
return $default(_that.id,_that.latitude,_that.longitude,_that.radius,_that.createdAt,_that.reason,_that.createdBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double latitude,  double longitude,  double radius,  DateTime createdAt,  String? reason,  String? createdBy)  $default,) {final _that = this;
switch (_that) {
case _LockedAreaModel():
return $default(_that.id,_that.latitude,_that.longitude,_that.radius,_that.createdAt,_that.reason,_that.createdBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double latitude,  double longitude,  double radius,  DateTime createdAt,  String? reason,  String? createdBy)?  $default,) {final _that = this;
switch (_that) {
case _LockedAreaModel() when $default != null:
return $default(_that.id,_that.latitude,_that.longitude,_that.radius,_that.createdAt,_that.reason,_that.createdBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LockedAreaModel implements LockedAreaModel {
  const _LockedAreaModel({required this.id, required this.latitude, required this.longitude, required this.radius, required this.createdAt, this.reason, this.createdBy});
  factory _LockedAreaModel.fromJson(Map<String, dynamic> json) => _$LockedAreaModelFromJson(json);

@override final  String id;
@override final  double latitude;
@override final  double longitude;
@override final  double radius;
@override final  DateTime createdAt;
@override final  String? reason;
@override final  String? createdBy;

/// Create a copy of LockedAreaModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LockedAreaModelCopyWith<_LockedAreaModel> get copyWith => __$LockedAreaModelCopyWithImpl<_LockedAreaModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LockedAreaModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LockedAreaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.radius, radius) || other.radius == radius)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,latitude,longitude,radius,createdAt,reason,createdBy);

@override
String toString() {
  return 'LockedAreaModel(id: $id, latitude: $latitude, longitude: $longitude, radius: $radius, createdAt: $createdAt, reason: $reason, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class _$LockedAreaModelCopyWith<$Res> implements $LockedAreaModelCopyWith<$Res> {
  factory _$LockedAreaModelCopyWith(_LockedAreaModel value, $Res Function(_LockedAreaModel) _then) = __$LockedAreaModelCopyWithImpl;
@override @useResult
$Res call({
 String id, double latitude, double longitude, double radius, DateTime createdAt, String? reason, String? createdBy
});




}
/// @nodoc
class __$LockedAreaModelCopyWithImpl<$Res>
    implements _$LockedAreaModelCopyWith<$Res> {
  __$LockedAreaModelCopyWithImpl(this._self, this._then);

  final _LockedAreaModel _self;
  final $Res Function(_LockedAreaModel) _then;

/// Create a copy of LockedAreaModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? latitude = null,Object? longitude = null,Object? radius = null,Object? createdAt = null,Object? reason = freezed,Object? createdBy = freezed,}) {
  return _then(_LockedAreaModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
