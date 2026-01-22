// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cue_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CueModel _$CueModelFromJson(Map<String, dynamic> json) => _CueModel(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String? ?? '',
  title: json['title'] as String,
  description: json['description'] as String?,
  audioUrl: json['audioUrl'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  radius: (json['radius'] as num?)?.toDouble() ?? 50.0,
  zoneType: json['zoneType'] as String? ?? 'circle',
  polygonPoints: (json['polygonPoints'] as List<dynamic>?)
      ?.map(
        (e) => (e as Map<String, dynamic>).map(
          (k, e) => MapEntry(k, (e as num).toDouble()),
        ),
      )
      .toList(),
);

Map<String, dynamic> _$CueModelToJson(_CueModel instance) => <String, dynamic>{
  'id': instance.id,
  'ownerId': instance.ownerId,
  'title': instance.title,
  'description': instance.description,
  'audioUrl': instance.audioUrl,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'createdAt': instance.createdAt.toIso8601String(),
  'radius': instance.radius,
  'zoneType': instance.zoneType,
  'polygonPoints': instance.polygonPoints,
};
