// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locked_area_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LockedAreaModel _$LockedAreaModelFromJson(Map<String, dynamic> json) =>
    _LockedAreaModel(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      reason: json['reason'] as String?,
      createdBy: json['createdBy'] as String?,
    );

Map<String, dynamic> _$LockedAreaModelToJson(_LockedAreaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radius': instance.radius,
      'createdAt': instance.createdAt.toIso8601String(),
      'reason': instance.reason,
      'createdBy': instance.createdBy,
    };
