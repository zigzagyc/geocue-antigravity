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

 String get id; String get ownerId; String get title; String? get description; String get audioUrl; double get latitude; double get longitude; DateTime get createdAt; String get language; String? get originalCueId;// If null, this is original. Points to source cue ID.
 String? get referenceCueId;// Optional grouping ID if different from originalCueId
 double get radius; String get zoneType;// 'circle' or 'polygon'
 List<Map<String, double>>? get polygonPoints;
/// Create a copy of CueModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CueModelCopyWith<CueModel> get copyWith => _$CueModelCopyWithImpl<CueModel>(this as CueModel, _$identity);

  /// Serializes this CueModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CueModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.language, language) || other.language == language)&&(identical(other.originalCueId, originalCueId) || other.originalCueId == originalCueId)&&(identical(other.referenceCueId, referenceCueId) || other.referenceCueId == referenceCueId)&&(identical(other.radius, radius) || other.radius == radius)&&(identical(other.zoneType, zoneType) || other.zoneType == zoneType)&&const DeepCollectionEquality().equals(other.polygonPoints, polygonPoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,title,description,audioUrl,latitude,longitude,createdAt,language,originalCueId,referenceCueId,radius,zoneType,const DeepCollectionEquality().hash(polygonPoints));

@override
String toString() {
  return 'CueModel(id: $id, ownerId: $ownerId, title: $title, description: $description, audioUrl: $audioUrl, latitude: $latitude, longitude: $longitude, createdAt: $createdAt, language: $language, originalCueId: $originalCueId, referenceCueId: $referenceCueId, radius: $radius, zoneType: $zoneType, polygonPoints: $polygonPoints)';
}


}

