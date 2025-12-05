// services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIClient {
  final String baseUrl;

  AIClient({this.baseUrl = 'https://api.openai.com/v1'});

  Future<String> generateExplanation(String text, String context) async {
    try {
      await dotenv.load();
      final apiKey = dotenv.get('OPENAI_API_KEY');
      
      if (apiKey.isEmpty) {
        throw Exception('OpenAI API key not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert Islamic scholar and tafsir (Quranic interpretation) specialist. Provide clear, educational explanations of Quranic verses and concepts.'
            },
            {
              'role': 'user',
              'content': 'Explain this Quranic tafsir content in simple, educational terms: "$text"'
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> choices = data['choices'];
        if (choices.isNotEmpty) {
          final Map<String, dynamic> message = choices.first['message'];
          return message['content'] as String;
        }
      }
      
      throw Exception('Failed to generate explanation: ${response.statusCode}');
    } catch (e) {
      print('AI explanation error: $e');
      throw Exception('Failed to generate AI explanation: $e');
    }
  }

  Future<bool> isAvailable() async {
    try {
      await dotenv.load();
      final apiKey = dotenv.get('OPENAI_API_KEY');
      return apiKey.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

class AIService {
  final AIClient aiClient;

  AIService({required this.aiClient});

  Future<String> explainText(String text) async {
    return await aiClient.generateExplanation(text, 'Quranic Tafsir');
  }

  Future<String> explainSectionWithAyat({
    required String text,
    required List<int> ayatRange,
    String? sectionTitle,
  }) async {
    final context = 'Quranic verses ${ayatRange[0]}-${ayatRange[1]}${sectionTitle != null ? ' from $sectionTitle' : ''}';
    return await aiClient.generateExplanation(text, context);
  }

  Future<String> explainWithContext({
    required String text,
    String? topic,
    String? subtopic,
    String? subsection,
  }) async {
    String context = 'Quranic tafsir';
    if (topic != null) context += ' about $topic';
    if (subtopic != null) context += ' - $subtopic';
    if (subsection != null) context += ' ($subsection)';
    
    return await aiClient.generateExplanation(text, context);
  }

  Future<bool> isAvailable() async {
    return await aiClient.isAvailable();
  }
}