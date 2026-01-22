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
      final user = await _fetchCurrentUser();
      await _checkPermissions(user, lat, lng);

      // 1. Generate Audio from Text
      final audioUrl = await ref.read(aiServiceProvider).textToSpeech(textContent, language);

      // 2. Create Cue Model
      final cue = CueModel(
        id: const Uuid().v4(),
        ownerId: user.id,
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
      final user = await _fetchCurrentUser();
      await _checkPermissions(user, lat, lng);

      final fileName = '${const Uuid().v4()}.m4a';
      final storagePath = 'users/${user.id}/cues/$fileName';
      
      // 1. Upload Audio File
      final audioUrl = await ref.read(storageServiceProvider).uploadFile(
        File(audioFilePath),
        storagePath,
      );

      // 2. Create Cue Model
      final cue = CueModel(
        id: const Uuid().v4(),
        ownerId: user.id,
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
