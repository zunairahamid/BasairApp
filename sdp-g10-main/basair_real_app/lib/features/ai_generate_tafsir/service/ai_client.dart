import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIClient {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'https://api.openai.com/v1';
  final int _maxTokens = int.tryParse(dotenv.env['MAX_TOKENS'] ?? '1500') ?? 1500;
  final double _temperature = double.tryParse(dotenv.env['TEMPERATURE'] ?? '0.3') ?? 0.3;

  Future<String> generateExplanation({
    required String text,
    required String apiKey,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert Islamic scholar and Quranic exegesis specialist. You MUST provide all responses in ENGLISH only. Do not use Arabic in your responses. Provide comprehensive tafsir explanations covering linguistic analysis, historical context, theological significance, practical applications, and scholarly interpretations - but always in English. Translate any Arabic terms you mention into English and provide their meanings in English.'
            },
            {
              'role': 'user', 
              'content': text
            }
          ],
          'max_tokens': _maxTokens,
          'temperature': _temperature,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final explanation = data['choices'][0]['message']['content'].toString().trim();
        print('🤖 AI RESPONSE: $explanation');
        return explanation;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your .env file.');
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please try again later.');
      } else {
        throw Exception('AI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}