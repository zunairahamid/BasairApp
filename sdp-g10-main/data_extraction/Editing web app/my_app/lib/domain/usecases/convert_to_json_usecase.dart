import 'dart:convert';
import '../entities/tafsir.dart';
import '../repositories/ai_repository.dart';

class ConvertToJsonUseCase {
  final AiRepository aiRepository;

  ConvertToJsonUseCase(this.aiRepository);

  Future<Tafsir> call(String extractedText, String prompt) async {
    final truncatedText = extractedText.length > 12000
        ? extractedText.substring(0, 12000) + '\n...'
        : extractedText;

    final raw = await aiRepository.convertTextToJson(truncatedText, prompt);

    final jsonString = _extractJson(raw);
    final map = json.decode(jsonString);


    if (map['tafsirId'] == null || (map['tafsirId'] as String).trim().isEmpty) {
      final surahId = (map['surahId'] ?? 'unknown').toString();
      map['tafsirId'] =
          "tafsir_${surahId}_${DateTime.now().millisecondsSinceEpoch}";
    }

    return Tafsir.fromJson(map);
  }


  String _extractJson(String raw) {
    raw = raw.trim();

 
    raw = raw.replaceAll(RegExp(r"```json"), "");
    raw = raw.replaceAll(RegExp(r"```"), "").trim();


    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw FormatException("AI output doesn't contain JSON.");
    }
    return raw.substring(start, end + 1);
  }
}


