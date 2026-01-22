import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hearhere/features/auth/data/auth_repository.dart';

part 'language_controller.g.dart';

@Riverpod(keepAlive: true)
class PreferredLanguage extends _$PreferredLanguage {
  static const _kPrefKey = 'preferred_language';
  static const supportedLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'zh', 'name': 'Chinese', 'flag': '🇨🇳'},
    {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'German', 'flag': '🇩🇪'},
    {'code': 'ja', 'name': 'Japanese', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': 'Korean', 'flag': '🇰🇷'},
  ];

  @override
  FutureOr<String> build() async {
    // 1. Check Auth User Preference
    final user = ref.watch(authStateChangesProvider).value;
    if (user != null) {
      // Fetch full profile to get stored preference
       final doc = await ref.read(currentUserModelProvider.future);
       if (doc != null) return doc.preferredLanguage;
    }

    // 2. Fallback to SharedPrefs (Guest or no cloud data)
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPrefKey) ?? 'en';
  }

  Future<void> setLanguage(String languageCode) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // 1. Save locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefKey, languageCode);

      // 2. Save to User Profile if logged in
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        // We need a method to update just the language, or generic update
        // We added updateUserStatus but that was for admin flags. 
        // We might need to add `updatePreferredLanguage` to AuthRepo or do it here directly via Firestore.
        // For speed, let's use a new method or direct Firestore (not ideal but quick).
        // Check AuthRepository first.
      }
      return languageCode;
    });
  }
}
