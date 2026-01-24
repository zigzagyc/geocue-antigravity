import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:translator/translator.dart';
import 'package:hearhere/features/settings/data/ai_settings_repository.dart';

part 'ai_service.g.dart';

class AiModelNotFoundException implements Exception {
  final String message;
  final String modelName;
  AiModelNotFoundException(this.message, this.modelName);
  @override
  String toString() => 'AiModelNotFoundException: $message ($modelName)';
}

abstract class AiService {
  Future<String> textToSpeech(String text, String language);
  Future<String> speechToText(String audioPath, String language);
  Future<String> translate(String text, String targetLanguage);
  Future<String> detectLanguage(String text);
  Future<List<String>> fetchAvailableModels();
}

class FallbackAiService implements AiService {
  final _translator = GoogleTranslator();

  @override
  Future<String> textToSpeech(String text, String language) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return '';
  }

  @override
  Future<String> speechToText(String audioPath, String language) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'This is recognized text from audio (Fallback).';
  }

  @override
  Future<String> translate(String text, String targetLanguage) async {
    try {
      final translation = await _translator.translate(text, to: targetLanguage);
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  @override
  Future<String> detectLanguage(String text) async {
    try {
      final translation = await _translator.translate(text, to: 'en');
      return translation.sourceLanguage.code;
    } catch (e) {
      return 'en';
    }
  }

  @override
  Future<List<String>> fetchAvailableModels() async {
    return [];
  }
}

class GeminiAiService implements AiService {
  GenerativeModel? _model;
  final String _apiKey;
  final AiSettingsRepository _settingsRepo;
  
  GeminiAiService(this._apiKey, this._settingsRepo);

  Future<GenerativeModel> _getModel() async {
    if (_model != null) return _model!;
    final modelName = await _settingsRepo.getModelName();
    _model = GenerativeModel(model: modelName, apiKey: _apiKey);
    return _model!;
  }
  
  // Force reset if model changes
  Future<void> reloadModel() async {
    _model = null; // Next call will re-fetch
  }

  Future<T> _executeWithFallback<T>(Future<T> Function(GenerativeModel model) operation) async {
    try {
      final model = await _getModel();
      return await operation(model);
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('models/') && errorStr.contains('not found')) {
        final modelName = await _settingsRepo.getModelName();
        throw AiModelNotFoundException('Model $modelName not found or deprecated.', modelName);
      }
      rethrow;
    }
  }

  @override
  Future<String> textToSpeech(String text, String language) async {
    return '';
  }

  @override
  Future<String> speechToText(String audioPath, String language) async {
    final audioFile = File(audioPath);
    final audioBytes = await audioFile.readAsBytes();
    
    return _executeWithFallback((model) async {
      final prompt = TextPart('Transcribe this audio. The language is likely $language. Only return the transcription text, nothing else.');
      final response = await model.generateContent([
        Content.multi([
          prompt,
          DataPart('audio/mpeg', audioBytes),
        ])
      ]);
      return response.text?.trim() ?? '';
    });
  }

  @override
  Future<String> translate(String text, String targetLanguage) async {
    return _executeWithFallback((model) async {
      final prompt = 'Translate the following text to $targetLanguage. Only return the translated text, nothing else: "$text"';
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? text;
    });
  }
  
  @override
  Future<String> detectLanguage(String text) async {
    return _executeWithFallback((model) async {
      final prompt = 'Detect the language of the following text: "$text". Return ONLY the 2-letter ISO 639-1 language code (e.g. en, es, zh, fr, de, ja, ko).';
      final response = await model.generateContent([Content.text(prompt)]);
      final code = response.text?.trim().toLowerCase() ?? 'en';
      return code.length > 2 ? code.substring(0, 2) : code;
    });
  }

  @override
  Future<List<String>> fetchAvailableModels() async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey');
    final client = HttpClient();
    try {
      final request = await client.getUrl(url);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        final json = jsonDecode(body);
        final models = json['models'] as List;
        return models
            .map((m) => m['name'].toString().replaceFirst('models/', ''))
            .where((name) => name.contains('gemini') || name.contains('flash') || name.contains('pro'))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching models: $e');
      return [];
    } finally {
      client.close();
    }
  }
}

@Riverpod(keepAlive: true)
AiService aiService(Ref ref) {
  const dartDefineKey = String.fromEnvironment('GEMINI_API_KEY');
  final envKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  
  final apiKey = dartDefineKey.isNotEmpty ? dartDefineKey : envKey;
  final settingsRepo = ref.watch(aiSettingsRepositoryProvider);

  if (apiKey.isEmpty || apiKey == 'Place_Your_Key_Here') {
     print('CRITICAL: Gemini API Key is missing.');
     return GeminiAiService('', settingsRepo);
  }
  
  return GeminiAiService(apiKey, settingsRepo);
}
