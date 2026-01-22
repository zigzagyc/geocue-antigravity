import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:translator/translator.dart';

part 'ai_service.g.dart';

abstract class AiService {
  Future<String> textToSpeech(String text, String language);
  Future<String> speechToText(String audioPath, String language);
  Future<String> translate(String text, String targetLanguage);
  Future<String> detectLanguage(String text);
}

class FallbackAiService implements AiService {
  final _translator = GoogleTranslator();

  @override
  Future<String> textToSpeech(String text, String language) async {
    // Return empty string to signal UI/PlaybackService to use on-device TTS
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
      return text; // Return original on error
    }
  }

  @override
  Future<String> detectLanguage(String text) async {
    try {
      // Translator package detects on translate, or we can just default to 'en' 
      // if we don't want to make a network call just for detection.
      // But let's try to be helpful. 
      // Note: The package doesn't expose a standalone detect method easily 
      // without translating.
      // Optimization: For now default to 'en' to save a call, or implement if critical.
      // Actually, let's just return 'en' to be safe and fast for now, 
      // or we can abuse translate to 'en' to check source.
      final translation = await _translator.translate(text, to: 'en');
      return translation.sourceLanguage.code;
    } catch (e) {
      return 'en';
    }
  }
}

class GeminiAiService implements AiService {
  final GenerativeModel _model;
  
  GeminiAiService(String apiKey) 
    : _model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);

  @override
  Future<String> textToSpeech(String text, String language) async {
    // Gemini doesn't natively do TTS yet in this SDK. 
    // Return empty string to signal UI/PlaybackService to use on-device TTS (flutter_tts)
    return '';
  }

  @override
  Future<String> speechToText(String audioPath, String language) async {
    final audioFile = File(audioPath);
    final audioBytes = await audioFile.readAsBytes();
    
    // Explicitly ask for JSON if we want structure, or just text.
    // For STT we usually just want text.
    final prompt = TextPart('Transcribe this audio. The language is likely $language. Only return the transcription text, nothing else.');
    final response = await _model.generateContent([
      Content.multi([
        prompt,
        DataPart('audio/mpeg', audioBytes), // Assuming mp3/m4a
      ])
    ]);
    
    return response.text?.trim() ?? '';
  }

  @override
  Future<String> translate(String text, String targetLanguage) async {
    final prompt = 'Translate the following text to $targetLanguage. Only return the translated text, nothing else: "$text"';
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text?.trim() ?? text;
  }
  
  Future<String> detectLanguage(String text) async {
    final prompt = 'Detect the language of the following text: "$text". Return ONLY the 2-letter ISO 639-1 language code (e.g. en, es, zh, fr, de, ja, ko).';
    final response = await _model.generateContent([Content.text(prompt)]);
    final code = response.text?.trim().toLowerCase() ?? 'en';
    // Basic cleanup just in case
    return code.length > 2 ? code.substring(0, 2) : code;
  }
}



@Riverpod(keepAlive: true)
AiService aiService(Ref ref) {
  // Try to get API KEY from environment or some config
  // Priority: 
  // 1. --dart-define (CI/CD)
  // 2. .env file (Local Dev)
  
  const dartDefineKey = String.fromEnvironment('GEMINI_API_KEY');
  final envKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  
  final apiKey = dartDefineKey.isNotEmpty ? dartDefineKey : envKey;

  if (apiKey.isEmpty || apiKey == 'Place_Your_Key_Here') {
     // We no longer fallback to mock. We enforce Real AI.
     // Throwing error here will make it obvious to the user they need a key.
     print('CRITICAL: Gemini API Key is missing. Please add it to .env or run with --dart-define=GEMINI_API_KEY=...');
     // Return empty service to avoid crash, but calls will fail.
     return GeminiAiService('');
  }
  
  return GeminiAiService(apiKey);
}
