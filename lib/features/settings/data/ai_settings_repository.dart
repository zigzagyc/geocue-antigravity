import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'ai_settings_repository.g.dart';

class AiSettingsRepository {
  static const _kGeminiModelKey = 'gemini_model_name';
  // Default to the one we know works now, but allow override
  static const _kDefaultModel = 'gemini-2.0-flash'; 

  Future<void> setModelName(String modelName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kGeminiModelKey, modelName);
  }

  Future<String> getModelName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kGeminiModelKey) ?? _kDefaultModel;
  }
}

@riverpod
AiSettingsRepository aiSettingsRepository(Ref ref) {
  return AiSettingsRepository();
}
