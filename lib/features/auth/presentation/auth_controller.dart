import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_repository.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // No initial state to load
  }

  Future<bool> checkAnyAdminExists() async {
    return ref.read(authRepositoryProvider).checkAnyAdminExists();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(authRepositoryProvider).signInWithEmailAndPassword(email, password));
  }

  Future<void> resetPassword(String email) async {
    // Fire and forget mostly, or handle error
    if (email.isEmpty) throw Exception('Email is required');
    await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
  }

  Future<void> signUp(String email, String password, {bool asAdmin = false}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(authRepositoryProvider).createUserWithEmailAndPassword(email, password, requestAdmin: asAdmin));
  }
    
  Future<void> signOut() async {
      // Sign out does not need to set loading state usually, but can if redirecting
      await ref.read(authRepositoryProvider).signOut();
  }
}
