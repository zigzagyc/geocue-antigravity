import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hearhere/features/cue/data/cue_repository.dart';
import 'package:hearhere/features/cue/domain/cue_model.dart';
import 'package:hearhere/features/auth/data/auth_repository.dart';
import 'package:hearhere/services/ai_service.dart';
import 'package:hearhere/services/storage_service.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hearhere/features/auth/domain/user_model.dart'; // Import
import 'package:hearhere/features/admin/data/locked_area_repository.dart';
import 'package:geolocator/geolocator.dart';

part 'create_cue_controller.g.dart';

@riverpod
class CreateCueController extends _$CreateCueController {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  Future<UserModel> _fetchCurrentUser() async {
    final authUser = ref.read(authRepositoryProvider).currentUser;
    if (authUser == null) throw Exception('User not logged in');
    
    // Fetch full user model for permissions
    final doc = await FirebaseFirestore.instance.collection('users').doc(authUser.uid).get();
    if (!doc.exists) throw Exception('User profile not found');
    
    return UserModel.fromJson(doc.data()!);
  }

  Future<void> _checkPermissions(UserModel user, double lat, double lng) async {
    if (user.isDisabled || !user.canCreateCues) {
      throw Exception('You are not authorized to create cues.');
    }

    // Check locked areas
    final lockedAreas = await ref.read(lockedAreaRepositoryProvider).getLockedAreas();
    for (final area in lockedAreas) {
      final distance = Geolocator.distanceBetween(lat, lng, area.latitude, area.longitude);
      if (distance <= area.radius) {
         if (!user.isAdmin) {
             throw Exception('This location is in a restricted area: ${area.reason ?? "Locked"}');
         }
      }
    }
  }

  static const supportedLanguages = ['en', 'zh', 'es', 'fr', 'de', 'ja', 'ko'];

