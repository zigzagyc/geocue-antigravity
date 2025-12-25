import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geocue/features/cue/domain/cue_privacy.dart';

part 'cue_model.freezed.dart';
part 'cue_model.g.dart';

@freezed
abstract class CueModel with _$CueModel {
  const factory CueModel({
    required String id,
    required String title,
    required String audioUrl,
  }) = _CueModel;

  factory CueModel.fromJson(Map<String, dynamic> json) =>
      _$CueModelFromJson(json);
}
