import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geocue/features/cue/data/cue_repository.dart';
import 'package:geocue/features/cue/domain/cue_model.dart';
import 'package:geocue/features/auth/data/auth_repository.dart';
import 'package:geocue/services/ai_service.dart';
import 'package:geocue/services/storage_service.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

part 'create_cue_controller.g.dart';

@riverpod
class CreateCueController extends _$CreateCueController {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  Future<void> createCueFromText({
    required String title,
    required String description,
    required String textContent,
    required String language,
    required double lat,
    required double lng,
    double radius = 50.0,
    String zoneType = 'circle',
    List<Map<String, double>>? polygonPoints,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      // 1. Generate Audio from Text
      final audioUrl = await ref.read(aiServiceProvider).textToSpeech(textContent, language);

      // 2. Create Cue Model
      final cue = CueModel(
        id: const Uuid().v4(),
        title: title,
        description: description,
        audioUrl: audioUrl,
        latitude: lat,
        longitude: lng,
        createdAt: DateTime.now(),
        radius: radius,
        zoneType: zoneType,
        polygonPoints: polygonPoints,
      );

      // 3. Save to Repository
      await ref.read(cueRepositoryProvider).createCue(cue);
    });
  }

  Future<void> createCueFromAudio({
    required String title,
    required String description,
    required String audioFilePath,
    required String language,
    required double lat,
    required double lng,
    double radius = 50.0,
    String zoneType = 'circle',
    List<Map<String, double>>? polygonPoints,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      final fileName = '${const Uuid().v4()}.m4a';
      final storagePath = 'users/${user.uid}/cues/$fileName';
      
      // 1. Upload Audio File
      final audioUrl = await ref.read(storageServiceProvider).uploadFile(
        File(audioFilePath),
        storagePath,
      );

      // 2. Create Cue Model
      final cue = CueModel(
        id: const Uuid().v4(),
        title: title,
        description: description,
        audioUrl: audioUrl,
        latitude: lat,
        longitude: lng,
        createdAt: DateTime.now(),
        radius: radius,
        zoneType: zoneType,
        polygonPoints: polygonPoints,
      );

      // 4. Save to Repository
      await ref.read(cueRepositoryProvider).createCue(cue);
    });
  }
}
