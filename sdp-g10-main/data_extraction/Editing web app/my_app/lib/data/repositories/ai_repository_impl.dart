import '../../domain/repositories/ai_repository.dart';

import 'package:google_generative_ai/google_generative_ai.dart';

class AiRepositoryImpl implements AiRepository {
  final GenerativeModel model;

  AiRepositoryImpl(String apiKey)
    : model = GenerativeModel(model: 'models/gemini-2.5-flash', apiKey: apiKey);

  @override
  Future<String> convertTextToJson(String text, String prompt) async {
    final response = await model.generateContent([
      Content.text('$prompt\n\n$text'),
    ]);
    final rawResponse = response.text ?? '{}';

    String cleanedResponse = rawResponse.trim();
    if (cleanedResponse.startsWith('```json')) {
      cleanedResponse = cleanedResponse.replaceFirst('```json', '').trim();
    }
    if (cleanedResponse.endsWith('```')) {
      cleanedResponse = cleanedResponse
          .substring(0, cleanedResponse.lastIndexOf('```'))
          .trim();
    }
    cleanedResponse = cleanedResponse.replaceAllMapped(
      RegExp(r'("text"\s*:\s*")([^"]*)(")'),
      (match) =>
          '${match[1]}${match[2]?.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}${match[3]}',
    );
    return cleanedResponse;
  }
}

