import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

part 'ai_service.g.dart';

abstract class AiService {
  Future<String> textToSpeech(String text, String language);
  Future<String> speechToText(String audioPath, String language);
  Future<String> translate(String text, String targetLanguage);
}

class MockAiService implements AiService {
  @override
  Future<String> textToSpeech(String text, String language) async {
    // Return a dummy URL or path
    await Future.delayed(const Duration(seconds: 1));
    return 'https://example.com/audio.mp3';
  }

  @override
  Future<String> speechToText(String audioPath, String language) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'This is recognized text from audio.';
  }

  @override
  Future<String> translate(String text, String targetLanguage) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'Translated: $text';
  }
}

class GeminiAiService implements AiService {
  final GenerativeModel _model;
  
  GeminiAiService(String apiKey) 
    : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  @override
  Future<String> textToSpeech(String text, String language) async {
    // Gemini doesn't natively do TTS yet in this SDK. 
    // Mocking for now or suggesting a different service.
    return 'https://example.com/tts_simulated.mp3';
  }

  @override
  Future<String> speechToText(String audioPath, String language) async {
    final audioFile = File(audioPath);
    final audioBytes = await audioFile.readAsBytes();
    
    final prompt = TextPart('Transcribe this audio in $language. Only return the transcription.');
    final response = await _model.generateContent([
      Content.multi([
        prompt,
        DataPart('audio/mpeg', audioBytes), // Assuming mp3/m4a
      ])
    ]);
    
    return response.text ?? '';
  }

  @override
  Future<String> translate(String text, String targetLanguage) async {
    final prompt = 'Translate the following text to $targetLanguage: "$text". Only return the translation.';
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? text;
  }
}

@Riverpod(keepAlive: true)
AiService aiService(Ref ref) {
  // Try to get API KEY from environment or some config
  const apiKey = String.fromEnvironment('GEMINI_API_KEY');
  if (apiKey.isNotEmpty) {
    return GeminiAiService(apiKey);
  }
  return MockAiService();
}