  Future<void> createCueFromText({
    required String title,
    required String description,
    required String textContent,
    String? language, // Optional. If null, we detect.
    required double lat,
    required double lng,
    double radius = 50.0,
    String zoneType = 'circle',
    List<Map<String, double>>? polygonPoints,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _fetchCurrentUser();
      await _checkPermissions(user, lat, lng);
      
      final aiService = ref.read(aiServiceProvider);

      // 1. Detect Language if not provided
      String sourceLang = language ?? 'en';
      if (language == null || language.isEmpty) {
        sourceLang = await aiService.detectLanguage(textContent);
      }



      // 2. Create Main Cue (Original)
      // Generate TTS for original
      final mainAudioUrl = await aiService.textToSpeech(textContent, sourceLang);
      
      final mainCueId = const Uuid().v4();
      final mainCue = CueModel(
        id: mainCueId,
        ownerId: user.id,
        title: title,
        description: description,
        audioUrl: mainAudioUrl,
        latitude: lat,
        longitude: lng,
        createdAt: DateTime.now(),
        radius: radius,
        zoneType: zoneType,
        polygonPoints: polygonPoints,
        language: sourceLang,
        originalCueId: null, // This is original
      );

      await ref.read(cueRepositoryProvider).createCue(mainCue);

      // 3. Generate Variations
      // We want to generate for ALL supported languages EXCEPT the source one.
      for (final targetLang in supportedLanguages) {
        if (targetLang == sourceLang) continue;
        

        
        // Translate
        final translatedText = await aiService.translate(textContent, targetLang);
        final translatedTitle = await aiService.translate(title, targetLang);
        final translatedDesc = await aiService.translate(description, targetLang); // Optional
        
        // TTS
        final audioUrl = await aiService.textToSpeech(translatedText, targetLang);
        
        final siblingCue = CueModel(
          id: const Uuid().v4(),
          ownerId: user.id,
          title: translatedTitle,
          description: translatedDesc,
          audioUrl: audioUrl,
          latitude: lat,
          longitude: lng,
          createdAt: DateTime.now(),
          radius: radius,
          zoneType: zoneType,
          polygonPoints: polygonPoints,
          language: targetLang,
          originalCueId: mainCueId, // Link to main
          referenceCueId: mainCueId, // Link to main
        );
        
        await ref.read(cueRepositoryProvider).createCue(siblingCue);
      }
    });
  }

  Future<void> createCueFromAudio({
    required String title,
    required String description,
    required String audioFilePath,
    String? language,
    required double lat,
    required double lng,
    double radius = 50.0,
    String zoneType = 'circle',
    List<Map<String, double>>? polygonPoints,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _fetchCurrentUser();
      await _checkPermissions(user, lat, lng);
      final aiService = ref.read(aiServiceProvider);

      final fileName = '${const Uuid().v4()}.m4a';
      final storagePath = 'users/${user.id}/cues/$fileName';
      
      // 1. Upload Audio File (Source)
      final sourceAudioUrl = await ref.read(storageServiceProvider).uploadFile(
        File(audioFilePath),
        storagePath,
      );

      // 2. Transcribe & Detect Language
      // If language not provided, we might need a hint or multi-pass. 
      // Current STT usually needs a language hint, or defaults to en. 
      // Using 'en' as default hint if null, but we can try to detect.
      // Actually, if we use Gemini, we can ask it to detect language FROM audio.
      String sourceLang = language ?? 'en';
      final transcription = await aiService.speechToText(audioFilePath, sourceLang);
      
      // If we didn't know language, let's detect it from the transcription text now
      if (language == null || language.isEmpty) {
        sourceLang = await aiService.detectLanguage(transcription);
      }
      


      // 3. Create Main Cue
      final mainCueId = const Uuid().v4();
      final mainCue = CueModel(
        id: mainCueId,
        ownerId: user.id,
        title: title,
        description: description,
        audioUrl: sourceAudioUrl, // Original voice
        latitude: lat,
        longitude: lng,
        createdAt: DateTime.now(),
        radius: radius,
        zoneType: zoneType,
        polygonPoints: polygonPoints,
        language: sourceLang,
        originalCueId: null,
      );

      await ref.read(cueRepositoryProvider).createCue(mainCue);

      // 4. Generate Variations (Translated Text + TTS)
      for (final targetLang in supportedLanguages) {
        if (targetLang == sourceLang) continue;
        


        // Translate the transcription
        final translatedText = await aiService.translate(transcription, targetLang);
        final translatedTitle = await aiService.translate(title, targetLang);
        final translatedDesc = await aiService.translate(description, targetLang);

        // TTS
        final audioUrl = await aiService.textToSpeech(translatedText, targetLang);

        final siblingCue = CueModel(
          id: const Uuid().v4(),
          ownerId: user.id,
          title: translatedTitle,
          description: translatedDesc, // Translated description
          audioUrl: audioUrl, // AI Voice
          latitude: lat,
          longitude: lng,
          createdAt: DateTime.now(),
          radius: radius,
          zoneType: zoneType, // Share zone
          polygonPoints: polygonPoints,
          language: targetLang,
          originalCueId: mainCueId,
          referenceCueId: mainCueId,
        );
        
        await ref.read(cueRepositoryProvider).createCue(siblingCue);
      }
    });
  }
  
  // Note: For Update, we need to check ownership.
  // We need to fetch the existing cue to check ownership? 
  // No, we can pass expected ownerId or ownership check logic.
  // Actually, UI calls this with known cue ID. We should check if current user is owner.
  // Since we don't pass 'originalOwnerId' here, we might have a gap.
  // Let's assume the UI passes the cue object OR we fetch it. 
  // Better: Pass ownerId to these update methods to verify.
  // EXCEPT: Modify `CueModel` implies we need `ownerId` in update too to persist it correctly (if we replace whole doc).
  
  Future<void> updateCueFromText({
    required String cueId,
    // We need original owner ID to preserve it and check permissions
    // Fetching cue inside controller is safer than trusting UI
    required String title,
    required String description,
    required String textContent,
    required String language,
    required DateTime createdAt,
    required double lat,
    required double lng,
    double radius = 50.0,
    String zoneType = 'circle',
    List<Map<String, double>>? polygonPoints,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _fetchCurrentUser();
      
      // Fetch existing cue to check owner
      final existingCue = await ref.read(cueRepositoryProvider).getCue(cueId);
      if (existingCue == null) throw Exception('Cue not found');
      
      if (existingCue.ownerId != user.id && !user.isAdmin) {
        throw Exception('You do not have permission to edit this cue.');
      }
      
      // Note: Locked area check applies to NEW cues. Requirement says:
      // "The user with existing cues in that area ... can still edit"
      // So we skip _checkPermissions(lockedArea) here!

      final audioUrl = await ref.read(aiServiceProvider).textToSpeech(textContent, language);

      final cue = CueModel(
        id: cueId,
        ownerId: existingCue.ownerId, // Preserve owner
        title: title,
        description: description,
        audioUrl: audioUrl,
        latitude: lat,
        longitude: lng,
        createdAt: createdAt, 
        radius: radius,
        zoneType: zoneType,
        polygonPoints: polygonPoints,
      );

      await ref.read(cueRepositoryProvider).updateCue(cue);
    });
  }

  Future<void> updateCueFromAudio({
    required String cueId,
    required String title,
    required String description,
    String? newAudioFilePath,
    required String originalAudioUrl,
    required DateTime createdAt,
    required String language,
    required double lat,
    required double lng,
    double radius = 50.0,
    String zoneType = 'circle',
    List<Map<String, double>>? polygonPoints,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _fetchCurrentUser();

      // Fetch existing cue to check owner
      final existingCue = await ref.read(cueRepositoryProvider).getCue(cueId);
      if (existingCue == null) throw Exception('Cue not found');
      
      if (existingCue.ownerId != user.id && !user.isAdmin) {
        throw Exception('You do not have permission to edit this cue.');
      }

      String audioUrl = originalAudioUrl;

      if (newAudioFilePath != null) {
        final fileName = '${const Uuid().v4()}.m4a';
        final storagePath = 'users/${user.id}/cues/$fileName';
        
        audioUrl = await ref.read(storageServiceProvider).uploadFile(
          File(newAudioFilePath),
          storagePath,
        );
      }

      final cue = CueModel(
        id: cueId,
        ownerId: existingCue.ownerId,
        title: title,
        description: description,
        audioUrl: audioUrl,
        latitude: lat,
        longitude: lng,
        createdAt: createdAt,
        radius: radius,
        zoneType: zoneType,
        polygonPoints: polygonPoints,
      );

      await ref.read(cueRepositoryProvider).updateCue(cue);
    });
  }
}