/// @nodoc
abstract mixin class $CueModelCopyWith<$Res>  {
  factory $CueModelCopyWith(CueModel value, $Res Function(CueModel) _then) = _$CueModelCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String title, String? description, String audioUrl, double latitude, double longitude, DateTime createdAt, String language, String? originalCueId, String? referenceCueId, double radius, String zoneType, List<Map<String, double>>? polygonPoints
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? title = null,Object? description = freezed,Object? audioUrl = null,Object? latitude = null,Object? longitude = null,Object? createdAt = null,Object? language = null,Object? originalCueId = freezed,Object? referenceCueId = freezed,Object? radius = null,Object? zoneType = null,Object? polygonPoints = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,originalCueId: freezed == originalCueId ? _self.originalCueId : originalCueId // ignore: cast_nullable_to_non_nullable
as String?,referenceCueId: freezed == referenceCueId ? _self.referenceCueId : referenceCueId // ignore: cast_nullable_to_non_nullable
as String?,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as double,zoneType: null == zoneType ? _self.zoneType : zoneType // ignore: cast_nullable_to_non_nullable
as String,polygonPoints: freezed == polygonPoints ? _self.polygonPoints : polygonPoints // ignore: cast_nullable_to_non_nullable
as List<Map<String, double>>?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String title,  String? description,  String audioUrl,  double latitude,  double longitude,  DateTime createdAt,  String language,  String? originalCueId,  String? referenceCueId,  double radius,  String zoneType,  List<Map<String, double>>? polygonPoints)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CueModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.title,_that.description,_that.audioUrl,_that.latitude,_that.longitude,_that.createdAt,_that.language,_that.originalCueId,_that.referenceCueId,_that.radius,_that.zoneType,_that.polygonPoints);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String title,  String? description,  String audioUrl,  double latitude,  double longitude,  DateTime createdAt,  String language,  String? originalCueId,  String? referenceCueId,  double radius,  String zoneType,  List<Map<String, double>>? polygonPoints)  $default,) {final _that = this;
switch (_that) {
case _CueModel():
return $default(_that.id,_that.ownerId,_that.title,_that.description,_that.audioUrl,_that.latitude,_that.longitude,_that.createdAt,_that.language,_that.originalCueId,_that.referenceCueId,_that.radius,_that.zoneType,_that.polygonPoints);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String title,  String? description,  String audioUrl,  double latitude,  double longitude,  DateTime createdAt,  String language,  String? originalCueId,  String? referenceCueId,  double radius,  String zoneType,  List<Map<String, double>>? polygonPoints)?  $default,) {final _that = this;
switch (_that) {
case _CueModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.title,_that.description,_that.audioUrl,_that.latitude,_that.longitude,_that.createdAt,_that.language,_that.originalCueId,_that.referenceCueId,_that.radius,_that.zoneType,_that.polygonPoints);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CueModel implements CueModel {
  const _CueModel({required this.id, this.ownerId = '', required this.title, this.description, required this.audioUrl, required this.latitude, required this.longitude, required this.createdAt, this.language = 'en', this.originalCueId, this.referenceCueId, this.radius = 50.0, this.zoneType = 'circle', final  List<Map<String, double>>? polygonPoints}): _polygonPoints = polygonPoints;
  factory _CueModel.fromJson(Map<String, dynamic> json) => _$CueModelFromJson(json);

@override final  String id;
@override@JsonKey() final  String ownerId;
@override final  String title;
@override final  String? description;
@override final  String audioUrl;
@override final  double latitude;
@override final  double longitude;
@override final  DateTime createdAt;
@override@JsonKey() final  String language;
@override final  String? originalCueId;
// If null, this is original. Points to source cue ID.
@override final  String? referenceCueId;
// Optional grouping ID if different from originalCueId
@override@JsonKey() final  double radius;
@override@JsonKey() final  String zoneType;
// 'circle' or 'polygon'
 final  List<Map<String, double>>? _polygonPoints;
// 'circle' or 'polygon'
@override List<Map<String, double>>? get polygonPoints {
  final value = _polygonPoints;
  if (value == null) return null;
  if (_polygonPoints is EqualUnmodifiableListView) return _polygonPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CueModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.language, language) || other.language == language)&&(identical(other.originalCueId, originalCueId) || other.originalCueId == originalCueId)&&(identical(other.referenceCueId, referenceCueId) || other.referenceCueId == referenceCueId)&&(identical(other.radius, radius) || other.radius == radius)&&(identical(other.zoneType, zoneType) || other.zoneType == zoneType)&&const DeepCollectionEquality().equals(other._polygonPoints, _polygonPoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,title,description,audioUrl,latitude,longitude,createdAt,language,originalCueId,referenceCueId,radius,zoneType,const DeepCollectionEquality().hash(_polygonPoints));

@override
String toString() {
  return 'CueModel(id: $id, ownerId: $ownerId, title: $title, description: $description, audioUrl: $audioUrl, latitude: $latitude, longitude: $longitude, createdAt: $createdAt, language: $language, originalCueId: $originalCueId, referenceCueId: $referenceCueId, radius: $radius, zoneType: $zoneType, polygonPoints: $polygonPoints)';
}


}

/// @nodoc
abstract mixin class _$CueModelCopyWith<$Res> implements $CueModelCopyWith<$Res> {
  factory _$CueModelCopyWith(_CueModel value, $Res Function(_CueModel) _then) = __$CueModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String title, String? description, String audioUrl, double latitude, double longitude, DateTime createdAt, String language, String? originalCueId, String? referenceCueId, double radius, String zoneType, List<Map<String, double>>? polygonPoints
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? title = null,Object? description = freezed,Object? audioUrl = null,Object? latitude = null,Object? longitude = null,Object? createdAt = null,Object? language = null,Object? originalCueId = freezed,Object? referenceCueId = freezed,Object? radius = null,Object? zoneType = null,Object? polygonPoints = freezed,}) {
  return _then(_CueModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,originalCueId: freezed == originalCueId ? _self.originalCueId : originalCueId // ignore: cast_nullable_to_non_nullable
as String?,referenceCueId: freezed == referenceCueId ? _self.referenceCueId : referenceCueId // ignore: cast_nullable_to_non_nullable
as String?,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as double,zoneType: null == zoneType ? _self.zoneType : zoneType // ignore: cast_nullable_to_non_nullable
as String,polygonPoints: freezed == polygonPoints ? _self._polygonPoints : polygonPoints // ignore: cast_nullable_to_non_nullable
as List<Map<String, double>>?,
  ));
}


}

// dart format on
