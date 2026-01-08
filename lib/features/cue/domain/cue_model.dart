import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hearhere/features/cue/domain/cue_privacy.dart';

part 'cue_model.freezed.dart';
part 'cue_model.g.dart';

@freezed
abstract class CueModel with _$CueModel {
  const factory CueModel({
    required String id,
    required String title,
    String? description,
    required String audioUrl,
    required double latitude,
    required double longitude,
    required DateTime createdAt,
    @Default(50.0) double radius,
    @Default('circle') String zoneType, // 'circle' or 'polygon'
    List<Map<String, double>>? polygonPoints,
  }) = _CueModel;

  factory CueModel.fromJson(Map<String, dynamic> json) =>
      _$CueModelFromJson(json);
}
