import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hearhere/features/auth/domain/user_model.dart';
import 'package:hearhere/features/auth/data/auth_repository.dart';
import 'package:hearhere/features/admin/domain/locked_area_model.dart';
import 'package:hearhere/features/admin/data/locked_area_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

part 'admin_controller.g.dart';

@riverpod
class AdminController extends _$AdminController {
  @override
  FutureOr<List<UserModel>> build() async {
    return _fetchUsers();
  }

  Future<List<UserModel>> _fetchUsers() async {
    return ref.read(authRepositoryProvider).getAllUsers();
  }

  Future<void> refreshUsers() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchUsers());
  }
  
  // This helps recover accounts that have cues but no user profile doc
  Future<int> syncOrphanedUsers() async {
    final firestore = FirebaseFirestore.instance;
    final cuesSnap = await firestore.collection('cues').get();
    final usersSnap = await firestore.collection('users').get();
    
    final existingUserIds = usersSnap.docs.map((d) => d.id).toSet();
    final orphanIds = <String>{};
    
    for (var doc in cuesSnap.docs) {
      final ownerId = doc.data()['ownerId'] as String?;
      if (ownerId != null && !existingUserIds.contains(ownerId)) {
        orphanIds.add(ownerId);
      }
    }
    
    int restored = 0;
    for (final uid in orphanIds) {
      // Create a placeholder profile so they appear in the list
      // We don't know their email from here unfortunately, so we set a placeholder
      // The admin can't reset password without email... 
      // WAIT. If we don't have email, we can't reset password.
      // But maybe we can list them and finding their email is another issue?
      // Actually, Client SDK cannot list users to get email from UID.
      // So effectively, if we don't have their email in DB, we are stuck unless...
      // The user knows their email?
      // If the user forgot password, they can just use "Forgot Password" on login screen if they know email.
      // If the ADMIN wants to help, Admin needs email.
      
      // Let's create the doc with "Unknown Email" so at least we see the ID.
      await firestore.collection('users').doc(uid).set({
        'id': uid,
        'email': 'unknown_email_for_$uid',
        'displayName': 'Restored User',
        'isAdmin': false,
        'canCreateCues': true,
        'isDisabled': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      restored++;
    }
    
    if (restored > 0) refreshUsers();
    return restored;
  }

  Future<void> toggleUserDisabled(String uid, bool currentStatus) async {
    // Optimistic update? No, let's refresh for safety or partial update.
    await ref.read(authRepositoryProvider).updateUserStatus(uid, isDisabled: !currentStatus);
    ref.invalidateSelf();
  }

  Future<void> toggleCanCreateCues(String uid, bool currentStatus) async {
    await ref.read(authRepositoryProvider).updateUserStatus(uid, canCreateCues: !currentStatus);
    ref.invalidateSelf();
  }
  
  Future<void> toggleAdmin(String uid, bool currentStatus) async {
    await ref.read(authRepositoryProvider).updateUserStatus(uid, isAdmin: !currentStatus);
    ref.invalidateSelf();
  }

  Future<void> resetPassword(String email) async {
    await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
  }

  Future<void> createLockedArea({
    required double latitude,
    required double longitude,
    required double radius,
    required String reason,
  }) async {
    // Check for duplicates
    final existingAreas = await ref.read(lockedAreaRepositoryProvider).getLockedAreas();
    for (final area in existingAreas) {
      final distance = Geolocator.distanceBetween(latitude, longitude, area.latitude, area.longitude);
      // If the new center is within the existing area OR the existing center is within the new area
      // Actually, let's just say if they overlap significantly.
      // Simplest check: unique location. If distance < 5 meters (accounting for GPS drift), reject.
      // Better check: If valid overlap.
      // User complaint: "lock a cue more than once".
      // Let's implement a strict check: if distance < (radius + area.radius), they overlap.
      // But maybe we want to allow overlapping locks? The user said "lock a cue more than once", suggesting identical locks.
      // Let's prevent if distance is very small (< 2 meters).
      if (distance < 5) {
        throw Exception('This location is already locked.');
      }
    }
    
    // We need current user for 'createdBy'
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    final area = LockedAreaModel(
      id: const Uuid().v4(),
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      reason: reason,
      createdBy: user.email ?? user.uid,
      createdAt: DateTime.now(),
    );
    
    await ref.read(lockedAreaRepositoryProvider).createLockedArea(area);
  }

  Future<void> deleteLockedArea(String id) async {
    await ref.read(lockedAreaRepositoryProvider).deleteLockedArea(id);
  }
}

@riverpod
Stream<List<LockedAreaModel>> lockedAreasStream(Ref ref) {
  return ref.watch(lockedAreaRepositoryProvider).watchLockedAreas();
}
