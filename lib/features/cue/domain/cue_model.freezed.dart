// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cue_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CueModel {

 String get id; String get title; String? get description; String get audioUrl; double get latitude; double get longitude; DateTime get createdAt;
/// Create a copy of CueModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CueModelCopyWith<CueModel> get copyWith => _$CueModelCopyWithImpl<CueModel>(this as CueModel, _$identity);

  /// Serializes this CueModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CueModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,audioUrl,latitude,longitude,createdAt);

@override
String toString() {
  return 'CueModel(id: $id, title: $title, description: $description, audioUrl: $audioUrl, latitude: $latitude, longitude: $longitude, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CueModelCopyWith<$Res>  {
  factory $CueModelCopyWith(CueModel value, $Res Function(CueModel) _then) = _$CueModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, String audioUrl, double latitude, double longitude, DateTime createdAt
});




}
/// @nodoc
class _$CueModelCopyWithImpl<$Res>
    implements $CueModelCopyWith<$Res> {
  _$CueModelCopyWithImpl(this._self, this._then);

  final CueModel _self;
  final $Res Function(CueModel) _then;

/// Create a copy of CueModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? audioUrl = null,Object? latitude = null,Object? longitude = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CueModel].
extension CueModelPatterns on CueModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CueModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CueModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CueModel value)  $default,){
final _that = this;
switch (_that) {
case _CueModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CueModel value)?  $default,){
final _that = this;
switch (_that) {
case _CueModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String audioUrl,  double latitude,  double longitude,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CueModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.audioUrl,_that.latitude,_that.longitude,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String audioUrl,  double latitude,  double longitude,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _CueModel():
return $default(_that.id,_that.title,_that.description,_that.audioUrl,_that.latitude,_that.longitude,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  String audioUrl,  double latitude,  double longitude,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CueModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.audioUrl,_that.latitude,_that.longitude,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CueModel implements CueModel {
  const _CueModel({required this.id, required this.title, this.description, required this.audioUrl, required this.latitude, required this.longitude, required this.createdAt});
  factory _CueModel.fromJson(Map<String, dynamic> json) => _$CueModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  String audioUrl;
@override final  double latitude;
@override final  double longitude;
@override final  DateTime createdAt;

/// Create a copy of CueModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CueModelCopyWith<_CueModel> get copyWith => __$CueModelCopyWithImpl<_CueModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CueModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CueModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,audioUrl,latitude,longitude,createdAt);

@override
String toString() {
  return 'CueModel(id: $id, title: $title, description: $description, audioUrl: $audioUrl, latitude: $latitude, longitude: $longitude, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CueModelCopyWith<$Res> implements $CueModelCopyWith<$Res> {
  factory _$CueModelCopyWith(_CueModel value, $Res Function(_CueModel) _then) = __$CueModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, String audioUrl, double latitude, double longitude, DateTime createdAt
});




}
/// @nodoc
class __$CueModelCopyWithImpl<$Res>
    implements _$CueModelCopyWith<$Res> {
  __$CueModelCopyWithImpl(this._self, this._then);

  final _CueModel _self;
  final $Res Function(_CueModel) _then;

/// Create a copy of CueModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? audioUrl = null,Object? latitude = null,Object? longitude = null,Object? createdAt = null,}) {
  return _then(_CueModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
