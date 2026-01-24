import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  final apiKey = 'AIzaSyBxNYq0RME6rAU0LkW9txaLg_IYuw0LlRk';
  
  final modelsToTest = [
    'gemini-2.0-flash',
    'gemini-flash-latest',
  ];

  print('Testing newer models with API Key: ${apiKey.substring(0, 5)}...');

  for (final modelName in modelsToTest) {
    stdout.write('Testing $modelName... ');
    try {
      final model = GenerativeModel(model: modelName, apiKey: apiKey);
      final response = await model.generateContent([Content.text('Hello')]);
      print('SUCCESS!');
    } catch (e) {
      print('FAILED: ${e.toString().split('\n').first}');
    }
  }
}
