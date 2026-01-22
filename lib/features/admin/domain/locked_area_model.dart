import 'package:freezed_annotation/freezed_annotation.dart';

part 'locked_area_model.freezed.dart';
part 'locked_area_model.g.dart';

@freezed
abstract class LockedAreaModel with _$LockedAreaModel {
  const factory LockedAreaModel({
    required String id,
    required double latitude,
    required double longitude,
    required double radius,
    required DateTime createdAt,
    String? reason,
    String? createdBy,
  }) = _LockedAreaModel;

  factory LockedAreaModel.fromJson(Map<String, dynamic> json) =>
      _$LockedAreaModelFromJson(json);
}
