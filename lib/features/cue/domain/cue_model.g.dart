// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cue_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CueModel _$CueModelFromJson(Map<String, dynamic> json) => _CueModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  audioUrl: json['audioUrl'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CueModelToJson(_CueModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'audioUrl': instance.audioUrl,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'createdAt': instance.createdAt.toIso8601String(),
};
