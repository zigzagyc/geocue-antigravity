import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hearhere/features/auth/domain/user_model.dart';

part 'auth_repository.g.dart';

// Abstract interface
abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> createUserWithEmailAndPassword(String email, String password, {bool requestAdmin = false});
  Future<void> signOut();
  Future<bool> checkAnyAdminExists();
  Future<List<UserModel>> getAllUsers();
  Future<void> updateUserStatus(String uid, {bool? isDisabled, bool? canCreateCues, bool? isAdmin});
  Future<void> sendPasswordResetEmail(String email);
}

// Concrete implementation (using FirebaseAuth & Firestore)
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  
  FirebaseAuthRepository(this._auth, this._firestore);

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (credential.user != null) {
      await _ensureFirestoreDoc(credential.user!);
    }
  }

  Future<void> _ensureFirestoreDoc(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      // Create missing user doc (Backfill)
      await docRef.set({
        'id': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'isAdmin': false,
        'canCreateCues': true,
        'isDisabled': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<bool> checkAnyAdminExists() async {
    final snapshot = await _firestore
        .collection('users')
        .where('isAdmin', isEqualTo: true)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
  
  @override
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    final users = snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
    // Sort in memory (safe for missing fields)
    // We don't have createdAt in UserModel yet to sort by, so just return as is or sort by email
    // users.sort((a, b) => a.email.compareTo(b.email)); 
    return users;
  }
  
  @override
  Future<void> updateUserStatus(String uid, {bool? isDisabled, bool? canCreateCues, bool? isAdmin}) async {
    final Map<String, dynamic> updates = {};
    if (isDisabled != null) updates['isDisabled'] = isDisabled;
    if (canCreateCues != null) updates['canCreateCues'] = canCreateCues;
    if (isAdmin != null) updates['isAdmin'] = isAdmin;
    
    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(updates);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> createUserWithEmailAndPassword(String email, String password, {bool requestAdmin = false}) async {
    // 1. Create Auth User
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user;
    
    if (user != null) {
      bool isAdmin = false;
      
      // 2. Check Admin logic if requested
      if (requestAdmin) {
        // Double check against race conditions (best effort client side)
        final anyAdmin = await checkAnyAdminExists();
        if (!anyAdmin) {
          isAdmin = true;
        }
      }

      // 3. Create User Document in Firestore
      // We manually construct the JSON to match UserModel structure for now, 
      // or imports UserModel if we want type safety here but repo usually deals with DTOs or models efficiently.
      // Let's write directly.
      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'isAdmin': isAdmin,
        'canCreateCues': true,
        'isDisabled': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

// Provider
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return FirebaseAuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
}

@riverpod
Stream<User?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@riverpod
Stream<UserModel?> currentUserModel(Ref ref) async* {
  final authRepo = ref.watch(authRepositoryProvider);
  await for (final user in authRepo.authStateChanges) {
    if (user == null) {
      yield null;
    } else {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        yield null;
      } else {
        yield UserModel.fromJson(doc.data()!);
      }
    }
  }
}
